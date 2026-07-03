# FPGA Beamformer

> If you're new, read the "Project Structure" section first.
> **Project Status:** 🔴 Phase 1 (setup)
> **Next milestone:** LED blink

---

## 📂 Project Structure (Important)

### rtl/ (hardware design)
- **learning/** → code you're writing now (may be broken)
- **ready/** → works in simulation
- **hardware_ok/** → verified on real FPGA
- **uart/** → UART communication modules used to transmit FPGA measurements to a host computer.
- **fifo/** → (First-In, First-Out) buffering modules used to queue measurements between hardware blocks.
- **top/** → final system that connects everything

👉 A **top module** is the final assembled system that connects smaller modules into real hardware.
Vivado synthesizes the top module.

---

### sim/ (testing)
- **testbenches/** → simulation files
- **advanced_uvm/** → future (ignore for now)

---

### constraints/
- **pin_mappings/** → FPGA pin assignments (.xdc)

---

### build/
Vivado-generated files (NOT committed)

---

### docs/
Engineering notes and journal

---

## 🔁 Workflow

1. Write code → `rtl/learning/`
2. Test → `sim/testbenches/`
3. Works in simulation? → copy to `rtl/ready/`
4. Works on FPGA? → copy to `rtl/hardware_ok/`
5. Integrate system → `rtl/top/`

---

## 🚫 Rules

- Never commit `build/`
- Never edit Vivado-generated files
- Only commit code you wrote

---

## 🚀 Quick Start

```bash
make sim-blinky   # Run simulation
make view-blinky  # View waveforms
make clean        # Remove temp files

