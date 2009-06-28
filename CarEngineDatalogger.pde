/**
 * CarEngineDatalogger
 *
 * Reads engine management system data using an OBD-II interface.
 *
 * This implementation relies on the extra UARTs available in an
 * Arduino Mega. It could alternatively use SoftwareSerial and run on
 * a Duemilanove or similar, but there may be problems with maintaining
 * several serial ports running at once at moderately high speed.
 *
 * Copyright 2009 Jonathan Oxer <jon@oxer.com.au>
 * http://www.practicalarduino.com/projects/medium/car-engine-datalogger
 */
#define ledPin 13

int incomingByte = 0;  // for incoming serial data

/**
 * Initial configuration
 */
void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(38400);   // Port for connection to host
  Serial1.begin(38400);  // Port for connection to OBD adaptor
  Serial2.begin(9600);   // Port for connection to GPS module

  Serial.println("Car Engine Datalogger starting up");

  //delay(1000);
  //Serial1.println("ATRV");
  //requestObdValue();
}


/**
 * Main program loop
 */
void loop() {
  toggle(ledPin);
  requestObdValue();
  delay(1000);
}


/**
 * requestObdValue();
 */
void requestObdValue()
{
  char readChar;
  boolean complete = 0;

  //char* parameter;
  Serial1.println("ATRV");
  // Receive the command echo back from the OBD-II adaptor
  while(complete == 0)
  {
    if (Serial1.available() > 0) {
      incomingByte = Serial1.read();
      readChar = (int)incomingByte;
      Serial.print(readChar);
      if(readChar == 13)
      {
        complete = 1;
        Serial.println("");
        //Serial.println("done");
      }
    }
  }
  // Receive the actual value response from the OBD-II adaptor
  complete = 0;
  while(complete == 0)
  {
    if (Serial1.available() > 0) {
      incomingByte = Serial1.read();
      readChar = (int)incomingByte;
      Serial.print(readChar);
      if(readChar == 13)
      {
        complete = 1;
        Serial.println("");
        //Serial.println("done");
      }
    }
  }
}


/**
 */
void toggle(int pinNum) {
  digitalWrite(pinNum, !digitalRead(pinNum));
}
