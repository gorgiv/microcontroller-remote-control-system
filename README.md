# Microcontroller-based remote control system 

Design and construction of a microcontroller-based remote control system for home appliances with real-time monitoring using mobile phones

![PrincipleScheme](/assets/images/PrincipleScheme.jpg "PrincipleScheme")

## Introduction

The aim of this project is to:
 - Create a system for remote control of home appliances
 - Make appropriate choice of the main control components:
    - microcontroller
    - mobile phone
- Develop a programming code for the microcontroller
- Implement AT commands in the code
- Establish serial communication between the mobile phone and microcontroller
- Utilize proper type of sensors for home conditions monitoring 

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

| **Specifications**            |   **PIC18F8722** |
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

![MicrocontrollerPIC18F8722](/assets/images/MicrocontrollerPIC18F8722.png "MicrocontrollerPIC18F8722")

## 3. Mobile phone Sony Ericsson T230

- An intermediary between the microcontroller and the system user
- Allows connection to the microcontroller via a serial communication cable
- It supports the exchange of information using AT commands
    - mode of operation in text format, as opposed to PDU format
- Its main purpose is information exchange over long distances via SMS messages
    - allows devices to be controlled remotely

## 4. MAX232 for voltage level adjustment of the microcontroller

![AdapterMAX232](/assets/images/AdapterMAX232.jpg "AdapterMAX232")

To adjust the voltage level of the microcontroller ports for serial communication (from 0V to 5V) it is necessary to use a MAX232 adapter which:
- Converts ±12V from RS232 into TTL compatible from 0V to 5V
- Inverts the voltage levels so that 5V is a "logic 1" and 0V is a "logic 0"

![ChartUART](/assets/images/ChartUART.png "ChartUART")

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
- Automatic Temperature Control - Maintain the ambient temperature in the home according to the desired temperature
- Fire alarm - Automatic notification when a critical temperature is exceeded
- Intruder alarm - Automatic notification when a human presence (home invader) is detected at home where the motion sensor is installed
- Check the current measured temperature in the home
- When a user is present at home, he can monitor the current temperature in the room through the display
- Allowed control by an unlimited number of users from any place in the world with a GSM network available
- Suitable for places without internet connection
- Only one person can be a system administrator

## 8. Working principle of the system

- A user sends an SMS message with a specific order to the mobile phone of the system
- The microcontroller constantly checks if the mobile phone has received an SMS message
- The microcontroller will read the new message, delete it from the phone's memory and execute the appropriate order
- Then, the microcontroller in the mobile phone of the system will write an SMS message with a response for the executed order and send it back to the user
- The microcontroller will also send an SMS message to the administrator to inform him about the phone number of the user who gave the order and its content as well

## 9. Handling orders

![TableOfOrders](/assets/images/TableOfOrders.png "TableOfOrders")

### 9.1 Turning ON the Boiler

If a user wishes to turn ON the boiler remotely, he only needs to send an SMS message to the mobile phone of the system with the following content

![SMSUserTurnsOnBoiler](/assets/images/SMSUserTurnsOnBoiler.png "SMSUserTurnsOnBoiler")

After the microcontroller turns ON the boiler successfully, it will respond back via the mobile phone by sending an SMS message to the user with the following content

![SMSPICRespondsTurnedOnBoiler](/assets/images/SMSPICRespondsTurnedOnBoiler.png "SMSPICRespondsTurnedOnBoiler")

Then, the microcontroller will also send a notification SMS message to the administrator with the following content

![SMSPICNotifiesTurnedOnBoiler](/assets/images/SMSPICNotifiesTurnedOnBoiler.png "SMSPICNotifiesTurnedOnBoiler")

### 9.2 Turning OFF the Boiler

If a user wishes to turn OFF the boiler remotely, he only needs to send an SMS message to the mobile phone of the system with the following content

![SMSUserTurnsOffBoiler](/assets/images/SMSUserTurnsOffBoiler.png "SMSUserTurnsOffBoiler")

After the microcontroller turns OFF the boiler successfully, it will respond back via the mobile phone by sending an SMS message to the user with the following content

![SMSPICRespondsTurnedOffBoiler](/assets/images/SMSPICRespondsTurnedOffBoiler.png "SMSPICRespondsTurnedOffBoiler")

Then, the microcontroller will also send a notification SMS message to the administrator with the following content

![SMSPICNotifiesTurnedOffBoiler](/assets/images/SMSPICNotifiesTurnedOffBoiler.png "SMSPICNotifiesTurnedOffBoiler")

### 9.3 Turning ON the Heater and Automatic Temperature Control

The content of the SMS message for turning on the heater and automatically control a certain temperature to be send by user is as follows

![SMSUserTurnsOnHeater](/assets/images/SMSUserTurnsOnHeater.png "SMSUserTurnsOnHeater")

![ChartHeaterATC](/assets/images/ChartHeaterATC.png "ChartHeaterATC")

### 9.4 Automatic notification of fire alarm and intruder alarm

- A fire alarm occurs when the temperature in the room exceeds 50&deg;C
- When a human presence is detected near the motion sensor, a home intruder alarm is activated
- Only the administrator can receive an automatic alarm notification via an SMS message with the following content:
    - Alarm POZAR (Alarm FIRE)
    - Alarm DVIZENJE (Alarm MOTION)

### 9.5 Conditions monitoring

By sending an SMS message "14MK SOSTOJBI" the user can receive the following information:
- What is the current temperature in the room?
- Are following devices turned on/off:
    - boiler
    - heater
    - irrigation system
- If the heater is turned off, is the automatic temperature control still active?
- Has an alarm been activated for:
    - fire
    - home intruder

![TableConditionsMonitoring](/assets/images/TableConditionsMonitoring.png "TableConditionsMonitoring")

## 10. Schematic diagram in Proteus 8 Professional

![SchematicDiagram](/assets/images/SchematicDiagram.jpg "SchematicDiagram")

## 11. Source code programming

- BASIC programming language with Proton IDE (Integrated Development Environment) is used for development of the [source code](./source/code.bas) for the PIC microcontroller
- On completion, the machine code file generated by Proton Plus Compiler is loaded into the microcontroller memory using an external Programmer such as ICD2, PICKit2 or "ET-PGMPIC USB" Programmer of ETT
- After finishing programming, the PIC microcontroller becomes ready to connect to the hardware circuit 

![SourceCodeProgramming](/assets/images/SourceCodeProgramming.jpg "SourceCodeProgramming")