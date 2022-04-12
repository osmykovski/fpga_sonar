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
* AXI4 Stream to AXI4 Lite FIFO
