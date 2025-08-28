import os
import re
import pandas as pd

# Use general configuration reading module
try:
    from config_reader import get_cp2k_config, get_output_filename
    ATOM1, ATOM2, ATOM3 = get_cp2k_config()
except ImportError:
    # If unable to import config module, use default configuration
    print("⚠️  Unable to import config_reader module, using default configuration")
    ATOM1, ATOM2, ATOM3 = 'H', 'H', 'Ne'

ENERGY_PATTERN = re.compile(
    r"ENERGY\|\s*Total FORCE_EVAL.*?energy \(a\.u\.\):\s*([-0-9\.Ee\+]+)")


def extract_energy_from_cp2k(output_path: str):
    try:
        with open(output_path, "r") as f:
            content = f.read()
    except FileNotFoundError:
        return None

    if re.search(r"ERROR", content, flags=re.IGNORECASE):
        return None

    matches = ENERGY_PATTERN.findall(content)
    if matches:
        return float(matches[-1])  # Hartree

    # Alternative keywords (some versions may differ)
    alt_matches = re.findall(r"Total energy:\s*([-0-9\.Ee\+]+)\s*a\.u\.\.", content)
    if alt_matches:
        return float(alt_matches[-1])

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
            out_path = os.path.join(dirname, "cp2k.out")
            
            energy = extract_energy_from_cp2k(out_path)
            if energy is None:
                error_rows.append((m, n))
                print(f"Error: {out_path}")
            else:
                data_rows.append((m, -n, energy))
                print(f"From {out_path}: E(Ha)={energy}")

    if data_rows:
        df = pd.DataFrame(data_rows, columns=["x", "y", "z"])  # z is energy (Hartree)
        try:
            output_filename = get_output_filename(ATOM1, ATOM2, ATOM3, "cp2k", "energy")
        except:
            output_filename = f"{ATOM1.lower()}_{ATOM2.lower()}_{ATOM3.lower()}_cp2k_energy.xlsx"
        df.to_excel(output_filename, index=False)
        print(f"Energy data saved to: {output_filename}")

    if error_rows:
        dfe = pd.DataFrame(error_rows, columns=["x", "y"])  # Coordinate pairs (failed)
        try:
            error_filename = get_output_filename(ATOM1, ATOM2, ATOM3, "cp2k", "errors")
        except:
            error_filename = f"{ATOM1.lower()}_{ATOM2.lower()}_{ATOM3.lower()}_cp2k_errors.xlsx"
        dfe.to_excel(error_filename, index=False)
        print(f"Error data saved to: {error_filename}")

    print(f"Processing completed! Total processed {len(data_rows)} successful files, {len(error_rows)} failed files")


if __name__ == "__main__":
    main()


