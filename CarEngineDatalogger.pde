/**
 * CarEngineDatalogger
 *
 * Reads engine management system data using an OBD-II interface and
 * GPS data from a Locosys LS20031 module, and writes the values to a
 * USB memory stick using a VDIP1 module from FTDI.
 *
 * This implementation relies on the extra UARTs available in an
 * Arduino Mega. It could alternatively use SoftwareSerial and run on
 * a Duemilanove or similar, but there may be problems with maintaining
 * several serial ports running at moderately high speed simultaneously.
 *
 * Serial connections are:
 *   Serial  = host computer           38400bps
 *   Serial1 = OBD-II interface        38400bps
 *   Serial2 = GPS module              57600bps
 *   Serial3 = Vinculum flash storage   9600bps
 *
 * Copyright 2009 Jonathan Oxer <jon@oxer.com.au>
 * Copyright 2009 Hugh Blemings <hugh@blemings.org>
 * http://www.practicalarduino.com/projects/car-engine-datalogger
 */

// Include the floatToString helper
#include "floatToString.h"

// Use the TinyGPS library to parse GPS data
#include <TinyGPS.h>
TinyGPS gps;

// We need the PString library to create a log buffer
#include <PString.h>

#define ledPin 13
int incomingByte = 0;  // for incoming serial data
char readChar;

// Host serial connection setup
#define HOST Serial
byte logActive = 0;

// OBD-II interface setup
#define OBD Serial1

// GPS module setup
#define GPS Serial2

// Vinculum setup
#define FLASH Serial3        // Serial port for VDIP connection
#define FLASH_RESET      12  // Pin for reset of VDIP module (active low)
#define FLASH_STATUS_LED 11  // LED to show whether a file is open
#define FLASH_WRITE_LED  10  // LED to show when write is in progress
#define FLASH_RTS_PIN     9  // Check if the VDIP is ready to receive. Active low

void gpsdump(TinyGPS &gps);
bool feedgps();
void printFloat(double f, int digits = 2);
//char * floatToString(char * outstr, float value, int places, int minwidth=0, bool rightjustify=false);


/**
 * Initial configuration
 */
void setup() {
  pinMode(ledPin, OUTPUT);
  HOST.begin(38400);   // Port for connection to host
  HOST.println("Car Engine Datalogger starting up");

  // Set up the GPS device
  HOST.print(" * Initialising GPS             ");
  GPS.begin(57600);    // Port for connection to GPS module
  HOST.println("[OK]");
  
  // Set up the OBD-II interface
  /* HOST.print(" * Initialising OBD-II          ");
  OBD.begin(38400);    // Port for connection to OBD adaptor
  HOST.println("[OK]");
  */

  // Set up the Vinculum flash storage device
  HOST.print(" * Initialising flash storage   ");
  pinMode(FLASH_STATUS_LED, OUTPUT);
  digitalWrite(FLASH_STATUS_LED, HIGH);
  
  pinMode(FLASH_WRITE_LED, OUTPUT);
  digitalWrite(FLASH_WRITE_LED, LOW);
  
  pinMode(FLASH_RTS_PIN, INPUT);
  
  pinMode(FLASH_RESET, OUTPUT);
  digitalWrite(FLASH_RESET, LOW);
  digitalWrite(FLASH_STATUS_LED, HIGH);
  digitalWrite(FLASH_WRITE_LED, HIGH);
  delay( 100 );
  digitalWrite(FLASH_RESET, HIGH);
  delay( 100 );
  FLASH.begin(9600);   // Port for connection to Vinculum flash memory module
  FLASH.print("IPA");  // Sets the VDIP to ASCII mode
  FLASH.print(13, BYTE);
  
  
  digitalWrite(FLASH_STATUS_LED, LOW);
  digitalWrite(FLASH_WRITE_LED, LOW);
  HOST.println("[OK]");
}


/**
 * Main program loop
 */
void loop()
{
  // Check for commands from the host
  if (HOST.available() > 0)
  {
    processCommand( HOST.read() );
  }
  
  // Echo data from flash to the host
  while (FLASH.available() > 0)
  {
    incomingByte = FLASH.read();
    if(incomingByte == 13) {
      Serial.println();
    }
    Serial.print(incomingByte, BYTE);
  }
  
  // Only do stuff if we're in logging mode
  if(logActive == 1)
  {
    if (feedgps())  // Only do a log write if we have GPS data
    {
      // Log entry fields:
      // Date, Time, Lat, Lon, Altitude (m), Speed (km/h)

      // Set up an 80-character buffer for writing to the memory stick
      char flashBuffer[80];
      PString logEntry(flashBuffer, sizeof(flashBuffer)); // Create a PString object called logEntry
      char valBuffer[15]; // Buffer for converting floats to strings before appending to flashBuffer
      
      digitalWrite(FLASH_WRITE_LED, HIGH);
      //HOST.println("Acquired Data");
      //HOST.println("-------------");
      //gpsdump(gps);
      //HOST.println("-------------");
      float fLat, fLon;
      unsigned long age, date, time, chars;
      int year;
      byte month, day, hour, minute, second, hundredths;
      //unsigned short sentences, failed;
      
      gps.f_get_position(&fLat, &fLon, &age);
      gps.get_datetime(&date, &time, &age);
      gps.crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths, &age);
      
      //logEntry += millis();
      //logEntry += ",";
      
      floatToString(valBuffer, year, 0);
      logEntry += valBuffer;
      logEntry += "-";
      floatToString(valBuffer, static_cast<int>(month), 0);
      logEntry += valBuffer;
      logEntry += "-";
      floatToString(valBuffer, static_cast<int>(day), 0);
      logEntry += valBuffer;
      logEntry += ",";
      
      floatToString(valBuffer, static_cast<int>(hour), 0);
      logEntry += valBuffer;
      logEntry += ":";
      floatToString(valBuffer, static_cast<int>(minute), 0);
      logEntry += valBuffer;
      logEntry += ":";
      floatToString(valBuffer, static_cast<int>(second), 0);
      logEntry += valBuffer;
      logEntry += ".";
      floatToString(valBuffer, static_cast<int>(hundredths), 0);
      logEntry += valBuffer;
      logEntry += ",";
      
      floatToString(valBuffer, fLat, 5);
      logEntry += valBuffer;
      logEntry += ",";

      floatToString(valBuffer, fLon, 5);
      logEntry += valBuffer;
      logEntry += ",";
      
      floatToString(valBuffer, gps.f_altitude(), 2);
      logEntry += valBuffer;
      logEntry += ",";
      
      floatToString(valBuffer, gps.f_speed_kmph(), 2);
      logEntry += valBuffer;
      //logEntry += ",";


      /////////////////////// START WRITE TO FILE //////////////////////////////
      //int logEntryLength = logEntry.length();
      byte position = 0;
      
      HOST.print(logEntry.length());
      HOST.print(": ");
      HOST.println(logEntry);
      
      FLASH.print("WRF ");
      FLASH.print(logEntry.length() + 1);  // 1 extra for the newline
      FLASH.print(13, BYTE);
      
      while(position < logEntry.length())
      {
        if(digitalRead(FLASH_RTS_PIN) == LOW)
        {
          FLASH.print(flashBuffer[position]);
          position++;
        } else {
          HOST.println("BUFFER FULL");
        }
      }
      
      FLASH.print(13, BYTE);               // End the log entry with a newline
      /////////////////////// END WRITE TO FILE //////////////////////////////
      digitalWrite(FLASH_WRITE_LED, LOW);
      
      /*if(digitalRead(FLASH_RTS_PIN) == HIGH)
      {
        HOST.println("Oops, it's high");
      } */
      delay( 500 );  // Delay if we've written a log entry
    }
  }
  
  
  //byte mode = 0x0;
  //byte parameter = 0x0;
  
  /* HOST.println( "Getting RPM reading" );
  mode = 0x01;
  parameter = 0x0C;
  getObdValue( mode, parameter );
  HOST.println("done");
  delay( 100 ); */
  
  /* HOST.println( "Getting speed reading" );
  mode = 0x01;
  parameter = 0x0D;
  getObdValue( mode, parameter );
  HOST.println("done");
  */
  //delay( 5000 );
  /*
  if (OBD.available() > 0) {
      incomingByte = OBD.read();
      readChar = (int)incomingByte;
      //response = readChar;
      if((incomingByte == 0x3E) || (incomingByte == 0x0D))   // The hex value for the ">" prompt returned by the ELM327
      {
        HOST.println();
      } else {
        HOST.print(readChar);
      }
    }
  */
}
