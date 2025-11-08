# 🔧 Troubleshooting Guide - Aptamer Design

## Common Issues and Solutions

### Issue 1: SSL/Network Errors When Downloading PDB Files

**Error Message:**
```
ERROR: Failed to download 1HAO.pdb: HTTPSConnectionPool...SSLError
KeyError: 'A'
```

**Root Cause:**
- SSL certificate verification issues with RCSB PDB server
- Network connectivity problems
- Firewall blocking HTTPS connections

**Solutions:**

#### Option A: Use Local PDB Files (Recommended)
```bash
# 1. Manually download PDB file from https://www.rcsb.org/
# 2. Use --pdb_path parameter

python boltzdesign.py \
  --target_name 1HAO \
  --pdb_path /path/to/1hao.pdb \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type dna \
  --length_min 30 \
  --length_max 60
```

#### Option B: Use Custom Sequence Input
```bash
# Provide protein sequence directly
python boltzdesign.py \
  --target_name my_protein \
  --input_type custom \
  --target_type protein \
  --custom_target_input "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQF..." \
  --binder_type dna \
  --length_min 30 \
  --length_max 60
```

#### Option C: Use wget/curl to Download PDB First
```bash
# Download manually
wget https://files.rcsb.org/download/1HAO.pdb -O inputs/protein_1HAO_dna/PDB/1HAO.pdb

# Then run without downloading
python boltzdesign.py \
  --target_name 1HAO \
  --pdb_path inputs/protein_1HAO_dna/PDB/1HAO.pdb \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type dna
```

---

### Issue 2: Invalid PDB Identifier for Custom Targets

**Error Message:**
```
OSError: ATP_aptamer is not a valid filename or a valid PDB identifier.
```

**Root Cause:**
- Using custom target name without specifying `--input_type custom`
- Code defaults to `--input_type pdb` and tries to download from RCSB

**Solution:**
```bash
# ❌ WRONG - Missing --input_type custom
python boltzdesign.py \
  --target_name ATP_aptamer \
  --target_type small_molecule \
  --custom_target_input "SMILES_STRING"

# ✅ CORRECT - Add --input_type custom
python boltzdesign.py \
  --target_name ATP_aptamer \
  --input_type custom \
  --target_type small_molecule \
  --custom_target_input "C1=NC(=C2C(=N1)N(C=N2)C3C(C(C(O3)COP(=O)(O)OP(=O)(O)OP(=O)(O)O)O)O)N" \
  --binder_type dna
```

**Rule:** Always use `--input_type custom` when:
- Target name is not a PDB ID
- Using `--custom_target_input`
- Providing SMILES strings or custom sequences

---

### Issue 3: KeyError When Accessing Chain IDs

**Error Message:**
```
KeyError: 'A'
```

**Root Cause:**
- PDB file download failed (empty chain_sequences dict)
- Wrong chain ID specified
- PDB file doesn't contain the specified chain

**Solutions:**

#### Check Available Chains
```bash
# First, examine your PDB file
grep "^ATOM" your_file.pdb | awk '{print $5}' | sort -u

# Or use online PDB viewer to check chain IDs
```

#### Use Correct Chain IDs
```bash
# Example: 5zmc has chains A, B, C, D
python boltzdesign.py \
  --target_name 5zmc \
  --target_type dna \
  --pdb_target_ids C,D \  # ✅ Correct chains
  --binder_type dna
```

---

### Issue 4: CUDA Out of Memory

**Error Message:**
```
RuntimeError: CUDA out of memory
```

**Solutions:**

#### Reduce Design Samples
```bash
# Reduce from 20 to 2-5
--design_samples 2
```

#### Reduce Sequence Length
```bash
# Shorter aptamers use less memory
--length_min 20
--length_max 40
```

#### Use CPU (Slower)
```bash
# Force CPU usage
export CUDA_VISIBLE_DEVICES=""
```

---

### Issue 5: LigandMPNN/ProteinMPNN Errors

**Error Message:**
```
FileNotFoundError: LigandMPNN checkpoint file not found!
```

**Solution:**
```bash
# Re-run LigandMPNN setup
cd LigandMPNN
bash get_model_params.sh "./model_params"
cd ..
```

---

## Quick Fixes Checklist

### For Small Molecule Targets
- [ ] Add `--input_type custom`
- [ ] Provide valid SMILES in `--custom_target_input`
- [ ] Set appropriate `--num_inter_contacts` (6-10)

### For Protein Targets with Network Issues
- [ ] Download PDB manually
- [ ] Use `--pdb_path` to specify local file
- [ ] OR use `--input_type custom` with sequence

### For Metal Ion Targets
- [ ] Add `--input_type custom`
- [ ] Use proper metal symbol (MG, ZN, CU, etc.)
- [ ] Set `--num_inter_contacts` to coordination number

### For DNA/RNA Targets
- [ ] Check chain IDs in PDB file first
- [ ] Use comma-separated chain IDs
- [ ] Ensure PDB download succeeded

---

## Example Working Commands

### DNA Aptamer for DNA Target (Works Out of Box)
```bash
python boltzdesign.py \
  --target_name 5zmc \
  --target_type dna \
  --pdb_target_ids C,D \
  --binder_type dna \
  --binder_id A \
  --length_min 30 \
  --length_max 60 \
  --design_samples 2 \
  --gpu_id 0
```

### RNA Aptamer for Custom Small Molecule
```bash
python boltzdesign.py \
  --target_name caffeine \
  --input_type custom \
  --target_type small_molecule \
  --custom_target_input "CN1C=NC2=C1C(=O)N(C(=O)N2C)C" \
  --binder_type rna \
  --binder_id A \
  --length_min 25 \
  --length_max 50 \
  --design_samples 2
```

### DNA Aptamer for Custom Protein Sequence
```bash
python boltzdesign.py \
  --target_name my_protein \
  --input_type custom \
  --target_type protein \
  --custom_target_input "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEK" \
  --binder_type dna \
  --binder_id A \
  --length_min 30 \
  --length_max 60 \
  --design_samples 2
```

---

## Debugging Tips

### Enable Verbose Logging
```bash
# Add to your command
--verbose True
```

### Check Input YAML
```bash
# Examine generated YAML file
cat inputs/<target_type>_<target>_<suffix>/yaml/<target_name>.yaml
```

### Verify GPU Availability
```bash
python -c "import torch; print(torch.cuda.is_available())"
python -c "import torch; print(torch.cuda.device_count())"
```

### Test with Minimal Example
```bash
# Simplest possible command (uses DNA target that works)
python boltzdesign.py \
  --target_name 5zmc \
  --target_type dna \
  --pdb_target_ids C,D \
  --binder_type dna \
  --design_samples 1 \
  --length_min 30 \
  --length_max 40
```

---

## Getting Help

If issues persist:

1. **Check the logs**: Look for detailed error messages
2. **Verify inputs**: Double-check all parameters
3. **Test connectivity**: Try downloading PDB manually
4. **Update environment**: Ensure all dependencies are installed
5. **Report issue**: Open a GitHub issue with:
   - Full command used
   - Complete error message
   - Environment details (Python version, CUDA version, etc.)

---

## Known Limitations

1. **Network dependency**: PDB downloads require internet connection
2. **SSL issues**: Some networks block HTTPS to RCSB
3. **Memory constraints**: Large designs need significant GPU memory
4. **Experimental validation**: Computational designs must be validated experimentally

---

**Last Updated:** 2025-01-08
