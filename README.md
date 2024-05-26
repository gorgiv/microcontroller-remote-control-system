# Microcontroller based remote-control system 

Design and construction of a microcontroller based remote-control system for home appliances with real-time monitoring using mobile phones

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
| I/O Pins | 70 |
| 10-bit Analog-to-Digital Module | 16 Input Channels |
| Timers | 5 |
| Capture/Compare/PWM Modules | 2 |
| Operating Voltage       | 2.0 – 5.5 VDC |

![Microcontroller PIC18F8722](/assets/images/medium-PIC18F8722-TQFP-80.png "Microcontroller PIC18F8722")

## 3. Mobile Phone Sony Ericsson T230

- An intermediary between the microcontroller and the system user
- Allows connection to the microcontroller via a serial communication cable
- It supports the exchange of information using AT commands
    - mode of operation in text format, as opposed to PDU format
- Its main purpose is exchange of information over long distances via SMS messages
    - allows devices to be controlled remotely

## 4. MAX232 for voltage level adjustment of the microcontroller

![MAX232](/assets/images/MAX232.jpg "MAX232")

To adjust the voltage level of the microcontroller ports for serial communication (from 0V to 5V) it is necessary to use a MAX232 adapter which:
- Converts ±12V from RS232 into TTL compatible from 0V to 5V
- Inverts the voltage levels so that 5V is a "logic 1" and 0V is a "logic 0"

![UART](/assets/images/UART.png "UART")

## 5. Power supply of the mobile phone serial port

- RS232 integrated circuit allows a maximum of 50mA per output pin
- Serial port of the mobile phone requires a current of 70mA
- On the Sony Ericsson T230 mobile phone it is necessary to connect the DTR and RTS pins to a 5V power supply for normal operation

![RS232supply](/assets/images/RS232supply.png "RS232supply")

## 6. AT Commands

- AT Commands are programming instructions used to exchange information between the mobile phone and the microcontroller
- They are used to control the mobile phone
- AT stands for "Attention"
- Every command line starts with "AT" and that's why modem commands are called AT Commands

## 7. Main features of the system

- On-off control of boiler, heater and irrigation system
- Maintain the ambient temperature in the home according to the desired temperature
- Fire alarm - Automatic notification when a critical temperature is exceeded
- Intruder alarm - Automatic notification when a human presence (home invader) is detected at home where the motion sensor is installed
- Check the current measured temperature in the home
- When a user is present at home, he can monitor the current temperature in the room through the display
- Allowed control by an unlimited number of users from any place in the world with a GSM network available
- Only one person can be a system administrator

## 8. Working principle of the system

- A user sends an SMS message with a specific command to the mobile phone of the system
- The microcontroller constantly checks if the mobile phone has received an SMS message
- The microcontroller will read the new message, delete it from the phone's memory and execute the appropriate command
- Then, the microcontroller in the mobile phone of the system will write an SMS message with a response for the executed command and send it back to the user
- The microcontroller will also send an SMS message to the administrator to inform him about the phone number of the user who gave the command and its content as well

![PrincipleScheme](/assets/images/PrincipleScheme.jpg "PrincipleScheme")

## 9. Schematic diagram of the system

![SchematicDiagram](/assets/images/SchematicDiagram.jpg "SchematicDiagram")
