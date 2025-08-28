import os
import re
import pandas as pd

# Use general configuration reading module
try:
    from config_reader import get_qe_config, get_output_filename
    ATOM1, ATOM2, ATOM3 = get_qe_config()
except ImportError:
    # If unable to import config module, use default configuration
    print("⚠️  Unable to import config_reader module, using default configuration")
    ATOM1, ATOM2, ATOM3 = 'H', 'H', 'Ne'

# QE standard SCF output energy line
RY_ENERGY_PATTERN = re.compile(r"!\s+total energy\s*=\s*([-0-9\.Ee\+]+)\s+Ry")


def extract_energy_from_qe(output_path: str):
    try:
        with open(output_path, "r") as f:
            content = f.read()
    except FileNotFoundError:
        return None

    if re.search(r"error|convergence NOT achieved", content, flags=re.IGNORECASE):
        return None

    matches = RY_ENERGY_PATTERN.findall(content)
    if matches:
        e_ry = float(matches[-1])
        e_ha = e_ry * 0.5  # 1 Ha = 2 Ry
        return e_ha

    # Alternative: some modules only output "total energy = ... Ry" (without !)
    alt = re.findall(r"total energy\s*=\s*([-0-9\.Ee\+]+)\s+Ry", content)
    if alt:
        e_ry = float(alt[-1])
        return e_ry * 0.5

    return None


def main():
    data_rows = []
    error_rows = []

    for i in range(71):
        for j in range(71):
            m = round(0.5 + 0.05 * i, 6)
            n = round(-0.5 - 0.05 * j, 6)
            # Use dynamic directory naming to match new atom configuration
            dirname = f"{ATOM3}{m},{ATOM2}{n}"
            out_path = os.path.join(dirname, "pw.out")
            
            energy = extract_energy_from_qe(out_path)
            if energy is None:
                error_rows.append((m, n))
                print(f"Error: {out_path}")
            else:
                data_rows.append((m, -n, energy))
                print(f"From {out_path}: E(Ha)={energy}")

    if data_rows:
        df = pd.DataFrame(data_rows, columns=["x", "y", "z"])  # z is energy (Hartree)
        try:
            output_filename = get_output_filename(ATOM1, ATOM2, ATOM3, "qe", "energy")
        except:
            output_filename = f"{ATOM1.lower()}_{ATOM2.lower()}_{ATOM3.lower()}_qe_energy.xlsx"
        df.to_excel(output_filename, index=False)
        print(f"Energy data saved to: {output_filename}")

    if error_rows:
        dfe = pd.DataFrame(error_rows, columns=["x", "y"])  # Coordinate pairs (failed)
        try:
            error_filename = get_output_filename(ATOM1, ATOM2, ATOM3, "qe", "errors")
        except:
            error_filename = f"{ATOM1.lower()}_{ATOM2.lower()}_{ATOM3.lower()}_qe_errors.xlsx"
        df.to_excel(error_filename, index=False)
        print(f"Error data saved to: {error_filename}")

    print(f"Processing completed! Total processed {len(data_rows)} successful files, {len(error_rows)} failed files")


if __name__ == "__main__":
    main()


