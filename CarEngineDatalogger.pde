/**
 * CarEngineDatalogger
 *
 * Reads engine management system data using an OBD-II interface.
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
 * http://www.practicalarduino.com/projects/car-engine-datalogger
 */

// Use the TinyGPS library to parse GPS data
#include <TinyGPS.h>
TinyGPS gps;

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
//#define FLASH_STATUS_LED 11
//#define FLASH_WRITE_LED  10

void gpsdump(TinyGPS &gps);
bool feedgps();
void printFloat(double f, int digits = 2);
char * floatToString(char * outstr, float value, int places, int minwidth=0, bool rightjustify=false);

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
  //pinMode(FLASH_STATUS_LED, OUTPUT);
  //digitalWrite(FLASH_STATUS_LED, HIGH);
  
  //pinMode(FLASH_WRITE_LED, OUTPUT);
  //digitalWrite(FLASH_WRITE_LED, LOW);
  
  pinMode(FLASH_RESET, OUTPUT);
  digitalWrite(FLASH_RESET, LOW);
  //digitalWrite(FLASH_STATUS_LED, HIGH);
  //digitalWrite(FLASH_WRITE_LED, HIGH);
  delay( 100 );
  digitalWrite(FLASH_RESET, HIGH);
  delay( 100 );
  FLASH.begin(9600);   // Port for connection to Vinculum flash memory module
  FLASH.print("IPA");  // Sets the VDIP to ASCII mode
  FLASH.print(13, BYTE);
  //digitalWrite(FLASH_STATUS_LED, LOW);
  //digitalWrite(FLASH_WRITE_LED, LOW);
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
    incomingByte = HOST.read();
    readChar = (int)incomingByte;
    if(readChar == '1')
    {                                       // Open file and start logging
      HOST.println("Start logging");
      logActive = 1;
      //digitalWrite(FLASH_STATUS_LED, HIGH);
      FLASH.print("OPW ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if( readChar == '2') {           // Stop logging and close file
      HOST.println("Stop logging");
      logActive = 0;
      //digitalWrite(FLASH_STATUS_LED, LOW);
      FLASH.print("CLF ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if (readChar == '3'){            // Display the file
      HOST.println("Reading file");
      FLASH.print("RD ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if (readChar == '4'){            // Delete the file
      HOST.println("Deleting file");
      FLASH.print("DLF ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if (readChar == '5'){            // Directory listing
      HOST.println("Directory listing");
      FLASH.print("DIR");
      FLASH.print(13, BYTE);  
    } else if (readChar == '6'){            // Reset the VDIP  
      HOST.print(" * Initialising flash storage   ");
      pinMode(FLASH_RESET, OUTPUT);
      digitalWrite(FLASH_RESET, LOW);
      delay( 100 );
      digitalWrite(FLASH_RESET, HIGH);
      delay( 100 );
      FLASH.print("IPA");  // Sets the VDIP to ASCII mode
      FLASH.print(13, BYTE);
      HOST.println("[OK]");
    } else {                                // HELP!
      HOST.print("Unrecognised command '");
      HOST.print(readChar);
      HOST.println("'");
      HOST.println("1 - Start logging");
      HOST.println("2 - Stop logging");
      HOST.println("3 - Display logfile");
      HOST.println("4 - Delete logfile");
      HOST.println("5 - Directory listing");
      HOST.println("6 - Reset VDIP module");
    }
    
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
    HOST.println("Logging");
    
    if (feedgps())  // Only do a log write if we have GPS data
    {
      //digitalWrite(FLASH_WRITE_LED, HIGH);
      HOST.println("Acquired Data");
      HOST.println("-------------");  
      gpsdump(gps);
      HOST.println("-------------");
      float fLat, fLon;
      unsigned long age, date, time, chars;
      //int year;
      //byte month, day, hour, minute, second, hundredths;
      //unsigned short sentences, failed;
      
      gps.f_get_position(&fLat, &fLon, &age);
      gps.get_datetime(&date, &time, &age);
      
      HOST.print("Lat/Long(float): ");
      printFloat(fLat, 5);
      HOST.print(", ");
      printFloat(fLon, 5);
      HOST.println();
      
      /////////////////////// START WRITE TO FILE //////////////////////////////
      HOST.println("------------- START WRITE TO FILE -----------------");
      
      /* writeLongToFlash( date );
      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(44, BYTE);  // ,  */
      
      /*writeLongToFlash( time );
      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(44, BYTE);  // ,  */
      
      writeFloatToFlash( fLat );
      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(44, BYTE);  // ,
      
      writeFloatToFlash( fLon );
      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(44, BYTE);  // ,

      // End the dataset with a newline
      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(13, BYTE);
      
      HOST.println("------------- END WRITE TO FILE -------------------");
      /////////////////////// END WRITE TO FILE //////////////////////////////
      //digitalWrite(FLASH_WRITE_LED, LOW);
    }
    delay( 1500 );
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
