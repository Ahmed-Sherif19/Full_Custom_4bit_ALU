# 4-Bit Full-Custom Arithmetic & Logic Unit (ALU)

**ECE 316: Digital Circuit Design | Ain Shams University (Spring 2026)**  
**Supervised by:** Prof. Sameh A. Ibrahim & Eng. Ibrahim Ayman  

---

## 📌 Project Overview

This project implements a complete, end-to-end IC design flow for a high-performance **4-bit signed Arithmetic and Logic Unit (ALU)** operating at **1 GHz** in **TSMC 65-nm CMOS technology** ($V_{DD} = 1.2\text{ V}$).

The design spans the entire abstraction stack from behavioral specification to physical layout:
1. **Behavioral RTL Description** in schematic-friendly Verilog.
2. **Functional Verification** via a comprehensive SystemVerilog testbench.
3. **Logic Synthesis & Schematic Extraction** using Xilinx Vivado.
4. **Transistor-Level Implementation** in Cadence Virtuoso using complementary CMOS logic.
5. **Circuit-Level Transient Simulation** verifying all 16 operations in Cadence ADE.
6. **Worst-Case Timing & Power Analysis** demonstrating timing closure at 1 GHz.
7. **Physical Layout & DRC/LVS Verification** in Cadence Virtuoso Layout Suite.

---

## ⚙️ Architecture & Specifications

The ALU accepts two 4-bit signed operands ($a[3:0]$ and $b[3:0]$) and a 4-bit operation code ($sel[3:0]$). The output $y$ is registered on the rising edge of a **1 GHz** system clock.

- **Arithmetic Unit ($sel[3] = 0$):** Processes signed arithmetic operations with an extended 8-bit output path.
- **Logic Unit ($sel[3] = 1$):** Executes 4-bit bitwise Boolean operations.
- **Output Multiplexer:** Routes the selected unit's result to the output registers.

### Supported Operations (16 Opcodes)

| `sel[3:0]` | Operation | Category | Description |
|:---:|:---:|:---:|:---|
| `0000` | $a + 1$ | Arithmetic | Increment operand $a$ |
| `0001` | $b + 1$ | Arithmetic | Increment operand $b$ |
| `0010` | $a$ | Arithmetic | Transfer operand $a$ |
| `0011` | $b$ | Arithmetic | Transfer operand $b$ |
| `0100` | $a - 1$ | Arithmetic | Decrement operand $a$ |
| `0101` | $b - 1$ | Arithmetic | Decrement operand $b$ |
| `0110` | $a + b$ | Arithmetic | 4-bit Signed Addition |
| `0111` | $a - b$ | Arithmetic | 4-bit Signed Subtraction ($a \ge b$) |
| `1000` | $\sim a$ | Logic | Bitwise NOT (Complement $a$) |
| `1001` | $\sim b$ | Logic | Bitwise NOT (Complement $b$) |
| `1010` | $a \ \& \ b$ | Logic | Bitwise AND |
| `1011` | $a \ \| \ b$ | Logic | Bitwise OR |
| `1100` | $a \oplus b$ | Logic | Bitwise XOR |
| `1101` | $\sim(a \oplus b)$ | Logic | Bitwise XNOR |
| `1110` | $\sim(a \ \& \ b)$ | Logic | Bitwise NAND |
| `1111` | $\sim(a \ \| \ b)$ | Logic | Bitwise NOR |

---

## 🔬 Transistor-Level Implementation (Cadence Virtuoso)

- **Process Technology:** TSMC 65-nm CMOS Process
- **Supply Voltage ($V_{DD}$):** 1.2 V
- **Transistor Sizing:**
  - Minimum Channel Length: $L_{min} = 60\text{ nm}$
  - NMOS Width: $W_n = 120\text{ nm}$
  - PMOS Width: $W_p = 240\text{ nm}$ ($W_p / W_n = 2$ for symmetric switching thresholds and matched propagation delays)
- **Circuit Hierarchy:** Built modularly with reusable building blocks:
  - Primitive gates (Inverters with $1\times, 2\times, 4\times, 16\times$ drive, NAND, NOR, XOR, XNOR, Transmission Gates)
  - Multiplexers ($2\times1, 4\times1, 8\times1$)
  - Arithmetic Slice & Full Adder
  - Logic Slice
  - Synchronous D Flip-Flops and 4-bit / 8-bit Output Registers

---

## 📊 Key Simulation Results & Performance

- **Target Clock Frequency:** 1.0 GHz ($T_{clk} = 1.0\text{ ns}$)
- **Measured Worst-Case Propagation Delay:** $\approx \mathbf{550\text{ ps}}$
- **Maximum Operating Frequency ($f_{max}$):** $\mathbf{1.818\text{ GHz}}$
- **Timing Margin:** **450 ps** (45% slack beyond 1 GHz requirement)
- **Functional Equivalence:** 100% agreement between SystemVerilog RTL and Cadence Virtuoso transistor-level transient simulations.
- **Physical Verification:** Layout cells (Inverter, NAND, NOR, XNOR, MUX) cleanly passed DRC with zero design rule violations.

---

## 📁 Repository Structure

```
.
├── ALU_Design_Project_Report.pdf   # Complete 47-page technical project report
├── Cadence/                        # Exported schematics of top module, slices, & cells
│   ├── TOP MODULE.jpeg
│   ├── ARTH SLICE.jpeg
│   ├── LOGIC SLICE.jpeg
│   ├── FULL ADDER.jpeg
│   ├── TB.jpeg
│   └── ...
├── Layout/                         # Physical layouts with DRC verification screenshots
│   ├── INVERTER_L.jpeg
│   ├── NAND_L.jpeg
│   ├── NOR_L.jpeg
│   ├── XNOR_L.jpeg
│   └── MUX_L.jpeg
├── Verilog/                        # RTL sources and verification suite
│   ├── Design.v                    # Synthesizable 4-bit ALU RTL
│   ├── TB.sv                       # SystemVerilog testbench covering all 16 ops
│   ├── Wave Form.jpeg              # ModelSim/QuestaSim waveform simulation
│   └── Transcript.jpeg             # Verification log transcript
└── Cadence_OA_Top/                 # Cadence Virtuoso OpenAccess top-level architecture
    └── DCD_ALU/
        ├── alu_top                 # Top ALU schematic & symbol
        ├── arith_slice             # Arithmetic slice schematic & symbol
        └── logic_slice             # Logic slice schematic & symbol
```

---

## 👥 Team Members (Team 7)

- **Ahmed Sherif** (23P0414) — *Gates & Logic*
- **Omar Ahmed Fouad** (23P0369) — *Report & Building blocks on Cadence*
- **Alaa Mostafa** (23P0331) — *Gates*
- **Ahmed Belal** (23P0007) — *Layout*
- **Naira Ahmed** (23P0408) — *Verilog & Testbench*
- **Abdullah Mohamed** (23P0238) — *Gates & Logic*
- **Fady Sameh Gamal** (23P0057) — *Gates*
- **Marina Amgad** (23P0330) — *Verilog & Testbench*
- **Mohamed Abdel Ghany** (22P0131) — *Report & Building blocks on Cadence*
