#!/bin/bash
# Example script for designing RNA aptamers

# Example 1: Design RNA aptamer for DNA/RNA target
echo "=========================================="
echo "Example 1: RNA Aptamer for DNA Target"
echo "=========================================="
echo "Using DNA target (5zmc) to avoid PDB download issues"

python boltzdesign.py \
  --target_name 5zmc \
  --target_type dna \
  --pdb_target_ids C,D \
  --binder_type rna \
  --binder_id A \
  --length_min 30 \
  --length_max 70 \
  --num_inter_contacts 5 \
  --design_samples 2 \
  --gpu_id 0 \
  --suffix rna_example1


# Example 2: Design RNA aptamer for a small molecule (Theophylline)
echo "=========================================="
echo "Example 2: RNA Aptamer for Theophylline"
echo "=========================================="

python boltzdesign.py \
  --target_name theophylline_aptamer \
  --input_type custom \
  --target_type small_molecule \
  --custom_target_input "CN1C2=C(C(=O)N(C1=O)C)NC=N2" \
  --binder_type rna \
  --binder_id A \
  --length_min 30 \
  --length_max 60 \
  --num_inter_contacts 6 \
  --design_samples 2 \
  --gpu_id 0 \
  --suffix rna_theophylline_aptamer


# Example 3: Design RNA aptamer for custom protein sequence
echo "=========================================="
echo "Example 3: RNA Aptamer for Custom Protein"
echo "=========================================="
echo "Using custom protein sequence to avoid PDB download issues"

python boltzdesign.py \
  --target_name custom_vegf \
  --input_type custom \
  --target_type protein \
  --custom_target_input "APMAEGGGQNHHEVVKFMDVYQRSYCHPIETLVDIFQEYPDEIEYIFKPSCVPLMRCGGCCNDEGLECVPTEESNITMQIMRIKPHQGQHIGEMSFLQHNKCECRPKKDRARQENPCGPCSERRKHLFVQDPQTCKCSCKNTDSRCKARQLELNERTCRCDKPRR" \
  --binder_type rna \
  --binder_id A \
  --length_min 40 \
  --length_max 80 \
  --num_inter_contacts 7 \
  --design_samples 2 \
  --gpu_id 0 \
  --suffix rna_vegf_aptamer


# Example 4: Short RNA aptamer for metal ion (Mg2+)
echo "=========================================="
echo "Example 4: RNA Aptamer for Magnesium"
echo "=========================================="

python boltzdesign.py \
  --target_name mg_aptamer \
  --input_type custom \
  --target_type metal \
  --custom_target_input "MG" \
  --binder_type rna \
  --binder_id A \
  --length_min 20 \
  --length_max 40 \
  --num_inter_contacts 3 \
  --design_samples 2 \
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
