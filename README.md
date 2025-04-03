# HUB75 LED Matrix Dice Demo

## Overview
FPGA-based digital dice system using VHDL. Displays dice animations on a HUB75 LED matrix. Components include clock scaling, dice rolling FSM, dice display logic, and a HUB75 Controller.

## Files
- **DiceRoller.vhd**: Dice FSM for state transitions.
- **HUB75_Dice_Logic.vhd**: Generates pixel-level dice patterns.
- **HUB75_Controller.vhd**: Drives the HUB75 LED matrix (row scanning, control signals).
- **PreScale.vhd**: Clock divider for timing adjustments.
- **scalerFSM.vhd**: FSM for dynamic clock scaling (i.e., dice animation slows down as it’s closer to stopping).
- **Top.vhd**: Top-level integration of all modules.

## Build & Usage
1. Import all VHDL files into your Quartus project.
2. Assign FPGA pins for `CLOCK_50`, switches (`SW`), keys (`KEY`), and `GPIO`. (Not necessary if you import the provided pinout.)
3. Compile and program the FPGA.
4. Use `KEY` and `SW` inputs to control dice rolling and display on/off.

## HUB75 GPIO Pinout
- **GPIO(0)**: r0  
- **GPIO(1)**: g0  
- **GPIO(2)**: b0  
- **GPIO(3)**: r1  
- **GPIO(4)**: g1  
- **GPIO(5)**: b1  
- **GPIO(6)**: A  
- **GPIO(7)**: B  
- **GPIO(8)**: C  
- **GPIO(9)**: D  
- **GPIO(10)**: CLK  
- **GPIO(11)**: LATCH  
- **GPIO(12)**: OE  

Below is a diagram of the HUB75 pinout (scaled down):

<img src="https://github.com/user-attachments/assets/a5799262-1b16-42d2-af19-34fc6aae3521" width="300" alt="HUB75 Pinout">

Demo:

<img src="https://github.com/user-attachments/assets/f2a9a52b-798d-44eb-bf11-ddd995458b77" width="300" alt="Demo GIF">
<img src="https://github.com/user-attachments/assets/ed5c34d6-7f70-424f-8328-526f218f4c46" width="300" alt="Demo Screenshot">

## How It Works
- **Clock Scaling:**  
  The `PreScale` and `scalerFSM` modules divide the 50MHz input clock to produce slower clocks. This allows you to gradually slow the dice roll animation.

- **Dice Rolling:**  
  The `DiceRoller` module implements an FSM that cycles through dice face states. The output (a 3-bit signal) represents the current face (1-6), which is then used to render dice patterns.

- **Dice Display Logic:**  
  `HUB75_Dice_Logic` converts face values into pixel-level patterns. It determines which pixels correspond to dice dots (red) or the background (white), based on defined regions on the LED matrix.

- **LED Matrix Driving:**  
  `HUB75_Controller` handles row scanning and timing for the HUB75 interface. It uses control signals (A-D for row addressing, CLK, LATCH, OE) to shift pixel data and update the display.

- **Top-Level Integration:**  
  The `Top` module ties together clock scaling, dice rolling, display logic, and matrix driving.
  
- **Modularity:**  
  Clock scaling, dice logic, and display logic are separated into distinct modules, making future modifications and expansion easy.

## License
MIT License.
