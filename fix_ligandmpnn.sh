#!/bin/bash
set -e

echo "🔧 Fixing LigandMPNN model download..."
echo ""

# Remove empty files
echo "🗑️  Removing empty model files..."
find LigandMPNN/model_params -name "*.pt" -size 0 -delete

# Re-download models
echo "⬇️  Downloading LigandMPNN models (this may take several minutes)..."
cd LigandMPNN

# Download with progress
echo ""
echo "Downloading ProteinMPNN models..."
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_002.pt -O model_params/proteinmpnn_v_48_002.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_010.pt -O model_params/proteinmpnn_v_48_010.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_020.pt -O model_params/proteinmpnn_v_48_020.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/proteinmpnn_v_48_030.pt -O model_params/proteinmpnn_v_48_030.pt

echo ""
echo "Downloading LigandMPNN models..."
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_005_25.pt -O model_params/ligandmpnn_v_32_005_25.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_010_25.pt -O model_params/ligandmpnn_v_32_010_25.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_020_25.pt -O model_params/ligandmpnn_v_32_020_25.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/ligandmpnn_v_32_030_25.pt -O model_params/ligandmpnn_v_32_030_25.pt

echo ""
echo "Downloading Membrane MPNN models..."
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/per_residue_label_membrane_mpnn_v_48_020.pt -O model_params/per_residue_label_membrane_mpnn_v_48_020.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/global_label_membrane_mpnn_v_48_020.pt -O model_params/global_label_membrane_mpnn_v_48_020.pt

echo ""
echo "Downloading SolubleMPNN models..."
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/solublempnn_v_48_002.pt -O model_params/solublempnn_v_48_002.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/solublempnn_v_48_010.pt -O model_params/solublempnn_v_48_010.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/solublempnn_v_48_020.pt -O model_params/solublempnn_v_48_020.pt
wget --progress=bar:force https://files.ipd.uw.edu/pub/ligandmpnn/solublempnn_v_48_030.pt -O model_params/solublempnn_v_48_030.pt

cd ..

echo ""
echo "✅ LigandMPNN models downloaded successfully!"
echo ""
echo "Run verification again:"
echo "  bash verify_installation.sh"
