#!/bin/bash
# Example script for designing RNA aptamers

# Example 1: Design RNA aptamer for a protein target (Streptavidin)
echo "=========================================="
echo "Example 1: RNA Aptamer for Streptavidin"
echo "=========================================="

python boltzdesign.py \
  --target_name 1STP \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type rna \
  --binder_id B \
  --length_min 30 \
  --length_max 70 \
  --num_inter_contacts 5 \
  --design_samples 10 \
  --gpu_id 0 \
  --suffix rna_streptavidin_aptamer


# Example 2: Design RNA aptamer for a small molecule (Theophylline)
echo "=========================================="
echo "Example 2: RNA Aptamer for Theophylline"
echo "=========================================="

python boltzdesign.py \
  --target_name theophylline_aptamer \
  --target_type small_molecule \
  --custom_target_input "CN1C2=C(C(=O)N(C1=O)C)NC=N2" \
  --binder_type rna \
  --binder_id A \
  --length_min 30 \
  --length_max 60 \
  --num_inter_contacts 6 \
  --design_samples 15 \
  --gpu_id 0 \
  --suffix rna_theophylline_aptamer


# Example 3: Design RNA aptamer for VEGF protein
echo "=========================================="
echo "Example 3: RNA Aptamer for VEGF"
echo "=========================================="

python boltzdesign.py \
  --target_name 1VPF \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type rna \
  --binder_id B \
  --length_min 40 \
  --length_max 80 \
  --num_inter_contacts 7 \
  --inter_chain_cutoff 18 \
  --learning_rate 0.15 \
  --soft_iteration 100 \
  --design_samples 20 \
  --gpu_id 0 \
  --suffix rna_vegf_aptamer \
  --run_alphafold True


# Example 4: Short RNA aptamer for metal ion (Mg2+)
echo "=========================================="
echo "Example 4: RNA Aptamer for Magnesium"
echo "=========================================="

python boltzdesign.py \
  --target_name mg_aptamer \
  --target_type metal \
  --custom_target_input "MG" \
  --binder_type rna \
  --binder_id A \
  --length_min 20 \
  --length_max 40 \
  --num_inter_contacts 3 \
  --design_samples 10 \
  --gpu_id 0 \
  --suffix rna_mg_aptamer


echo "=========================================="
echo "RNA Aptamer Design Examples Completed!"
echo "=========================================="
echo ""
echo "Results will be saved in:"
echo "  - outputs/<target_type>_<target>_<suffix>/results_final/"
echo "  - outputs/<target_type>_<target>_<suffix>/ligandmpnn_cutoff_4/03_af_pdb_success/"
echo ""
echo "High-confidence aptamer designs can be found in the success directory."
echo ""
echo "Note: RNA aptamers often have higher binding affinity than DNA aptamers"
echo "      due to the 2'-OH group allowing more diverse structural conformations."
