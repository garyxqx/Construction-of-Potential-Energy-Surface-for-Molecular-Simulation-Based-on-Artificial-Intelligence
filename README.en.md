## PES Project Guide (English)

This repository provides neural-network-based Potential Energy Surface (PES) modeling and Molecular Dynamics (MD) simulation with both CLI and a simple GUI.

### Features

- **Train**: Fit a neural PES using CSV data
- **Visualize**: Generate true-vs-predicted scatter plots, 3D surfaces and 2D contours
- **Simulate**: Run a simple MD simulation driven by gradients of the learned PES
- **Logging**: Visualize metrics via TensorBoard

### Environment Setup

1) Use a virtual environment (recommended)
```
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
```

2) Install dependencies
```
pip install -r requirements.txt
```

For GPU acceleration, install a CUDA-enabled PyTorch.

### Quick Start

CLI:
```
# Train (Unix/macOS)
./run.sh train --config 2-64 --data input_force_filtered.csv --out 2-64
# Train (Windows)
run.bat train --config 2-64 --data input_force_filtered.csv --out 2-64

# Visualize (Unix/macOS)
./run.sh visualize --config 2-64 --data input_force_filtered.csv --model-dir 2-64
# Visualize (Windows)
run.bat visualize --config 2-64 --data input_force_filtered.csv --model-dir 2-64

# Simulate (Unix/macOS)
./run.sh simulate --config 2-64 --model-dir 2-64 --steps 50000
# Simulate (Windows)
run.bat simulate --config 2-64 --model-dir 2-64 --steps 50000

# List available configs (Unix/macOS)
./run.sh list-configs
# List available configs (Windows)
run.bat list-configs
```

GUI:
```
# Unix/macOS
./run.sh gui
# Windows
run.bat gui
# Visit: http://localhost:8501
```

The GUI supports English/Chinese switching via the language selector in the sidebar.

### Data Format

CSV must contain columns: `x`, `y`, `z1`, `z2`, `z3`, `z4`.
- `x, y`: Model inputs
- `z1`: Main regression target
- `z2..z4`: Target gradients (for gradient supervision)

### Configuration

See `config.py`. `DEFAULT_CONFIG_NAME` is the default. Each config includes:
- Model: `hidden_dim`, `num_layers`, `activation_function`
- Training: `learning_rate`, `epochs`, `patience`, `min_delta`
- Data: `train_data_path`
- Output filenames: `save_model_path`, `saveaxpath`, `saveaxpath2`, `assesspath`

Most parameters can be overridden from CLI/GUI.

Note: Training runs per-sample without batching (equivalent to batch size = 1). There is no `batch_size` parameter.

### Code Structure

- `main.py`: CLI entry (train/visualize/simulate/list-configs)
- `gui.py`: Streamlit GUI (with language switching)
- `model.py`: Neural network model (activation resolved by name)
- `train.py`: Training loop (early stopping, LR scheduler, TensorBoard)
- `data_loader.py`: CSV to DataLoader (per-sample iteration)
- `utils.py`: Model I/O, logging, visualization, metrics
- `loss.py`: Weighted loss of value MSE + gradient MSE
- `molecular_simulation.py`: Simple MD using PES gradients
- `config.py`: Config registry and defaults
- `mkdir.py`: Helper to create multiple directories

### Training

Example:
```
# Unix/macOS
./run.sh train --config 2-64 --data input_force_filtered.csv --out 2-64 \
  --epochs 800 --patience 60 --lr 0.0005 --activation ReLU
# Windows
run.bat train --config 2-64 --data input_force_filtered.csv --out 2-64 \
  --epochs 800 --patience 60 --lr 0.0005 --activation ReLU
```

TensorBoard logs:
```
tensorboard --logdir logs
```

### Visualization

After training, you will get:
- `assess.png`: True-vs-predicted scatter plot
- `ax.png`: 3D PES surface
- `ax2.png`: 2D contour

### Simulation

Example:
```
# Unix/macOS
./run.sh simulate --config 2-64 --model-dir 2-64 --steps 60000 --dt 1e-18 \
  --x1 3.0 --x2 0.0 --x3 -1.108 --v1 -20000 --v2 0 --v3 0
# Windows
run.bat simulate --config 2-64 --model-dir 2-64 --steps 60000 --dt 1e-18 \
  --x1 3.0 --x2 0.0 --x3 -1.108 --v1 -20000 --v2 0 --v3 0
```

Outputs:
- Trajectory CSV: `simulation_results.csv`
- XYZ: `<config>_trajectory.xyz`
- MD contour with path: `*_MD.png`
- Total energy curve: `*_Energy.png`

### Notes

- If `LeakyReLU` is selected as activation, the model uses `negative_slope=0.01`.
- Streamlit image rendering uses `use_container_width=True`.
- Training is performed per-sample without batching for better gradient supervision.

### FAQ

- CUDA unavailable? Install CUDA-enabled PyTorch or use CPU.
- Blank plots? Check column names/ranges (x,y in [0.5, 4.0]).
- Low R2? Increase model capacity or adjust LR/epochs.

### License

See this repo's LICENSE.


