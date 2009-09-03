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
 * http://www.practicalarduino.com/projects/hard/car-engine-datalogger
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
//char gpsReading[81];   // To store the reading in

// Vinculum setup
#define FLASH Serial3
int fileNumber = 1;
int noOfChars;
char stringToLog[81];


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
      Serial.println("Reading file");
      FLASH.print("RD ARDUINO.TXT");
      FLASH.print(13, BYTE);
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
      
      int partLen = 2;   // Extra for the trailing newline
      int sendPart;
      sendPart = int(fLat);
      long int x = sendPart;
      if(x < 0) {    // Add a digit for a leading "-" on a negative number
        partLen++;
      }
      while(x >= 10 || x <= -10) {     // Number can be negative!
        partLen++;
        x/=10;
      }
      HOST.println(sendPart);
      HOST.println(partLen);
      FLASH.print("WRF ");
      FLASH.print(partLen);
      FLASH.print(13, BYTE);
      FLASH.print(sendPart, DEC);
      FLASH.println(13, BYTE);
      
      /*int lonLen = 10;
      HOST.println(lonLen);
      FLASH.print("WRF ");
      FLASH.print(lonLen + 1);
      FLASH.print(13, BYTE);
      FLASH.print(fLon);
      FLASH.print(13, BYTE);
      */
      
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



/**
 * gpsdump
 */
void gpsdump(TinyGPS &gps)
{
  long lat, lon;
  float flat, flon;
  unsigned long age, date, time, chars;
  int year;
  byte month, day, hour, minute, second, hundredths;
  unsigned short sentences, failed;

  gps.get_position(&lat, &lon, &age);
  Serial.print("Lat/Long(10^-5 deg): "); Serial.print(lat); Serial.print(", "); Serial.print(lon); 
  Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");
  
  feedgps(); // If we don't feed the gps during this long routine, we may drop characters and get checksum errors

  gps.f_get_position(&flat, &flon, &age);
  Serial.print("Lat/Long(float): "); printFloat(flat, 5); Serial.print(", "); printFloat(flon, 5);
  Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");

  feedgps();

  gps.get_datetime(&date, &time, &age);
  Serial.print("Date(ddmmyy): "); Serial.print(date); Serial.print(" Time(hhmmsscc): "); Serial.print(time);
  Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");

  feedgps();

  gps.crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths, &age);
  Serial.print("Date: "); Serial.print(static_cast<int>(month)); Serial.print("/"); Serial.print(static_cast<int>(day)); Serial.print("/"); Serial.print(year);
  Serial.print("  Time: "); Serial.print(static_cast<int>(hour)); Serial.print(":"); Serial.print(static_cast<int>(minute)); Serial.print(":"); Serial.print(static_cast<int>(second)); Serial.print("."); Serial.print(static_cast<int>(hundredths));
  Serial.print("  Fix age: ");  Serial.print(age); Serial.println("ms.");
  
  feedgps();

  Serial.print("Alt(cm): "); Serial.print(gps.altitude()); Serial.print(" Course(10^-2 deg): "); Serial.print(gps.course()); Serial.print(" Speed(10^-2 knots): "); Serial.println(gps.speed());
  Serial.print("Alt(float): "); printFloat(gps.f_altitude()); Serial.print(" Course(float): "); printFloat(gps.f_course()); Serial.println();
  Serial.print("Speed(knots): "); printFloat(gps.f_speed_knots()); Serial.print(" (mph): ");  printFloat(gps.f_speed_mph());
  Serial.print(" (mps): "); printFloat(gps.f_speed_mps()); Serial.print(" (kmph): "); printFloat(gps.f_speed_kmph()); Serial.println();

  feedgps();

  gps.stats(&chars, &sentences, &failed);
  Serial.print("Stats: characters: "); Serial.print(chars); Serial.print(" sentences: "); Serial.print(sentences); Serial.print(" failed checksum: "); Serial.println(failed);
}

/**
 * feedgps
 */
bool feedgps()
{
  while (GPS.available())
  {
    if (gps.encode(GPS.read()))
      return true;
  }
  return false;
}

/**
 * printFloat
 */
void printFloat(double number, int digits)
{
  // Handle negative numbers
  if (number < 0.0)
  {
     HOST.print('-');
     number = -number;
  }

  // Round correctly so that print(1.999, 2) prints as "2.00"
  double rounding = 0.5;
  for (uint8_t i=0; i<digits; ++i)
    rounding /= 10.0;
  
  number += rounding;

  // Extract the integer part of the number and print it
  unsigned long int_part = (unsigned long)number;
  double remainder = number - (double)int_part;
  HOST.print(int_part);

  // Print the decimal point, but only if there are digits beyond
  if (digits > 0)
    HOST.print("."); 

  // Extract digits from the remainder one at a time
  while (digits-- > 0)
  {
    remainder *= 10.0;
    int toPrint = int(remainder);
    HOST.print(toPrint);
    remainder -= toPrint; 
  } 
}

/**
 * toggle
 */
void toggle(int pinNum) {
  digitalWrite(pinNum, !digitalRead(pinNum));
}


void loop1()
{
  
  
  //HOST.println( "Getting GPS reading" );
  if(logActive == 1)
  {
    
    
    //HOST.println(numOfChars);
    
    /* FLASH.print("WRF ");          //write to file (file needs to have been opened to write first)
    FLASH.print(numOfChars);       //needs to then be told how many characters will be written
    FLASH.print(13, BYTE);        //return to say command is finished
    FLASH.print(gpsReading);
    FLASH.print(13, BYTE); */
    
    /* FLASH.print("WRF ");          //write to file (file needs to have been opened to write first)
    FLASH.print(8, DEC);
    FLASH.print(13, BYTE);        //return to say command is finished
    FLASH.print(1234567);
    FLASH.print(13, BYTE); */
    //HOST.println("done");
    delay( 1000 );
  }
  byte mode = 0x0;
  byte parameter = 0x0;
  
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




/**
 */
void getObdValue( byte mode, byte parameter )
{
  if(( mode == 0x01 ) && ( parameter == 0x0C ))
  {
    // 010C (RPM)
    byte obdRawValue[2];
    byte length = 2;
    getRawObdResponse( mode, parameter, obdRawValue, length );
    byte A = obdRawValue[0];
    byte B = obdRawValue[1];
    
    HOST.print( "RPM: " );
    HOST.println( obdRawValue[0], HEX );
    HOST.println( obdRawValue[1], HEX );
    HOST.println(((A*256) + B)/4);
  } else if(( mode == 0x01 ) && ( parameter == 0x0D ))
  {
    // 010D (Vehicle speed)
    byte obdRawValue[1];
    byte length = 1;
    getRawObdResponse( mode, parameter, obdRawValue, length );
    byte A = obdRawValue[0];
    
    HOST.print( "Speed: " );
    HOST.println( obdRawValue[0], HEX );
    HOST.println(A, DEC);
  } else {
    HOST.print("unknown parameter");
  }
  //HOST.println("ended");
}

/**
 */
void getRawObdResponse( byte mode, byte parameter, byte* obdRawValue, byte length )
{
  OBD.flush();  // Flush the receive buffer so we get a fresh reading
  //OBD.print( mode );
  //OBD.println( parameter );
  OBD.println( '010D' );
  //OBD.println();
  //OBD.println( "ATRV" );
  //OBD.print(13, HEX);
  byte i = 0;

  incomingByte = 1;
  while(incomingByte != 0x0D)
  {
    if (OBD.available() > 0)
    {
      incomingByte = OBD.read();
      HOST.print("r0: ");
      HOST.println(incomingByte, HEX);
    }
  }
  incomingByte = 1;
  while(incomingByte != 0x0D)
  {
    if (OBD.available() > 0)
    {
      incomingByte = OBD.read();
      HOST.print("r1: ");
      HOST.println(incomingByte, HEX);
      obdRawValue[i] = incomingByte;
      i++;
    }
  }
}

