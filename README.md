# Autonomous Window Controller

**Smart Sliding Window Automation System**

This project is a smart home device that automatically opens and closes a sliding-glass window based on environmental conditions such as temperature, humidity, and light — or via manual control through an Android app. The system uses an Arduino microcontroller, a 12V worm gear motor, and various sensors to implement both manual and context-aware automation.

Designed for affordability, modularity, and compatibility with most sliding windows.

---
Animation created in Unity for demonstration

## Demo

![Smart Window Closer Demo](demo/demo.gif)

---
## Features

- Automatically opens/closes a window based on:
  - Temperature
  - Humidity
  - Light intensity
- Manual control via Bluetooth Android app
- IR sensor-based window position detection
- Persistent settings stored in Arduino EEPROM
- Configurable sensor thresholds
- Real-time sensor values displayed in app
- Capstan-style paracord system driven by a worm gear motor

---

## System Overview

### Hardware Components

| Component               | Purpose                                      |
|-------------------------|----------------------------------------------|
| Arduino UNO             | Main microcontroller                         |
| BTS7960                 | Motor driver for 12V DC motor                |
| 12V Worm Gear DC Motor  | Applies force to move window                 |
| DHT11 Sensor            | Measures temperature and humidity            |
| Photoresistor           | Measures light intensity                     |
| IR Sensor               | Detects window closed position               |
| HC-05 Bluetooth Module  | Communicates with Android app                |
| ACS712                  | Measures current draw                        |
| Paracord + Spool        | Mechanical motion transmission               |

### Software Components

- **Arduino Sketch**  
  Reads sensor values, controls the motor, communicates with the app, and stores settings in EEPROM.

- **Android App (Flutter)**  
  Provides manual control, threshold configuration, and real-time data display via Bluetooth.

---

## Android App UI

| Mode              | Description                                               |
|-------------------|-----------------------------------------------------------|
| Manual Mode       | Button to open or close window; displays current state    |
| Automatic Mode    | Displays real-time sensor values                          |
| Configuration     | Enables/disables sensors and sets threshold values        |

---

## Setup Instructions

### Hardware

1. Mount the motor securely and attach the spool to the motor shaft using a hose clamp.
2. Route paracord around pulleys and tie both ends to an L-bracket on the window.
3. Wire all components to the Arduino:

   - DHT11: Digital input
   - Light sensor: Analog input
   - IR sensor: Digital input
   - BTS7960: PWM and direction pins
   - HC-05: TX/RX serial communication
   - ACS712: Analog input

4. Secure all connections and test motor tension.

### Software

#### Arduino

- Upload `WindowCloser.ino` from the `/arduino` directory using the Arduino IDE.
- Ensure required libraries are installed (`DHT`, `EEPROM`, etc.).

#### Android

- Build the Flutter app from `/android_app` using Android Studio or install the precompiled APK.
- Pair your phone with the HC-05 Bluetooth module.
- Launch the app, connect to HC-05, and test functionality.

---

## Testing and Results

### Hardware System

- Completed by **March 31**
- Functional capstan-style system reliably opens/closes real sliding window
- Motor and spool setup passes force/tension requirements

### Sensor Integration

- Completed by **April 8**
- Sensors: DHT11, photoresistor, IR sensor, ACS712, HC-05
- Arduino triggers correct behavior based on sensor thresholds

### Software System

- Completed by **April 14**
- App provides real-time data, threshold configuration, manual/auto control
- Arduino stores values in EEPROM and acts on thresholds accordingly

---

## Limitations

- No rain or sound sensor integration (time constraints)
- Opening is time-based; closing uses IR sensor
- Any one sensor can trigger window closure
- Cooldown added to prevent repeated open/close cycles

---

## Future Improvements

- Integrate rain and sound detection
- Add encoder/potentiometer for precise window position tracking
- Replace Bluetooth with Wi-Fi for remote access
- Add OTA firmware updates

---

## Repository Structure

