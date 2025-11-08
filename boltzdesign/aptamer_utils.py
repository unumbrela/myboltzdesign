"""
Aptamer-specific utilities for DNA/RNA aptamer design.

This module provides specialized loss functions and optimization tools
for designing nucleic acid aptamers with desired properties.
"""

import torch
import numpy as np
from typing import Optional, Tuple


def calculate_gc_content(sequence: str) -> float:
    """
    Calculate GC content of a nucleotide sequence.

    Args:
        sequence: DNA or RNA sequence string

    Returns:
        float: GC content ratio (0.0 to 1.0)
    """
    sequence = sequence.upper()
    gc_count = sequence.count('G') + sequence.count('C')
    total = len(sequence)
    return gc_count / total if total > 0 else 0.0


def gc_content_loss(logits: torch.Tensor, target_gc: float = 0.5, weight: float = 0.1) -> torch.Tensor:
    """
    Loss function to guide GC content towards a target value.

    Optimal GC content for aptamers is typically 40-60% for stability.

    Args:
        logits: Sequence logits tensor [batch, length, vocab_size]
        target_gc: Target GC content (default: 0.5 for 50%)
        weight: Weight for this loss term

    Returns:
        torch.Tensor: GC content loss value
    """
    # Get nucleotide indices (assumes vocabulary order: A, G, C, U/T, N, DA, DG, DC, DT, DN)
    # For RNA: A=24, G=25, C=26, U=27
    # For DNA: DA=29, DG=30, DC=31, DT=32

    probs = torch.softmax(logits, dim=-1)

    # Calculate expected GC content from probabilities
    # This is a soft approximation that works during gradient-based optimization
    gc_prob_rna = probs[..., 25] + probs[..., 26]  # G + C for RNA
    gc_prob_dna = probs[..., 30] + probs[..., 31]  # DG + DC for DNA

    # Use the maximum to handle both RNA and DNA
    gc_prob = torch.maximum(gc_prob_rna, gc_prob_dna)

    # Average across sequence length
    mean_gc = gc_prob.mean(dim=-1)

    # L2 loss from target GC content
    loss = ((mean_gc - target_gc) ** 2).mean()

    return weight * loss


def sequence_complexity_loss(logits: torch.Tensor, weight: float = 0.2) -> torch.Tensor:
    """
    Loss function to penalize low-complexity sequences (e.g., homopolymers).

    Encourages diverse nucleotide usage to avoid sequences like "AAAAAAA" or "GCGCGCGC".

    Args:
        logits: Sequence logits tensor [batch, length, vocab_size]
        weight: Weight for this loss term

    Returns:
        torch.Tensor: Sequence complexity loss value
    """
    probs = torch.softmax(logits, dim=-1)

    # Calculate entropy at each position (higher entropy = more diverse)
    # Entropy = -sum(p * log(p))
    log_probs = torch.log(probs + 1e-10)  # Add small epsilon to avoid log(0)
    entropy = -(probs * log_probs).sum(dim=-1)

    # We want high entropy, so minimize negative entropy
    mean_entropy = entropy.mean()
    max_entropy = np.log(probs.shape[-1])  # Maximum possible entropy

    # Normalize to [0, 1] and invert (so low complexity = high loss)
    complexity_score = mean_entropy / max_entropy
    loss = 1.0 - complexity_score

    return weight * loss


def homopolymer_penalty(logits: torch.Tensor, max_run: int = 4, weight: float = 0.3) -> torch.Tensor:
    """
    Penalize long runs of the same nucleotide (homopolymers).

    Long homopolymers (e.g., "GGGGGG") can cause synthesis and folding issues.

    Args:
        logits: Sequence logits tensor [batch, length, vocab_size]
        max_run: Maximum allowed consecutive same nucleotides
        weight: Weight for this loss term

    Returns:
        torch.Tensor: Homopolymer penalty loss
    """
    probs = torch.softmax(logits, dim=-1)

    # Calculate probability of consecutive same nucleotides
    # For simplicity, we check adjacent positions
    # More sophisticated version would check longer runs

    # Compute similarity between adjacent positions
    # High similarity means likely same nucleotide
    similarity = torch.einsum('...li,...mi->...lm', probs, probs)

    # Extract diagonal elements (adjacent positions)
    penalty = 0.0
    for i in range(1, min(max_run + 1, probs.shape[1])):
        # Penalty for i consecutive same nucleotides
        diagonal = torch.diagonal(similarity, offset=i, dim1=-2, dim2=-1)
        penalty += diagonal.mean() * (i / max_run)  # Stronger penalty for longer runs

    return weight * penalty


def aptamer_structure_loss(
    logits: torch.Tensor,
    structure_type: str = 'hairpin',
    weight: float = 0.15
) -> torch.Tensor:
    """
    Encourage specific secondary structures in aptamers.

    Common aptamer structures:
    - hairpin: stem-loop structure
    - g_quadruplex: G-rich sequences that form quadruplexes
    - kissing_loop: two hairpins that interact

    Args:
        logits: Sequence logits tensor [batch, length, vocab_size]
        structure_type: Desired structure type
        weight: Weight for this loss term

    Returns:
        torch.Tensor: Structure loss value
    """
    probs = torch.softmax(logits, dim=-1)
    seq_len = probs.shape[1]

    if structure_type == 'hairpin':
        # Encourage complementarity between 5' and 3' ends
        # For hairpin structure, first N bases should complement last N bases
        stem_length = min(6, seq_len // 3)

        # Get probabilities for 5' stem
        stem_5_probs = probs[:, :stem_length, :]
        # Get probabilities for 3' stem (reversed)
        stem_3_probs = probs[:, -stem_length:, :].flip(dims=[1])

        # Calculate complementarity score
        # A-U/T pairs, G-C pairs
        # This is a simplified version; actual implementation would need
        # base-pairing matrix
        complementarity = torch.einsum('...li,...li->...l', stem_5_probs, stem_3_probs)
        comp_score = complementarity.mean()

        # We want high complementarity, so minimize negative score
        loss = -comp_score

    elif structure_type == 'g_quadruplex':
        # Encourage G-rich regions
        # G-quadruplex requires at least 4 runs of 3+ guanines
        g_idx_rna = 25  # G for RNA
        g_idx_dna = 30  # DG for DNA

        g_prob = torch.maximum(probs[..., g_idx_rna], probs[..., g_idx_dna])

        # Encourage high G content
        mean_g = g_prob.mean()
        loss = -mean_g  # Negative because we want to maximize

    else:
        # Default: no structural preference
        loss = torch.tensor(0.0, device=logits.device)

    return weight * loss


def calculate_tm(sequence: str, na_conc: float = 50.0, mg_conc: float = 2.0) -> float:
    """
    Estimate melting temperature (Tm) of a nucleic acid sequence.

    Uses nearest-neighbor method approximation.

    Args:
        sequence: DNA or RNA sequence
        na_conc: Sodium concentration in mM (default: 50 mM)
        mg_conc: Magnesium concentration in mM (default: 2 mM)

    Returns:
        float: Estimated Tm in Celsius
    """
    # Simplified Wallace rule for short sequences (< 14 nt)
    # Tm = 2(A+T) + 4(G+C)
    # For longer sequences, use more sophisticated nearest-neighbor method

    sequence = sequence.upper()
    length = len(sequence)

    if length < 14:
        # Wallace rule
        at_count = sequence.count('A') + sequence.count('T') + sequence.count('U')
        gc_count = sequence.count('G') + sequence.count('C')
        tm = 2 * at_count + 4 * gc_count
    else:
        # Simplified nearest-neighbor (this is approximate)
        gc_content = calculate_gc_content(sequence)
        tm = 81.5 + 16.6 * np.log10(na_conc / 1000.0) + 0.41 * (gc_content * 100) - 675.0 / length

    # Adjust for Mg2+ concentration (simplified)
    if mg_conc > 0:
        tm += np.log10(mg_conc) * 2.0

    return tm


def validate_aptamer_sequence(sequence: str, min_length: int = 20, max_length: int = 100) -> Tuple[bool, str]:
    """
    Validate an aptamer sequence for common issues.

    Args:
        sequence: Nucleotide sequence to validate
        min_length: Minimum acceptable length
        max_length: Maximum acceptable length

    Returns:
        Tuple of (is_valid, message)
    """
    sequence = sequence.upper()
    length = len(sequence)

    # Check length
    if length < min_length:
        return False, f"Sequence too short ({length} < {min_length})"
    if length > max_length:
        return False, f"Sequence too long ({length} > {max_length})"

    # Check for valid nucleotides
    valid_nt = set('ACGTU')
    invalid = set(sequence) - valid_nt
    if invalid:
        return False, f"Invalid nucleotides: {invalid}"

    # Check GC content (should be 30-70% for most applications)
    gc = calculate_gc_content(sequence)
    if gc < 0.3 or gc > 0.7:
        return False, f"Extreme GC content: {gc:.1%} (should be 30-70%)"

    # Check for long homopolymers (> 5 of same base)
    for nt in 'ACGU':
        if nt * 6 in sequence:
            return False, f"Long homopolymer detected: {nt * 6}"

    # Check for simple repeats
    for i in range(2, 6):
        repeat = sequence[:i]
        if repeat * (length // i + 1) in sequence * 2:
            return False, f"Simple repeat detected: {repeat}"

    return True, "Sequence passed validation"


# Combined aptamer loss function
def aptamer_design_loss(
    logits: torch.Tensor,
    target_gc: float = 0.5,
    structure_type: Optional[str] = None,
    weights: Optional[dict] = None
) -> Tuple[torch.Tensor, dict]:
    """
    Combined loss function for aptamer design.

    Args:
        logits: Sequence logits tensor
        target_gc: Target GC content
        structure_type: Desired secondary structure (optional)
        weights: Dictionary of loss weights (optional)

    Returns:
        Tuple of (total_loss, loss_dict)
    """
    if weights is None:
        weights = {
            'gc_content': 0.1,
            'complexity': 0.2,
            'homopolymer': 0.3,
            'structure': 0.15
        }

    loss_dict = {}

    # GC content loss
    gc_loss = gc_content_loss(logits, target_gc, weights['gc_content'])
    loss_dict['gc_content_loss'] = gc_loss.item()

    # Sequence complexity loss
    comp_loss = sequence_complexity_loss(logits, weights['complexity'])
    loss_dict['complexity_loss'] = comp_loss.item()

    # Homopolymer penalty
    homo_loss = homopolymer_penalty(logits, weight=weights['homopolymer'])
    loss_dict['homopolymer_loss'] = homo_loss.item()

    # Structure loss (optional)
    if structure_type:
        struct_loss = aptamer_structure_loss(logits, structure_type, weights['structure'])
        loss_dict['structure_loss'] = struct_loss.item()
    else:
        struct_loss = torch.tensor(0.0, device=logits.device)
        loss_dict['structure_loss'] = 0.0

    # Total loss
    total_loss = gc_loss + comp_loss + homo_loss + struct_loss
    loss_dict['total_aptamer_loss'] = total_loss.item()

    return total_loss, loss_dict
