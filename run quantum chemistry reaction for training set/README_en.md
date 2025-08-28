## Project Overview

This directory contains scripts to run the same collinear triatomic system with Gaussian, CP2K, and Quantum ESPRESSO (QE), over a 71×71 grid of coordinates, and to parse outputs into spreadsheets.

### 🆕 Three-Atom Configuration Feature

**New Feature**: Now you can flexibly configure three different atom types in the three generate scripts!

- **Default Configuration**: `H-H-Ne` system (hydrogen-hydrogen-neon)
- **Custom Configuration**: Modify the `ATOM1`, `ATOM2`, `ATOM3` variables at the beginning of the scripts
- **Supported Atoms**: H, He, Li, Be, B, C, N, O, F, Ne, Na, Mg, Al, Si, P, S, Cl, Ar, K, Ca

**Configuration Example**:
```python
# Modify at the beginning of generate_*.py files
ATOM1 = 'C'    # First atom type
ATOM2 = 'H'    # Second atom type  
ATOM3 = 'O'    # Third atom type
```

### System and Grid
- Atomic positions (Å):
  - `{ATOM1}  (0.0, 0.0, 0.0)`
  - `{ATOM2}  (n,   0.0, 0.0)`
  - `{ATOM3}  (m,   0.0, 0.0)`
- Grid definition: `m = 0.5 + 0.05*i`, `n = -0.5 - 0.05*j`, with `i, j ∈ [0, 70]`. Each grid point is stored in a subdirectory named `{ATOM3}{m},{ATOM2}{n}`.

## Files

- Gaussian
  - `generate_gaussian_input.py`: Generate `.gjf` inputs in all subfolders (supports three-atom configuration)
  - `g09.sh`: Batch run Gaussian (`g16` by default; adjust as needed)
  - `read.py` or `read_gaussian.py`: Parse Gaussian outputs to Excel (supports three-atom configuration)

- CP2K
  - `generate_cp2k_input.py`: Generate `cp2k.inp` in all subfolders (supports three-atom configuration)
  - `cp2k.sh`: Batch run CP2K
  - `read_cp2k.py`: Parse `cp2k.out` to Excel (supports three-atom configuration)

- Quantum ESPRESSO
  - `generate_qe_input.py`: Generate `pw.in` in all subfolders (supports three-atom configuration)
  - `qe.sh`: Batch run QE (`pw.x`)
  - `read_qe.py`: Parse `pw.out` to Excel (supports three-atom configuration)

- 🆕 Configuration Files
  - `atom_config.py`: Unified atom configuration file, modify once to affect all scripts
  - `atom_config_examples.py`: Multiple atom combination configuration examples
  - `test_atom_config.py`: Test script to verify atom configuration is correct

## Requirements

- Python 3 (for generators and parsers)
- Disk space sufficient for 71×71 runs
- Gaussian (`g16`/`g09`), CP2K (`cp2k.psmp`), QE (`pw.x`) properly installed
- Pseudopotentials/atomic data available:
  - CP2K: `BASIS_MOLOPT`, `GTH_POTENTIALS` reachable by CP2K
  - QE: place UPF files under `./pseudo/`, matching names in `ATOMIC_SPECIES`

### 🆕 Atom Type Support

**Supported Atom Types**: H, He, Li, Be, B, C, N, O, F, Ne, Na, Mg, Al, Si, P, S, Cl, Ar, K, Ca

**Basis Set/Pseudopotential Requirements**:
- **Gaussian**: 6-311g** basis set supports most light elements
- **CP2K**: TZV2P-MOLOPT-GTH basis set and GTH-PBE pseudopotentials support all listed atoms
- **QE**: Need to prepare corresponding PBE pseudopotential files

## Generate Inputs

### 🆕 Atom Configuration Instructions

Before running any generate script, please check and configure the required atom types:

#### Method 1: Unified Configuration (Recommended)
1. **Modify `atom_config.py` file**:
   ```python
   ATOM1 = 'C'    # First atom type
   ATOM2 = 'H'    # Second atom type  
   ATOM3 = 'O'    # Third atom type
   ```
2. **All scripts will automatically use the same configuration**

#### Method 2: Individual Configuration
1. **Open the corresponding generate script** (e.g., `generate_gaussian_input.py`)
2. **Modify the atom configuration at the beginning**:
   ```python
   ATOM1 = 'H'    # First atom type
   ATOM2 = 'H'    # Second atom type  
   ATOM3 = 'Ne'   # Third atom type
   ```
3. **Ensure corresponding basis set/pseudopotential files exist**

#### 🆕 Method 3: Automatic Configuration Reading (Most Recommended)
**No need to repeat configuration!** Read scripts automatically read atom configuration from corresponding generate files:

- **`read_gaussian.py`** → Automatically reads configuration from `generate_gaussian_input.py`
- **`read_cp2k.py`** → Automatically reads configuration from `generate_cp2k_input.py`  
- **`read_qe.py`** → Automatically reads configuration from `generate_qe_input.py`
- **`read.py`** → Automatically reads configuration from `generate_gaussian_input.py`

**Usage**:
1. Only configure atom types once in generate files
2. When running read scripts, automatically use the same configuration
3. No need to repeat configuration in read files

**Important Notes**:
- **Gaussian**: Need to ensure basis set supports selected atom types
- **CP2K**: Need to ensure `BASIS_MOLOPT` and `GTH_POTENTIALS` contain selected atoms
- **QE**: Need to prepare corresponding pseudopotential files (`.UPF` format)

### Gaussian
```bash
python3 generate_gaussian_input.py
```

### CP2K
```bash
python3 generate_cp2k_input.py
```

### QE
```bash
python3 generate_qe_input.py
```

## Batch Runs

### Gaussian
```bash
bash g09.sh
```

### CP2K
```bash
bash cp2k.sh /path/to/cp2k.psmp
# or, if cp2k.psmp is in PATH
bash cp2k.sh
```

### QE
```bash
bash qe.sh /path/to/pw.x
# or, if pw.x is in PATH
bash qe.sh
```

## Parse Outputs to Excel

Each parser scans `{ATOM3}{m},{ATOM2}{n}` folders (m, n as defined above) and writes a spreadsheet with columns `x, y, z`, where `z` is total energy in Hartree (Ha). For Gaussian parsing, `read.py` is the original script; `read_gaussian.py` is a robust alternative.

- Gaussian (choose one of two scripts):
  - Original script (compatible with historical tables):
    ```bash
    python3 read.py
    ```
    Generates `{atom1}_{atom2}_{atom3}_input_force.xlsx` (columns x, y, z, where z is HF energy).
  - New parsing script (more robust regex matching):
    ```bash
    python3 read_gaussian.py
    ```
    Generates `{atom1}_{atom2}_{atom3}_gaussian_energy.xlsx`, failure list `{atom1}_{atom2}_{atom3}_gaussian_errors.xlsx`.

- CP2K:
```bash
python3 read_cp2k.py
# outputs: {atom1}_{atom2}_{atom3}_cp2k_energy.xlsx, {atom1}_{atom2}_{atom3}_cp2k_errors.xlsx
```

- QE:
```bash
python3 read_qe.py
# outputs: {atom1}_{atom2}_{atom3}_qe_energy.xlsx, {atom1}_{atom2}_{atom3}_qe_errors.xlsx
```

**🆕 Output File Naming Rules**:
- Format: `{atom1}_{atom2}_{atom3}_{software}_{type}.xlsx`
- Examples:
  - Default H-H-Ne: `h_h_ne_gaussian_energy.xlsx`
  - Custom C-H-O: `c_h_o_cp2k_energy.xlsx`
  - Custom Li-Na-K: `li_na_k_qe_errors.xlsx`

Notes:
- CP2K energy is read from lines like `ENERGY| Total FORCE_EVAL ( QS ) energy (a.u.): ...`.
- QE energy is read from lines like `!    total energy = ... Ry` and converted to Hartree by `E_Ha = E_Ry × 0.5`.

## Consistency

- Charge/spin: Gaussian route uses `1 2` (charge = +1, multiplicity = 2). CP2K and QE templates are set accordingly.
- Functional and numerics: templates use B3LYP-like settings. For large scans or faster turnaround, consider switching to PBE and adjusting cutoffs.
- Box/periodicity: Large cubic box (~30 Å) and Γ-point sampling approximate non-periodic conditions.

## Troubleshooting

- Missing data files: ensure CP2K basis/potentials and QE pseudopotentials are available and paths match.
- SCF convergence: reduce mixing or loosen thresholds, preconverge with a GGA first, or increase max iterations.
- Throughput: use your scheduler (SLURM/PBS) or GNU Parallel to spread subfolders across nodes/cores; mind I/O quotas.

## Directory Structure Example

```text
run-big/
  generate_gaussian_input.py  # Supports three-atom configuration
  g09.sh                      # Automatically detects Gaussian version
  read.py
  read_gaussian.py
  generate_cp2k_input.py      # Supports three-atom configuration
  cp2k.sh
  read_cp2k.py
  generate_qe_input.py         # Supports three-atom configuration
  qe.sh
  read_qe.py
  config_reader.py             # General configuration reading module
  atom_config.py               # Unified configuration file
  atom_config_examples.py      # Configuration examples
  test_atom_config.py          # Test script
  quick_start.py               # Quick start script
  pseudo/                      # QE pseudopotentials (need to prepare)
  
  # 🆕 New directory structure (recommended)
  H_H_Ne_gaussian_calculations/     # Main folder
    Ne0.5,H-0.5/                    # Calculation subfolder
      Ne0.5,H-0.5.gjf
    Ne0.55,H-0.55/
      Ne0.55,H-0.55.gjf
    ...
  
  H_H_Ne_cp2k_calculations/         # CP2K main folder
    Ne0.5,H-0.5/
      cp2k.inp
    ...
  
  H_H_Ne_qe_calculations/           # QE main folder
    Ne0.5,H-0.5/
      pw.in
    ...
```

**🆕 New Directory Structure Advantages**:
- **Clearer Organization**: Each software's calculation results are placed in independent main folders
- **Easy Management**: Can easily backup, move, or delete specific software's calculation results
- **Avoid Confusion**: Different software output files won't mix together
- **Convenient Analysis**: Can process different software results separately

**Directory Naming Rules**:
- **Main Folder Format**: `{ATOM1}_{ATOM2}_{ATOM3}_{software}_calculations`
- **Calculation Subfolder Format**: `{ATOM3}{m},{ATOM2}{n}`
- **Examples**:
  - Default H-H-Ne: `H_H_Ne_gaussian_calculations/`
  - Custom C-H-O: `C_H_O_cp2k_calculations/`
  - Custom Li-Na-K: `Li_Na_K_qe_calculations/`

## Notes

- The above scripts will generate 71×71 subdirectories by default, which is quite large; for testing only, please temporarily reduce the loop range.
- If you want me to provide scripts for merging and comparing three sets of results, please let me know the output format requirements.

### 🆕 Atom Configuration Notes

**Important Reminders**:
1. **After modifying atom types**, please ensure:
   - Corresponding basis set/pseudopotential files are available
   - Calculation parameters are suitable for the new atomic system
   - Charge and spin settings are reasonable

2. **Common Atom Combination Recommendations**:
   - **Light Element Systems**: H, He, Li, Be, B, C, N, O, F, Ne (recommended)
   - **Medium Elements**: Na, Mg, Al, Si, P, S, Cl, Ar (need to check basis set support)
   - **Heavy Elements**: K, Ca (may need to adjust calculation parameters)

3. **Special System Notes**:
   - **Metal Systems**: May need to adjust functionals and basis sets
   - **Heavy Elements**: Recommend using relativistic pseudopotentials
   - **Mixed Systems**: Ensure all atom types have corresponding basis sets/pseudopotentials

4. **Testing Recommendations**:
   - First test new atom combinations with small grids (e.g., 5×5)
   - Check if generated input files are correct
   - Verify if individual calculations can complete normally


