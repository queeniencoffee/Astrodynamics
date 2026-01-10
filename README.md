# "Sally Astra" Astrodynamics Toolkit 

<b> "Sally Astra" Astro Toolkit </b> is a Python-based astrodynamics and mission analysis platform developed to support <b> the evaluation and feasibility of space-based / AI data centers</b>. The project integrates orbital mechanics, space environment modeling, and system-level trade studies to evaluate how orbital selection impacts power availability, thermal behavior, communications access, and long-term operability. 

Built using modern scientific Python libraries, the toolkit supports high-fidelity orbit propagation, eclipse and coverage analysis, parametric trade studies, and interactive visualization. A modular architecture separates core physics models from mission logic and a graphical user interface, enabling reproducible model-and-simulation workflows and clear engineering traceability.

The project serves both as a learning framework for applied astrodynamics and as a proof-of-concept mission analysis tool, demonstrating how orbital dynamics directly inform the design and operation of next-generation orbital infrastructure.






## 📦 Sally Astra Astrodynamics Toolkit — Structure

```
sally-astra/
│
├── README.md
├── environment.yml
├── pyproject.toml
│
├── src/
│   └── astrodc/
│       ├── __init__.py
│
│       ├── config/                 # Mission & simulation configuration
│       │   ├── constants.py
│       │   ├── earth.py
│       │   ├── mission_defaults.py
│       │
│       ├── core/                   # Core astrodynamics engines
│       │   ├── __init__.py
│       │   ├── time.py             # Time systems & epochs
│       │   ├── frames.py           # ECI/ECEF conversions
│       │   ├── propagation.py      # poliastro wrappers
│       │   ├── transfers.py
│       │   ├── perturbations.py
│       │
│       ├── environment/            # Space environment models
│       │   ├── __init__.py
│       │   ├── eclipse.py
│       │   ├── radiation.py
│       │   ├── atmosphere.py
│       │
│       ├── power_thermal/           # Data center–specific models
│       │   ├── __init__.py
│       │   ├── solar_power.py
│       │   ├── battery.py
│       │   ├── thermal_balance.py
│       │
│       ├── comms/                  # Communications geometry
│       │   ├── __init__.py
│       │   ├── ground_stations.py
│       │   ├── access.py
│       │   ├── latency.py
│       │
│       ├── mission/                # Mission logic & CONOPS
│       │   ├── __init__.py
│       │   ├── orbit_design.py
│       │   ├── station_keeping.py
│       │   ├── disposal.py
│       │
│       ├── trade_studies/           # Parametric analysis
│       │   ├── __init__.py
│       │   ├── orbit_trades.py
│       │   ├── power_trades.py
│       │   ├── cost_proxies.py
│       │
│       ├── visualization/           # Plotting & animation
│       │   ├── __init__.py
│       │   ├── plots_2d.py
│       │   ├── orbits_3d.py
│       │   ├── ground_tracks.py
│       │   ├── animations.py
│       │
│       ├── gui/                    # PySide6 application
│       │   ├── __init__.py
│       │   ├── app.py
│       │   ├── main_window.py
│       │   ├── orbit_panel.py
│       │   ├── results_panel.py
│       │
│       └── utils/                  # Shared helpers
│           ├── __init__.py
│           ├── units.py
│           ├── logging.py
│           └── io.py
│
├── notebooks/                      # Exploration only
│   ├── orbit_trade_study.ipynb
│   ├── eclipse_analysis.ipynb
│
├── tests/
│   ├── test_propagation.py
│   ├── test_eclipse.py
│
├── data/
│   ├── ground_stations.yaml
│   └── orbit_cases/
│
├── videos/
│   ├── meo_orbit_demo.mp4
│   └── eclipse_cycle.gif
│
├── docs/
│   ├── architecture.md
│   ├── assumptions.md
│   └── trade_studies.md
│
└── .vscode/
    ├── settings.json
    └── launch.json

```
