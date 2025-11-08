#!/bin/bash
# Example script for designing DNA aptamers

# Example 1: Design DNA aptamer for a protein target (Thrombin, PDB: 1HAO)
echo "=========================================="
echo "Example 1: DNA Aptamer for Thrombin"
echo "=========================================="
echo "Note: Using DNA target (5zmc) as example since protein download may fail due to SSL"
echo "To use protein target, first download PDB manually and use --pdb_path"

python boltzdesign.py \
  --target_name 5zmc \
  --target_type dna \
  --pdb_target_ids C,D \
  --binder_type dna \
  --binder_id A \
  --length_min 30 \
  --length_max 60 \
  --num_inter_contacts 5 \
  --design_samples 2 \
  --gpu_id 0 \
  --suffix dna_example1


# Example 2: Design DNA aptamer for a small molecule (ATP)
echo "=========================================="
echo "Example 2: DNA Aptamer for ATP"
echo "=========================================="

python boltzdesign.py \
  --target_name ATP_aptamer \
  --input_type custom \
  --target_type small_molecule \
  --custom_target_input "C1=NC(=C2C(=N1)N(C=N2)C3C(C(C(O3)COP(=O)(O)OP(=O)(O)OP(=O)(O)O)O)O)N" \
  --binder_type dna \
  --binder_id A \
  --length_min 25 \
  --length_max 50 \
  --num_inter_contacts 6 \
  --design_samples 2 \
  --gpu_id 0 \
  --suffix dna_atp_aptamer


# Example 3: Design DNA aptamer for a protein using custom sequence
echo "=========================================="
echo "Example 3: DNA Aptamer for Custom Protein"
echo "=========================================="
echo "Using custom protein sequence to avoid PDB download issues"

python boltzdesign.py \
  --target_name custom_protein \
  --input_type custom \
  --target_type protein \
  --custom_target_input "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQHDFSAGEGLYTHMKALRPDEDRLSPLHSVYVDQWDWERVMGDGERQFSTLKSTVEAIWAGIKATEAAVSEEFGLAPFLPDQIHFVHSQELLSRYPDLDAKGRERAIAKDLGAVFLVGIGGKLSDGHRHDVRAPDYDDWSTPSELGHAGLNGDILVWNPVLEDAFELSSMGIRVDADTLKHQLALTGDEDRLELEWHQALLRGEMPQTIGGGIGQSRLTMLLLQLPHIGQVQAGVWPAAVRESVPSLL" \
  --binder_type dna \
  --binder_id A \
  --length_min 40 \
  --length_max 70 \
  --num_inter_contacts 6 \
  --design_samples 2 \
  --gpu_id 0 \
  --suffix dna_custom_protein


echo "=========================================="
echo "DNA Aptamer Design Examples Completed!"
echo "=========================================="
echo ""
echo "Results will be saved in:"
echo "  - outputs/protein_<target>_<suffix>/results_final/"
echo "  - outputs/protein_<target>_<suffix>/ligandmpnn_cutoff_4/03_af_pdb_success/"
echo ""
echo "High-confidence aptamer designs can be found in the success directory."
