# Microcontroller based remote-control system 

Design and construction of a microcontroller based remote-control system for home appliances with real-time monitoring using mobile phones

#### Table of Contents

- [Introduction](#introduction)
- [1. System components](#1-system-components)
- [2. Specifications of Microcontroller PIC18F8722](#2-specifications-of-microcontroller-pic18f8722)


## Introduction

The aim of this project is to:
 - Create a system for remote control of home appliances
 - Make appropriate choice of the main control components:
    - microcontroller
    - mobile phone
- Develop a programming code for the microcontroller
- Implement AT commands in the code
- Apply serial communication between the mobile phone and microcontroller
- Use the proper type of sensors for household conditions monitoring 

## 1. System components

-	PIC18F8722 microcontroller
-	Sony Ericsson T230 mobile phone
-	RS232 serial communication cable
-	Omron G3L-205P1C-US electronic relay
-	Analog temperature sensor LM35DZ
-	Infrared motion sensor EKMC1601111
-	LCD display LM016L
-	Several signal LEDs and resistors

## 2. Specifications of Microcontroller PIC18F8722

| Specifications            |   PIC18F8722 |
| :---                      |        ---: |
| Operating Frequency       | DC – 40 MHz |
| Program Memory (Bytes)    | 128K |
| Data Memory (Bytes)       | 3.936 |
| Data EEPROM Memory (Bytes) | 1.024 |
| I/O Port PINs | 70 |
| 10-bit Analog-to-Digital Module | 16 Input Channels |
| Timers | 5 |
| Capture/Compare/PWM Modules | 2 |
| Operating Voltage       | 2.0 – 5.5 VDC |

## 3. Mobile Phone Sony Ericsson T230

- An intermediary between the microcontroller and the system user
- Allows connection to the microcontroller via a serial communication cable
- It supports the exchange of information using AT commands
    - mode of operation in text format, as opposed to PDU format
- Its main purpose is wireless exchange of information over long distances
    - allows devices to be controlled remotely
