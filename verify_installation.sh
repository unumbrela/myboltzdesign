#!/bin/bash

echo "🔍 Verifying BoltzDesign Installation..."
echo ""

# Check conda environment
echo "1️⃣ Checking conda environment..."
if conda env list | grep -q "boltz_design"; then
    echo "✅ boltz_design environment exists"
else
    echo "❌ boltz_design environment not found"
fi
echo ""

# Check Boltz installation
echo "2️⃣ Checking Boltz installation..."
if conda run -n boltz_design python -c "import boltz" 2>/dev/null; then
    echo "✅ Boltz is installed"
else
    echo "❌ Boltz import failed"
fi
echo ""

# Check PyRosetta
echo "3️⃣ Checking PyRosetta..."
if conda run -n boltz_design python -c "import pyrosetta" 2>/dev/null; then
    echo "✅ PyRosetta is installed"
else
    echo "⚠️  PyRosetta not found (optional)"
fi
echo ""

# Check Boltz weights
echo "4️⃣ Checking Boltz weights..."
if [ -f ~/.boltz/boltz1_conf.ckpt ]; then
    SIZE=$(du -h ~/.boltz/boltz1_conf.ckpt | cut -f1)
    echo "✅ Boltz weights downloaded ($SIZE)"
else
    echo "❌ Boltz weights not found"
fi
echo ""

# Check LigandMPNN models
echo "5️⃣ Checking LigandMPNN models..."
MODEL_COUNT=$(find LigandMPNN/model_params -name "*.pt" -size +1M 2>/dev/null | wc -l)
TOTAL_COUNT=$(find LigandMPNN/model_params -name "*.pt" 2>/dev/null | wc -l)
if [ "$MODEL_COUNT" -gt 0 ]; then
    echo "✅ LigandMPNN models: $MODEL_COUNT/$TOTAL_COUNT downloaded successfully"
else
    echo "❌ LigandMPNN models not downloaded (0/$TOTAL_COUNT)"
    echo "   Files exist but are empty (0 bytes)"
fi
echo ""

# Check DAlphaBall
echo "6️⃣ Checking DAlphaBall..."
if [ -x "boltzdesign/DAlphaBall.gcc" ]; then
    echo "✅ DAlphaBall.gcc is executable"
else
    echo "❌ DAlphaBall.gcc not executable"
fi
echo ""

# Summary
echo "================================"
echo "📊 Installation Summary"
echo "================================"
if [ "$MODEL_COUNT" -eq 0 ]; then
    echo "⚠️  Installation INCOMPLETE - LigandMPNN models need to be downloaded"
    echo ""
    echo "To fix, run:"
    echo "  bash fix_ligandmpnn.sh"
else
    echo "✅ Installation appears complete!"
    echo ""
    echo "To use BoltzDesign, activate the environment:"
    echo "  conda activate boltz_design"
fi
