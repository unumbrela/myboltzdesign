#!/bin/bash
# Example script for designing DNA aptamers

# Example 1: Design DNA aptamer for a protein target (Thrombin, PDB: 1HAO)
echo "=========================================="
echo "Example 1: DNA Aptamer for Thrombin"
echo "=========================================="

python boltzdesign.py \
  --target_name 1HAO \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type dna \
  --binder_id B \
  --length_min 30 \
  --length_max 60 \
  --num_inter_contacts 5 \
  --design_samples 10 \
  --gpu_id 0 \
  --suffix dna_thrombin_aptamer


# Example 2: Design DNA aptamer for a small molecule (ATP)
echo "=========================================="
echo "Example 2: DNA Aptamer for ATP"
echo "=========================================="

python boltzdesign.py \
  --target_name ATP_aptamer \
  --target_type small_molecule \
  --custom_target_input "C1=NC(=C2C(=N1)N(C=N2)C3C(C(C(O3)COP(=O)(O)OP(=O)(O)OP(=O)(O)O)O)O)N" \
  --binder_type dna \
  --binder_id A \
  --length_min 25 \
  --length_max 50 \
  --num_inter_contacts 6 \
  --design_samples 15 \
  --gpu_id 0 \
  --suffix dna_atp_aptamer


# Example 3: Design DNA aptamer with specific constraints
echo "=========================================="
echo "Example 3: DNA Aptamer with Constraints"
echo "=========================================="

python boltzdesign.py \
  --target_name 1M17 \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type dna \
  --binder_id B \
  --length_min 40 \
  --length_max 70 \
  --num_inter_contacts 6 \
  --inter_chain_cutoff 18 \
  --learning_rate 0.15 \
  --soft_iteration 100 \
  --design_samples 20 \
  --gpu_id 0 \
  --suffix dna_egfr_aptamer \
  --run_alphafold True


echo "=========================================="
echo "DNA Aptamer Design Examples Completed!"
echo "=========================================="
echo ""
echo "Results will be saved in:"
echo "  - outputs/protein_<target>_<suffix>/results_final/"
echo "  - outputs/protein_<target>_<suffix>/ligandmpnn_cutoff_4/03_af_pdb_success/"
echo ""
echo "High-confidence aptamer designs can be found in the success directory."
