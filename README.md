# QCA_LeeQ

Quantum Calibration Agent integrated with LeeQ - A Docker container that bundles the CalibrationNTKAgent with LeeQ's quantum experiment framework.

## Overview

This repository provides a containerized environment for running AI-powered quantum calibration workflows using:

- **CalibrationNTKAgent**: LLM-based agent for orchestrating quantum calibration experiments
- **LeeQ**: Superconducting qubit experiment framework with high-level simulation

## Quick Start

### Prerequisites

- Docker and Docker Compose
- OpenAI API key (for GPT-4o)

### Setup

1. Clone with submodules:
```bash
git clone --recursive git@github.com:ShuxiangCao/QCA_LeeQ.git
cd QCA_LeeQ
```

2. Create environment file:
```bash
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

3. Build the container:
```bash
docker build -t qca-leeq .
```

### Running

#### Interactive TUI with Web UI
```bash
docker run -it -p 8000:8000 -e OPENAI_API_KEY qca-leeq
```
- Automatically inherits `OPENAI_API_KEY` from host environment
- Web UI available at http://localhost:8000
- TUI runs in terminal for interactive commands

#### Web UI Only
```bash
docker run -p 8000:8000 -e OPENAI_API_KEY qca-leeq serve
```

#### Execute Single Command
```bash
docker run -e OPENAI_API_KEY qca-leeq exec "list all available experiments"
```

#### Using Docker Compose (Recommended)
```bash
# Interactive TUI + Web UI (inherits OPENAI_API_KEY from host)
docker compose up

# Web UI only
docker compose up webui
```

## Available Experiments

The container comes with 10+ LeeQ experiments auto-discovered:

| Category | Experiment | Description |
|----------|------------|-------------|
| calibrations | DragCalibrationSingleQubitMultilevel | DRAG coefficient calibration |
| calibrations | NormalisedRabi | Driving amplitude calibration |
| calibrations | SimpleRamseyMultilevel | Frequency detuning measurement |
| calibrations | ResonatorSweepTransmissionWithExtraInitialLPB | Resonator frequency sweep |
| calibrations | MeasurementCalibrationMultilevelGMM | GMM measurement calibration |
| characterizations | SingleQubitRandomizedBenchmarking | Gate fidelity benchmarking |
| characterizations | SimpleT1 | T1 relaxation measurement |
| characterizations | SpinEchoMultiLevel | T2 coherence measurement |

## Example Usage

### List Experiments
```bash
docker compose run --rm qca-leeq exec "list all available experiments"
```

### Run Calibration
```bash
docker compose run --rm qca-leeq exec \
  "calibrate qubit 0 starting with resonator spectroscopy, then Rabi and Ramsey"
```

### Interactive Session
```bash
docker compose up
# Web UI at http://localhost:8000
# TUI in terminal
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key (required) | - |
| `EPII_EXPERIMENT_SET` | Active experiment set | `leeq` |
| `EPII_TIMEOUT` | Execution timeout (seconds) | `300` |

### Custom Configuration

Mount your own config:
```bash
docker run -v ./my-config:/app/config:ro -e OPENAI_API_KEY=$OPENAI_API_KEY qca-leeq
```

## Architecture

```
QCA_LeeQ/
├── CalibrationNTKAgent/     # AI agent for calibration (submodule)
├── LeeQ/                    # Quantum experiment framework (submodule)
├── config/
│   └── epii_config.yaml     # EPII configuration for LeeQ
├── Dockerfile
├── docker-compose.yml
└── entrypoint.sh
```

### How It Works

1. **CalibrationNTKAgent** provides the LLM-based orchestration layer
2. **LeeQ** provides the experiment implementations with high-level simulation
3. **EPII** (Experiment Platform Intelligence Interface) bridges them together
4. The agent can:
   - List available experiments
   - Execute experiments with parameters
   - Analyze results and make decisions
   - Chain experiments into calibration workflows

## Development

### Updating Submodules
```bash
git submodule update --remote
```

### Rebuilding After Changes
```bash
docker build --no-cache -t qca-leeq .
```

## License

See individual submodule licenses:
- CalibrationNTKAgent: [LICENSE](CalibrationNTKAgent/LICENSE)
- LeeQ: [LICENSE](LeeQ/LICENSE)
