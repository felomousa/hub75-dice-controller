# HUB75 LED Matrix Dice Demo

## Overview

FPGA-based dice display system written in VHDL. Emulates rolling 1–4 dice with customizable face counts, rendered on a HUB75-compatible RGB LED matrix. Input is controlled through switches and keys on the DE10-Standard board. The dice animation progressively slows using a pseudo-random timing FSM, and final results are rendered as pixel patterns on the display.

## Files

- **Top.vhd**  
  Top-level integration of all submodules. Connects user input (switches + keys) to dice configuration, animation, and display output on GPIO.

- **Settings.vhd**  
  Parses switch/key inputs to increment/decrement number of dice (1–4) and number of faces (1–6). Prevents simultaneous editing of both settings.

- **RollDice.vhd**  
  Handles timed activation of a `DiceRoller`. Scales input clock and enables dice rolling for a fixed period.

- **Dice.vhd**  
  Top-level wrapper for a single animated die. Combines `scalerFSM` (to control rolling duration/clock speed) and `DiceRoller` (FSM-based face state generator). Uses an LFSR seed for pseudo-randomization.

- **scalerFSM.vhd**  
  Finite State Machine that outputs a progressively slower clock signal and enables rolling based on an LFSR-generated delay. Simulates a dice roll that slows before stopping.

- **PreScale.vhd**  
  Clock divider. Given a scale factor, outputs a lower-frequency clock used for timing dice updates.

- **DiceRoller.vhd**  
  FSM that cycles through 6 face states (1–6) when `enable` is high. Outputs current face value as a 3-bit signal.

- **HUB75_Dice_Logic.vhd**  
  Converts 3-bit face values into pixel-level dot patterns for display. Determines whether each pixel corresponds to a red dot, white dice background, or black background. Supports displaying 1–4 dice in predefined screen regions.

- **HUB75_Controller.vhd**  
  Drives the HUB75 LED matrix via GPIO. Implements row scanning, color shifting, and control signals (CLK, LATCH, OE, A-D).

## Inputs

- `SW(0)` – Edit number of faces (when high)  
- `SW(1)` – Edit number of dice (when high)  
- `SW(2)` – Disable die 1 (face_dice_0) when low  
- `SW(3)` – Disable die 2 (face_dice_1) when low  
- `SW(4)` – Disable die 3 (face_dice_2) when low  
- `SW(5)` – Disable die 4 (face_dice_3) when low  
- `SW(8)` – Reset to default for `Settings` module (active high)  
- `SW(9)` – Global display disable (when high, display outputs black)

- `KEY(0)` – Increment selected setting (faces or dice)  
- `KEY(3)` – Decrement selected setting (faces or dice)

## Outputs

- `GPIO(0)`: r0  
- `GPIO(1)`: g0  
- `GPIO(2)`: b0  
- `GPIO(3)`: r1  
- `GPIO(4)`: g1  
- `GPIO(5)`: b1  
- `GPIO(6)`: A  
- `GPIO(7)`: B  
- `GPIO(8)`: C  
- `GPIO(9)`: D  
- `GPIO(10)`: CLK  
- `GPIO(11)`: LATCH  
- `GPIO(12)`: OE  

Below is a diagram of the HUB75 pinout:

<img src="https://github.com/user-attachments/assets/a5799262-1b16-42d2-af19-34fc6aae3521" width="300" alt="HUB75 Pinout">

## Build & Usage

1. Import all `.vhd` files into your Quartus project.  
2. Assign pin constraints for `CLOCK_50`, `SW`, `KEY`, and `GPIO(0–12)`.  
3. Compile and program the FPGA.  
4. Use switch inputs to select number of dice/faces and roll behavior. Dice results are shown on the HUB75 display.

## How It Works

- **Clock Scaling & Animation**  
  `scalerFSM` uses internal states to gradually slow down the rolling animation. It combines with `PreScale` to manage the animation clock.

- **Pseudo-Randomness**  
  `scalerFSM` includes a 4-bit LFSR. It controls how long the dice roll before stopping, ensuring results vary and dice don't stop at a pre-determined time.

- **Dice Rolling Logic**  
  `DiceRoller` cycles through 6 faces and wraps around. `RollDice` controls how long each die rolls before freezing.

- **Display Logic**  
  `HUB75_Dice_Logic` takes current face values and maps them to hardcoded pixel positions to represent traditional dice layouts. Up to 4 dice can be shown at once.

- **Display Driving**  
  `HUB75_Controller` handles all signal-level driving of the LED matrix, updating rows and managing color shifts via GPIO.

- **Top-Level Coordination**  
  `Top.vhd` connects everything. It routes inputs to `Settings`, outputs dice states, manages how many dice to display, and connects `HUB75_Dice_Logic` + `HUB75_Controller`.

## Demo

<p float="left">
  <img src="https://github.com/user-attachments/assets/f2a9a52b-798d-44eb-bf11-ddd995458b77" width="300" alt="Demo GIF">
  <img src="https://github.com/user-attachments/assets/ed5c34d6-7f70-424f-8328-526f218f4c46" width="300" alt="Demo Screenshot">
</p>

## License

MIT License.