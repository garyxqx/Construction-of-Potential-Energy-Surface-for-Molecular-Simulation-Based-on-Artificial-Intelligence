## Project Description

This directory provides scripts for batch single-point energy/force calculations of the same triatomic system in three quantum chemistry software packages: Gaussian, CP2K, and Quantum ESPRESSO (QE).

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
- Atomic coordinates (Å):
  - `{ATOM1}  (0.0, 0.0, 0.0)`
  - `{ATOM2}  (n,   0.0, 0.0)`
  - `{ATOM3}  (m,   0.0, 0.0)`
- Grid: `m = 0.5 + 0.05*i`, `n = -0.5 - 0.05*j`, `i, j ∈ [0, 70]`, total 71×71 subdirectories.
- Directory naming: `{ATOM3}{m},{ATOM2}{n}`

## File List

- Gaussian (existing)
  - `generate_gaussian_input.py`: Batch generate `.gjf` files (supports three-atom configuration)
  - `g09.sh`: Batch run `g16` (or change to `g09`)
  - `read.py`: Extract energy (HF) from Gaussian output, write to `input_force.xlsx` (supports three-atom configuration)
  - `read_gaussian.py`: Parse Gaussian `*.out`, output `gaussian_energy.xlsx`, `gaussian_errors.xlsx` (supports three-atom configuration)

- CP2K (new)
  - `generate_cp2k_input.py`: Batch generate `cp2k.inp` (supports three-atom configuration)
  - `cp2k.sh`: Batch call `cp2k.psmp` (or executable in your environment)
  - `read_cp2k.py`: Parse `cp2k.out`, output `cp2k_energy.xlsx`, `cp2k_errors.xlsx` (supports three-atom configuration)

- Quantum ESPRESSO (new)
  - `generate_qe_input.py`: Batch generate `pw.in` (supports three-atom configuration)
  - `qe.sh`: Batch call `pw.x`
  - `read_qe.py`: Parse `pw.out`, output `qe_energy.xlsx`, `qe_errors.xlsx` (supports three-atom configuration)

- 🆕 Configuration Files
  - `atom_config.py`: Unified atom configuration file, modify once to affect all scripts
  - `atom_config_examples.py`: Multiple atom combination configuration examples
  - `test_atom_config.py`: Test script to verify atom configuration is correct

## Environment Setup

### Common Requirements
- Python 3 (for input generation)
- Sufficient disk space (71×71 grid will generate many subdirectories and output files)

### 🆕 Atom Type Support

**Supported Atom Types**: H, He, Li, Be, B, C, N, O, F, Ne, Na, Mg, Al, Si, P, S, Cl, Ar, K, Ca

**Basis Set/Pseudopotential Requirements**:
- **Gaussian**: 6-311g** basis set supports most light elements
- **CP2K**: TZV2P-MOLOPT-GTH basis set and GTH-PBE pseudopotentials support all listed atoms
- **QE**: Need to prepare corresponding PBE pseudopotential files

### Gaussian
- `g16` or `g09` installed, and `GAUSS_SCRDIR` set
- Ensure basis set supports selected atom types

### CP2K
- CP2K installed (recommend parallel version `cp2k.psmp`)
- Data files visible:
  - `BASIS_MOLOPT` (common path example: `$CP2K_DATA/BASIS_MOLOPT`)
  - `GTH_POTENTIALS` (common path example: `$CP2K_DATA/GTH_POTENTIALS`)
- Ensure basis set and pseudopotential files contain selected atom types

### Quantum ESPRESSO
- QE installed (`pw.x`)
- Prepare `pseudo/` pseudopotential files in this directory (filenames must match those in `pw.in`)
- Default pseudopotential filename format: `{atom_symbol}.pbe-n-rrkjus_psl.1.0.0.UPF`
- For custom pseudopotentials, modify the `PSEUDO_FILES` dictionary in the script

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
Each subdirectory contains `cp2k.inp`.

### Quantum ESPRESSO
```bash
python3 generate_qe_input.py
```
Each subdirectory contains `pw.in`.

## Batch Execution

### Gaussian
```bash
bash g09.sh
```
Script traverses `*/*.gjf`, output written to corresponding `.out`.

### CP2K
```bash
# Specify executable (optional)
bash cp2k.sh /path/to/cp2k.psmp
# Or use cp2k.psmp in PATH
bash cp2k.sh
```
Output written to `cp2k.out` in each subdirectory.

Parallel hint: If you need to use `mpirun`, you can edit the script to replace the executable with `mpirun -np N cp2k.psmp`, or explicitly use `mpirun`/`srun` in the job script.

### Quantum ESPRESSO
```bash
# Specify executable (optional)
bash qe.sh /path/to/pw.x
# Or use pw.x in PATH
bash qe.sh
```
Output written to `pw.out` in each subdirectory.

Parallel hint: Same as above, if you need `mpirun -np N pw.x`, recommend writing the complete command directly in the job script, or modify `qe.sh`, to avoid passing command strings with spaces in the script.

## Result Extraction and Comparison

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
  ```
  Generates `{atom1}_{atom2}_{atom3}_cp2k_energy.xlsx`, `{atom1}_{atom2}_{atom3}_cp2k_errors.xlsx`.

- Quantum ESPRESSO:
  ```bash
  python3 read_qe.py
  ```
  Generates `{atom1}_{atom2}_{atom3}_qe_energy.xlsx`, `{atom1}_{atom2}_{atom3}_qe_errors.xlsx` (energy converted from Ry to Ha, coefficient 0.5).

**🆕 Output File Naming Rules**:
- Format: `{atom1}_{atom2}_{atom3}_{software}_{type}.xlsx`
- Examples:
  - Default H-H-Ne: `h_h_ne_gaussian_energy.xlsx`
  - Custom C-H-O: `c_h_o_cp2k_energy.xlsx`
  - Custom Li-Na-K: `li_na_k_qe_errors.xlsx`

If you need to summarize three sets of energies into one Excel for comparison, let me know the required table header format, and I can add a merge script.

## Important Parameters and Consistency Notes

- Charge/Spin:
  - Gaussian input: `1 2` (charge=+1, multiplicity=2).
  - CP2K: `CHARGE 1`, `UKS TRUE`, `MULTIPLICITY 2`.
  - QE: `tot_charge = 1`, `nspin = 2`, for `H` set `starting_magnetization(1) = 1.0` (according to `ATOMIC_SPECIES` order).

- Functional/Numerical Parameters:
  - Gaussian: `# sp b3lyp/6-311g** Force nosymm scf=(qc)`.
  - CP2K: Template uses `B3LYP` (with `&HF` fraction), basis set `TZV2P-MOLOPT-GTH`, pseudopotential `GTH-PBE`, `CUTOFF 600`, `REL_CUTOFF 60` (can be adjusted up/down as needed).
  - QE: Template writes `input_dft='B3LYP'`, `ecutwfc=80`, `ecutrho=640`. Hybrid functionals are expensive in plane-wave framework, for fast scanning or better pseudopotential matching, can change to `PBE` and adjust `ecutwfc/ecutrho` accordingly.

- Box/Periodicity:
  - CP2K: `ABC 30 30 30`, `PERIODIC NONE`.
  - QE: `ibrav=0` + 30 Å cubic box + Γ-point approximation non-periodic.

For strict comparison with Gaussian, please unify: functional, basis set/pseudopotential, SCF convergence threshold and numerical parameters, and ensure sufficiently large box to avoid mirror interactions.

## Common Issues (FAQ)

- Cannot find pseudopotential/basis set files:
  - CP2K: Check `BASIS_SET_FILE_NAME`, `POTENTIAL_FILE_NAME` paths; ensure environment variables or absolute paths are correct.
  - QE: Ensure pseudopotentials are in `pseudo/` and filenames match those in `ATOMIC_SPECIES`.

- SCF not converging:
  - Reduce `mixing_beta` (QE), increase `MAX_SCF`/`EPS_SCF` (CP2K), or give better initial guess; try changing to GGA first to converge then switch back to hybrid functional.

- Batch parallelization:
  - To run multiple subdirectories in parallel, can combine with cluster scheduling system (SLURM/PBS) or `GNU parallel`. Note I/O and disk quotas.

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


