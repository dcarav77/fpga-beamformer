# FPGA Development Portfolio – Artix-7

**Current status:** RTL development and hardware validation of UART interfaces, FIFO buffering, clock-domain crossing concepts, and ultrasonic sensor data acquisition on a Xilinx Artix-7 FPGA.

**Active work:** Extending the ultrasonic sensing system to multiple clock domains using an asynchronous FIFO with Gray-coded pointers and synchronized control signals.

---

## Project Structure

```text
rtl/                      # Hardware design
├── learning/             # In-progress modules
├── ready/                # Verified in simulation
├── hardware_ok/          # Verified on Artix-7 hardware
├── uart/                 # UART transmit/receive modules
├── fifo/                 # FIFO and buffering logic
└── top/                  # Top-level system integration

sim/                      # Simulation
├── testbenches/          # RTL testbenches
└── advanced_uvm/         # Future verification work

constraints/              # FPGA pin mappings and timing constraints
build/                    # Vivado-generated files (not committed)
docs/                     # Architecture notes and engineering journal
```

---

## Workflow

1. Write RTL → `rtl/learning/`
2. Simulate → `sim/testbenches/`
3. Verified in simulation → move to `rtl/ready/`
4. Verified on Artix-7 hardware → move to `rtl/hardware_ok/`
5. Integrate system → `rtl/top/`

---

## Current FPGA Work

* **UART interface** – Custom transmit/receive logic used for FPGA-to-host communication.
* **FIFO buffering** – Synchronous FIFO design and verification; currently extending the design to an asynchronous FIFO.
* **Clock-domain crossing** – Implementing Gray-coded read/write pointers and two-flop synchronization for asynchronous FIFO control.
* **Ultrasonic sensor interface** – FPGA logic generates the sensor trigger pulse, measures echo pulse width, buffers measurements, and forwards data to a host system.
* **Hardware validation** – FPGA signals and sensor timing validated with an oscilloscope.
* **Timing and implementation** – Designs synthesized and implemented in Vivado with XDC timing and pin constraints.

---

## Current System Architecture

```text
HC-SR04 Sensor
      ↓
Echo Measurement RTL
      ↓
FIFO / CDC
      ↓
UART Transmitter
      ↓
FTDI USB Interface
      ↓
Linux / Python Host
```

---

## Direction

This repository documents my transition from software engineering into FPGA and digital hardware design.

Current work focuses on real-time sensor-to-host pipelines, RTL architecture, buffering, clock-domain crossing, timing analysis, and hardware/software integration.

Future work will extend these foundations toward larger FPGA systems, hardware acceleration, computer architecture, and hardware/software co-design.
