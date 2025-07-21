#include <EEPROM.h>
#include <SoftwareSerial.h>
#include <DHT.h>

// Pins
#define RPWM 6
#define LPWM 5
#define REN 8
#define LEN 7
#define IR_SENSOR 13
#define PHOTO_PIN A4
#define DHTPIN 12
#define DHTTYPE DHT11

#define STATE_OPENING 'O'  // Uppercase O for opening
#define STATE_CLOSING 'C'  // Uppercase C for closing
#define STATE_OPEN 'o'     // Lowercase o for open (stopped)
#define STATE_CLOSED 'c'   // Lowercase c for closed (stopped)
#define STATE_STOPPED 's'  // s for unknown/stopped

SoftwareSerial BTSerial(3, 2);
DHT dht(DHTPIN, DHTTYPE);

// Motor state
char currentState = STATE_STOPPED;

// Sensors active flags
bool tempActive = false;
bool humidityActive = false;
bool lightActive = false;

// Thresholds
float tempThreshold = 25.0;
float humidityThreshold = 50.0;
int lightThreshold = 500;



// Timing
unsigned long lastSensorCheckTime = 0;
const unsigned long sensorCheckInterval = 1000;  // Check every 1 second

// EEPROM storage
const int addrTemp = 0;
const int addrHumidity = 4;
const int addrLight = 8;
//const int addrState = 12;


unsigned long lastActionTime = 0;
const unsigned long actionCooldown = 20000; 

void loadThresholds() {
  EEPROM.get(addrTemp, tempThreshold);
  EEPROM.get(addrHumidity, humidityThreshold);
  EEPROM.get(addrLight, lightThreshold);
}

void saveThresholds() {
  EEPROM.put(addrTemp, tempThreshold);
  EEPROM.put(addrHumidity, humidityThreshold);
  EEPROM.put(addrLight, lightThreshold);
}

void stopMotor() {
  analogWrite(RPWM, 0);
  analogWrite(LPWM, 0);
  currentState = STATE_STOPPED;
}



void openWindow() {
   if (currentState != STATE_OPEN && currentState != STATE_OPENING) {
    // Start opening window
    analogWrite(RPWM, 0);
    analogWrite(LPWM, 150);
     currentState = STATE_OPENING;
    // Run for 10 seconds
    Serial.println("Opening window - will take 10 seconds");
    unsigned long startTime = millis();
    while (millis() - startTime < 10000) {
      // Small delay to prevent CPU hogging
      delay(100);
    }
    
    
    analogWrite(LPWM, 0);
    currentState = STATE_OPEN;
    lastActionTime = millis();
  }
}

void closeWindow() {
  if (currentState != STATE_CLOSED && currentState != STATE_CLOSING) {
    // Start closing window
    analogWrite(LPWM, 0);
    analogWrite(RPWM, 150);
    currentState = STATE_CLOSING;
    
    Serial.println("Closing window - waiting for IR sensor");
    
    // Run until IR sensor is triggered or maximum safety timeout (30 seconds)
    unsigned long startTime = millis();
    bool irTriggered = false;
    
    while (millis() - startTime < 15000) { 
      // Check IR sensor - stop if triggered
      if (digitalRead(IR_SENSOR) == LOW) {
        Serial.println("IR sensor triggered - window closed");
        irTriggered = true;
        break;
      }
      delay(100);
    }

    delay(100);
    analogWrite(RPWM, 0);
    currentState = STATE_CLOSED; 
    lastActionTime = millis();
    
  }
}

void updateThresholds(String cmd) {
  // Reset active flags - we'll set them if they're included in command
  tempActive = false;
  humidityActive = false;
  lightActive = false;
  
  int idx;
  while ((idx = cmd.indexOf(';')) != -1) {
    String pair = cmd.substring(0, idx);
    cmd = cmd.substring(idx + 1);

    if (pair.startsWith("L:")) {
      lightActive = true;
      lightThreshold = pair.substring(2).toInt();
    } else if (pair.startsWith("T:")) {
      tempActive = true;
      tempThreshold = pair.substring(2).toFloat();
    } else if (pair.startsWith("H:")) {
      humidityActive = true;
      humidityThreshold = pair.substring(2).toFloat();
    }
  }
  
  saveThresholds();
}

void checkSensors() {


   if (millis() - lastActionTime < actionCooldown) {
    return;
  }
  int photoVal = analogRead(PHOTO_PIN);
  float temp = dht.readTemperature();
  float humid = dht.readHumidity();
  Serial.print("Light: "); Serial.print(photoVal);
  Serial.print(" | Temp: "); Serial.print(temp);
  Serial.print("°C | Humidity: "); Serial.print(humid);
  Serial.println("%");
  if (isnan(temp) || isnan(humid)) {
    return; // Failed to read from DHT sensor
  }

  Serial.print("Window state: ");
    switch (currentState) {
      case STATE_OPEN: Serial.println("OPEN"); break;
      case STATE_CLOSED: Serial.println("CLOSED"); break;
      case STATE_OPENING: Serial.println("OPENING"); break;
      case STATE_CLOSING: Serial.println("CLOSING"); break;
      case STATE_STOPPED: Serial.println("STOPPED"); break;
    }
  
  bool shouldClose = false;
  
  // Check if any active sensor is above threshold
  if (tempActive && temp > tempThreshold) {
    shouldClose = true;
  }
  
  if (humidityActive && humid > humidityThreshold) {
    shouldClose = true;
  }
  
  if (lightActive && photoVal > lightThreshold) {
    shouldClose = true;
  }
  
  // Take action based on sensor readings
   if (shouldClose && currentState == STATE_OPEN) {
    Serial.println("Decision: Close window");
    closeWindow();
  } else if (!shouldClose && currentState == STATE_CLOSED) {
    Serial.println("Decision: Open window");
    openWindow();
  } else {
    Serial.println("Decision: No action needed");
  }
}

void setup() {
  dht.begin();
  Serial.begin(9600);
  BTSerial.begin(9600);

  pinMode(IR_SENSOR, INPUT);
  pinMode(RPWM, OUTPUT);
  pinMode(LPWM, OUTPUT);
  pinMode(REN, OUTPUT);
  pinMode(LEN, OUTPUT);

  digitalWrite(REN, HIGH);
  digitalWrite(LEN, HIGH);
  stopMotor();

  lastActionTime = millis();
  loadThresholds();
  checkSensors();

  if (digitalRead(IR_SENSOR) == LOW) {
    stopMotor();
    // Window is now closed, so we can set state accordingly
   currentState = STATE_CLOSED;
  } else {
    currentState = STATE_OPEN;
  }
}

void loop() {
  // Check IR sensor only during close operation
  //if (digitalRead(IR_SENSOR) == LOW) {
    //stopMotor();
    // Window is now closed, so we can set state accordingly
    //currentState = STATE_CLOSED;
  //}

  // Bluetooth input - only process threshold settings
  if (BTSerial.available()) {
    String cmd = BTSerial.readStringUntil('\n');
    cmd.trim();
    // Print ANY received command
    Serial.print("Received raw command: [");
    Serial.print(cmd);
    Serial.println("]");
    if (cmd.startsWith("Save:")) {
      String settingsData = cmd.substring(5);
       Serial.print("Settings data: ");
      Serial.println(settingsData);
      updateThresholds(settingsData);
     
    }
  }

  // Regular sensor checks on a 1-second interval
  unsigned long currentTime = millis();
  if (currentTime - lastSensorCheckTime >= sensorCheckInterval) {
    lastSensorCheckTime = currentTime;
    checkSensors();
  }

  delay(50);
}