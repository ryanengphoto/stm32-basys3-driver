# stm32-basys3-driver

This project's goal is to create a system that effectively combines three different systems to create an ALU that can be operated from a computer GUI created with python by sending serial data to an STM32 that will forward the appropriate signals to the basys3 to stimulate the ALU designed in HDL there and provide the output back to the GUI for the operator to see.

## Structure
### /pc
This holds the python code for the gui.

### /stm
This holds the C code for the stm32h7553zit6

### /basys3
This holds the verilog/systemverilog code for the Artix7 FPGA on the Basys3 dev board