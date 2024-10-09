# 7-segment Clock on a DE10-Lite

This project implements a digital clock on the DE10-Lite FPGA development board using VHDL. The clock displays hours, minutes, and seconds on a 6-digit seven-segment display. It is possible to set the time using the two onboard tactile switches for incrementing the hours and minutes. The VHDL code was produced by ChatGPT, then adapted and troubleshot by me. This is to illustrate the use of AI to generate code. It is not meant to be a tutorial and it's not guaranteed that best coding practices are followed.

## Requirements

- DE10-Lite FPGA Development Board
- Having downloaded and installed Intel Quartus Prime Lite

## Files

- `clock_display.vhd`: The main VHDL file that contains the clock logic.
- `seven_segment_display.vhd`: A module for driving each seven-segment display.

If you only want to have a look at the source code, open these two files here on GitHub or in a text editor on your local machine.

## How It Works

1. **Clock Generation**: A 50 MHz input clock is divided down to 1 Hz using a counter.
2. **Time Counting**: The clock keeps track of hours, minutes, and seconds. Each time unit is represented by two signals (units and tens).
3. **Manual Time Adjustment**: 
   - When `KEY[0]` is pressed, the minutes increment. 
   - When `KEY[1]` is pressed, the hours increment. 
   - The clock resets to 00:00:00 after 23:59:59.
4. **Display**: The time is displayed on the six-digit seven-segment display.

## How to use


1. Clone this repository to your local machine, or download a copy in ZIP using the green button.
2. Open the project in **Intel Quartus Prime Lite**.
3. The project is already compiled. If you want to modify the source code, only then you need to recompile the VHDL code.
4. Program the DE10-Lite board with the `.sof` file (in the output_files folder) generated by Quartus. This loads the code in RAM, then the DE10 resets to default when power is lost. If you want the DE10-Lite to boot to this design every time, use the `.pof` file instead.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

