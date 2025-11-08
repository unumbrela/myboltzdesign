# 🧬 Aptamer Design Guide

## Overview

BoltzDesign1 now supports **aptamer design** - designing DNA and RNA oligonucleotides that specifically bind to target molecules (proteins, small molecules, nucleic acids, or metal ions).

This guide covers:
- What are aptamers
- How to design DNA/RNA aptamers using BoltzDesign1
- Best practices and optimization tips
- Example use cases

---

## 📖 What are Aptamers?

**Aptamers** are short single-stranded DNA or RNA oligonucleotides (typically 20-100 nucleotides) that fold into specific 3D structures to bind target molecules with high affinity and specificity.

### Key Features:
- **High specificity**: Can distinguish between closely related molecules
- **Wide target range**: Proteins, small molecules, cells, viruses, metal ions
- **Stable**: Can be chemically synthesized and modified
- **Non-immunogenic**: Unlike antibodies, minimal immune response
- **Reusable**: Can be denatured and renatured multiple times

### Applications:
- Diagnostics (biosensors, disease markers)
- Therapeutics (drug delivery, blocking protein function)
- Research tools (affinity purification, imaging)
- Industrial applications (food safety, environmental monitoring)

---

## 🚀 Quick Start

### DNA Aptamer for Protein Target

```bash
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
  --suffix dna_thrombin_apt
```

### RNA Aptamer for Small Molecule

```bash
python boltzdesign.py \
  --target_name ATP_aptamer \
  --target_type small_molecule \
  --custom_target_input "C1=NC(=C2C(=N1)N(C=N2)C3C(C(C(O3)COP(=O)(O)OP(=O)(O)OP(=O)(O)O)O)O)N" \
  --binder_type rna \
  --binder_id A \
  --length_min 25 \
  --length_max 50 \
  --num_inter_contacts 6 \
  --design_samples 15 \
  --gpu_id 0 \
  --suffix rna_atp_apt
```

---

## ⚙️ Key Parameters for Aptamer Design

### Binder Type
```bash
--binder_type [dna|rna|peptide]
```
- **dna**: DNA aptamer design
- **rna**: RNA aptamer design (typically higher affinity due to 2'-OH group)
- **peptide**: Short peptide binder

### Length Range
```bash
--length_min 30
--length_max 60
```
- **DNA aptamers**: Typically 20-80 nucleotides
- **RNA aptamers**: Typically 20-100 nucleotides (can be longer for complex structures)
- **Shorter aptamers** (20-40 nt): Easier to synthesize, lower cost
- **Longer aptamers** (50-100 nt): More complex structures, potentially higher affinity

### Interaction Parameters
```bash
--num_inter_contacts 5      # Number of contact points with target
--inter_chain_cutoff 18     # Distance cutoff for contacts (Angstroms)
```
- **Increase num_inter_contacts** for:
  - Larger target molecules
  - Higher specificity requirements
  - Small molecule targets (need more contacts for stability)
- **Typical values**:
  - Protein targets: 4-7 contacts
  - Small molecules: 6-10 contacts
  - Metal ions: 3-4 contacts (coordination number)

### Learning Rate
```bash
--learning_rate 0.15
--learning_rate_pre 1.2
```
- Aptamer configs use **higher learning rates** than protein design
- Nucleic acid sequence space is smaller, allowing faster optimization

---

## 🎯 Design Strategies for Different Targets

### 1. Protein Targets

**Example: VEGF, Thrombin, PDGF**

```bash
python boltzdesign.py \
  --target_name 1VPF \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type rna \
  --length_min 40 \
  --length_max 80 \
  --num_inter_contacts 6 \
  --design_samples 20
```

**Tips:**
- Use **RNA** for therapeutic applications (e.g., Macugen for AMD)
- Target **protein pockets** or **binding sites** using `--contact_residues`
- Longer aptamers (50-80 nt) for large proteins

### 2. Small Molecule Targets

**Example: ATP, Theophylline, Cocaine**

```bash
python boltzdesign.py \
  --target_name theophylline \
  --target_type small_molecule \
  --custom_target_input "CN1C2=C(C(=O)N(C1=O)C)NC=N2" \
  --binder_type rna \
  --length_min 30 \
  --length_max 60 \
  --num_inter_contacts 8
```

**Tips:**
- **Higher num_inter_contacts** (6-10) for small molecules
- Shorter aptamers (30-50 nt) often sufficient
- RNA preferred for small molecules (2'-OH helps binding)

### 3. Metal Ions

**Example: Mg2+, Zn2+, Cu2+**

```bash
python boltzdesign.py \
  --target_name zinc \
  --target_type metal \
  --custom_target_input "ZN" \
  --binder_type rna \
  --length_min 20 \
  --length_max 40 \
  --num_inter_contacts 4  # Match coordination number
```

**Tips:**
- Set `num_inter_contacts` to match **coordination number**
- Short aptamers (20-40 nt) usually sufficient
- RNA strongly preferred (phosphate backbone coordinates metals)

### 4. DNA/RNA Targets

**Example: DNA sequence recognition**

```bash
python boltzdesign.py \
  --target_name telomere \
  --target_type dna \
  --custom_target_input "TTAGGG" \
  --binder_type rna \
  --length_min 25 \
  --length_max 50
```

**Tips:**
- Design complementary or structure-recognizing sequences
- Consider Watson-Crick base pairing

---

## 🔧 Optimization Tips

### 1. Increase Design Samples
```bash
--design_samples 20    # Generate more candidates
```
More samples → higher chance of finding high-affinity aptamers

### 2. Adjust Iteration Steps
```bash
--soft_iteration 100   # Increased for aptamers (default: 75)
--temp_iteration 60    # More annealing steps
```
Aptamer configs already have optimized iteration counts

### 3. Control Secondary Structure
For hairpin structures or specific folds, future versions will support:
```bash
--structure_type hairpin     # Coming soon!
```

### 4. GC Content Optimization
Optimal GC content is 40-60% for stability:
- Too low (<30%): Unstable, poor folding
- Too high (>70%): Difficult to synthesize, aggregation

The aptamer_utils.py module includes GC content optimization.

### 5. Avoid Homopolymers
Long runs of same base (e.g., "GGGGGG") cause:
- Synthesis failures
- Non-specific binding
- Aggregation

Built-in homopolymer penalties prevent this.

---

## 📊 Output and Analysis

### Design Outputs

After running BoltzDesign, you'll find:

```
outputs/<target_type>_<target>_<suffix>/
├── results_final/              # Initial designs from BoltzDesign
│   ├── *.cif                   # Structure files
│   └── rmsd_results.csv        # Quality metrics
├── pdb/                        # PDB format structures
├── ligandmpnn_cutoff_4/        # After sequence optimization
│   ├── 01_lmpnn_redesigned/
│   └── 03_af_pdb_success/      # ✅ HIGH-CONFIDENCE DESIGNS
│       ├── *.pdb
│       └── high_iptm_confidence_scores.csv
```

### Quality Metrics

**High-confidence aptamers** should have:
- **iPTM > 0.6**: Good interface prediction
- **pLDDT > 0.7**: High structure confidence
- **Low RMSD** (<5 Å): Stable binding pose

### Validation

Check `high_iptm_confidence_scores.csv`:

```csv
file,iptm,plddt,rmsd
aptamer_length_45_model_0.cif,0.78,0.82,3.2
aptamer_length_52_model_0.cif,0.72,0.79,4.1
```

---

## 🧪 Experimental Validation

After computational design, validate experimentally:

### 1. Synthesis
- Order aptamers from oligo synthesis companies
- Consider **chemical modifications** for stability:
  - 2'-F (2'-fluoro) for RNA
  - Phosphorothioate linkages
  - 3' inverted dT cap

### 2. Binding Assays
- **SPR** (Surface Plasmon Resonance): Measure KD
- **ITC** (Isothermal Titration Calorimetry): Thermodynamics
- **EMSA** (Electrophoretic Mobility Shift): Binding confirmation
- **Fluorescence polarization**: High-throughput screening

### 3. Structure Validation
- **SHAPE** (Selective 2'-Hydroxyl Acylation): RNA structure
- **DMS footprinting**: Nucleotide accessibility
- **X-ray crystallography** or **Cryo-EM**: Atomic structure

### 4. Functional Assays
- Cell-based assays for therapeutic aptamers
- Biosensor testing for diagnostic aptamers

---

## 📚 Advanced Features

### Using Aptamer-Specific Loss Functions

The `aptamer_utils.py` module provides specialized optimization:

```python
from boltzdesign.aptamer_utils import (
    aptamer_design_loss,
    validate_aptamer_sequence,
    calculate_tm
)

# Calculate combined aptamer loss
total_loss, loss_components = aptamer_design_loss(
    logits=sequence_logits,
    target_gc=0.5,
    structure_type='hairpin',
    weights={
        'gc_content': 0.1,
        'complexity': 0.2,
        'homopolymer': 0.3,
        'structure': 0.15
    }
)
```

### Future Enhancements

Coming soon:
- [ ] RNA secondary structure prediction integration
- [ ] SELEX simulation (iterative selection)
- [ ] Specificity optimization (positive/negative selection)
- [ ] Modified nucleotide support
- [ ] Multimer aptamer design

---

## 🎓 Learning Resources

### Aptamer Basics
- [Aptamer Wiki](https://en.wikipedia.org/wiki/Aptamer)
- [The Aptamer Handbook](https://www.aptamergroup.co.uk/)

### SELEX Process
- Ellington & Szostak (1990) - Original SELEX paper
- Tuerk & Gold (1990) - Systematic Evolution of Ligands

### Aptamer Databases
- [Aptagen Database](https://www.aptagen.com/aptamer-database/)
- [APTAbase](http://aptabase.unl.edu/)

### Therapeutic Aptamers
- Macugen (Pegaptanib) - AMD treatment (first FDA-approved aptamer)
- AS1411 - Cancer therapy (clinical trials)

---

## 💡 Example Projects

### 1. Diagnostic Biosensor
**Goal**: Detect COVID-19 spike protein

```bash
python boltzdesign.py \
  --target_name 6VXX \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type rna \
  --length_min 40 \
  --length_max 70 \
  --num_inter_contacts 7 \
  --design_samples 30
```

### 2. Drug Delivery
**Goal**: Target aptamer for cancer cell receptor

```bash
python boltzdesign.py \
  --target_name 1N8Z \
  --target_type protein \
  --pdb_target_ids A \
  --binder_type rna \
  --length_min 50 \
  --length_max 80 \
  --num_inter_contacts 6
```

### 3. Environmental Monitoring
**Goal**: Detect heavy metal contamination

```bash
python boltzdesign.py \
  --target_name lead \
  --target_type metal \
  --custom_target_input "PB" \
  --binder_type dna \
  --length_min 25 \
  --length_max 45 \
  --num_inter_contacts 4
```

---

## ⚠️ Important Notes

1. **Computational designs require experimental validation**
   - Not all designs will work in vitro
   - Typically need to test 10-20 candidates

2. **Consider experimental conditions**
   - Buffer composition (pH, salt concentration)
   - Temperature
   - Target concentration

3. **Chemical modifications may be needed**
   - Nuclease resistance
   - Enhanced binding affinity
   - Reduced immunogenicity

4. **Aptamers vs Antibodies**
   - Aptamers: Easier to produce, more stable, non-immunogenic
   - Antibodies: Larger binding surface, well-established protocols

---

## 📧 Support

For questions or issues with aptamer design:
- GitHub Issues: https://github.com/yehlincho/BoltzDesign1/issues
- Email: yehlin@mit.edu

---

## 📖 Citation

If you use BoltzDesign1 for aptamer design in your research, please cite:

```
@article{cho2025boltzdesign1,
  title={Boltzdesign1: Inverting all-atom structure prediction model for generalized biomolecular binder design},
  author={Cho, Yehlin and Pacesa, Martin and Zhang, Zhidian and Correia, Bruno E and Ovchinnikov, Sergey},
  journal={bioRxiv},
  year={2025},
  publisher={Cold Spring Harbor Laboratory}
}
```

---

**Happy Aptamer Designing! 🧬✨**
