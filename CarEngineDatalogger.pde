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
#define FLASH Serial3


void gpsdump(TinyGPS &gps);
bool feedgps();
void printFloat(double f, int digits = 2);

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
  FLASH.begin(9600);   // Port for connection to Vinculum flash memory module
  FLASH.print("IPA");  // Sets the VDIP to ASCII mode
  FLASH.print(13, BYTE);
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
      FLASH.print("OPW ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if( readChar == '2') {           // Stop logging and close file
      HOST.println("Stop logging");
      logActive = 0;
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
    } else {                                // HELP!
      HOST.print("Unrecognised command '");
      HOST.print(readChar);
      HOST.println("'");
      HOST.println("1 - Start logging");
      HOST.println("2 - Stop logging");
      HOST.println("3 - Display logfile");
      HOST.println("4 - Delete logfile");
    }
    
  }
  
  // Echo data from flash to the host
  if (FLASH.available() > 0)
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
    if (feedgps())
    {
      HOST.println("Acquired Data");
      HOST.println("-------------");  
      //gpsdump(gps);
      //HOST.println("-------------");
      float fLat, fLon;
      unsigned long age, date, time, chars;
      int year;
      byte month, day, hour, minute, second, hundredths;
      unsigned short sentences, failed;
    
      /* HOST.print(" Fix age: ");
      HOST.print(age);
      HOST.println("ms."); */
      
      gps.f_get_position(&fLat, &fLon, &age);
      HOST.print("Lat/Long(float): ");
      printFloat(fLat, 5);
      HOST.print(", ");
      printFloat(fLon, 5);
      HOST.println();
      
      //////////////////////////////////////////////////////////////
      //writeFloatToFlash( fLat );

      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(",");
      
      //////////////////////////////////////////////////////////////
      writeFloatToFlash( fLon );

      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(",");
      
      /*int lonLen = 10;
      HOST.println(lonLen);
      FLASH.print("WRF ");
      FLASH.print(lonLen + 1);
      FLASH.print(13, BYTE);
      FLASH.print(fLon);
      FLASH.print(13, BYTE);
      */
      
      // End the dataset with a newline
      FLASH.print("WRF 1");
      FLASH.print(13, BYTE);
      FLASH.print(13, BYTE);
      HOST.println("-------------------------------------");
      
      /*FLASH.print("WRF ");          //write to file (file needs to have been opened to write first)
      
      FLASH.print(8, DEC);
      FLASH.print(13, BYTE);        //return to say command is finished
      FLASH.print(fLat);
      FLASH.print(13, BYTE);*/
    }
    /* FLASH.print("WRF ");          //write to file (file needs to have been opened to write first)
    FLASH.print(numOfChars);       //needs to then be told how many characters will be written
    FLASH.print(13, BYTE);        //return to say command is finished
    FLASH.print(gpsReading);
    FLASH.print(13, BYTE); */
    
    /*FLASH.print("WRF ");          //write to file (file needs to have been opened to write first)
    FLASH.print(8, DEC);
    FLASH.print(13, BYTE);        //return to say command is finished
    FLASH.print(1234567);
    FLASH.print(13, BYTE);
    //HOST.println("done"); */
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
