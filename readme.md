# Sonar

Trying to make FPGA-based sonar.

## Used parts

1. INMP441-based micropone board
1. Piezo buzzer board
1. 90x70 mm prototype board
1. QMTECH Board with xc7z010clg400

## Dataflow

### Transmitter

* Signal generator
* Buzzer

### Receiver

* 4 I2S MEMS microphones
* I2S to AXI Stream converter IP
* Highpass FIR filter
* Demodulator
* Lowpass FIR filter
* Decimator
* AXI4 Stream to AXI4 Lite FIFO

## Project deployment

Execute the `deploy.bat` file (you may need to edit this file according to your Vivado version).

## Catalog tree description

* `doc`: project related documentation;
* `ip`: custom IP-cores, used in the project;
* `sdk`: Xilinx SDK project (without BSP and HDF)
* `sources`: project sources
    * `bd`: Vivado block design folder
    * `hdf`: hardware platform specification file folder (specified in the `Export -> Export Hardware ...` dialog box)
    * `ip`: non-BD IP instances
    * `tb`: testbench files
    * `xdc`: Xilinx design constraints folder
* `clean.bat`: script to cleanin temporary project files
* `deploy.bat` and `deploy.tcl`: project deployment scripts
