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
 *   Serial2 = GPS module              38400bps
 *   Serial3 = Vinculum flash storage  9600bps
 *
 * Copyright 2009 Jonathan Oxer <jon@oxer.com.au>
 * http://www.practicalarduino.com/projects/hard/car-engine-datalogger
 */

#define ledPin 13
#define HOST Serial
int incomingByte = 0;  // for incoming serial data
char readChar;

// OBD-II interface setup
#define OBD Serial1

// GPS module setup
#define GPS Serial2
char gpsReading[80];   // To store the reading in

// Vinculum setup
#define FLASH Serial3
int fileNumber = 1;
int noOfChars;
byte valToWrite;

/**
 * Initial configuration
 */
void setup() {
  pinMode(ledPin, OUTPUT);
  HOST.begin(38400);   // Port for connection to host
  HOST.println("Car Engine Datalogger starting up");

  // Set up the Vinculum flash storage device
  HOST.print(" * Initialising GPS             ");
  GPS.begin(38400);    // Port for connection to Vinculum flash memory module
  HOST.println("[OK]");
  
  // Set up the OBD-II interface
  HOST.print(" * Initialising OBD-II          ");
  OBD.begin(38400);    // Port for connection to Vinculum flash memory module
  HOST.println("[OK]");

  // Set up the Vinculum flash storage device
  HOST.print(" * Initialising flash storage   ");
  FLASH.begin(9600);   // Port for connection to Vinculum flash memory module
  FLASH.print("IPA");  // Sets the VDIP to ASCII mode
  FLASH.print(13, BYTE);
  HOST.println("[OK]");
  
  /*delay(5000);
  HOST.println("Checking firmware version:");
  FLASH.print("FWV");           // Asks for the firmware version
  FLASH.print(13, BYTE);
  while(incomingByte != 13 )
  {
    if (FLASH.available() > 0) {
      incomingByte = FLASH.read();
      HOST.print(incomingByte, BYTE);
    }
  }
  HOST.println(); */
}


/**
 * Main program loop
 */
void loop()
{  
  //HOST.println( "Getting GPS reading" );
  getGpsReading( gpsReading );
  HOST.println( gpsReading );
  //HOST.println("done");
  delay( 100 );
  
  byte mode = 0x0;
  byte parameter = 0x0;
  
  /* HOST.println( "Getting RPM reading" );
  mode = 0x01;
  parameter = 0x0C;
  getObdValue( mode, parameter );
  HOST.println("done");
  delay( 100 ); */
  
  HOST.println( "Getting speed reading" );
  mode = 0x01;
  parameter = 0x0D;
  getObdValue( mode, parameter );
  HOST.println("done");
  delay( 5000 );
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
 * Wait for the next GPS reading and return it
 */
void getGpsReading( char* gpsReading)
{
  byte i = 0;

  GPS.flush();  // Flush the receive buffer so we get a fresh reading

  incomingByte = 1;
  while((incomingByte != 0x0D) && (i < 81))
  {
    if (GPS.available() > 0)
    {
      incomingByte = GPS.read();
      readChar = (int)incomingByte;
      gpsReading[i] = readChar;
      i++;
    }
  }
  gpsReading[i] = '\0';   // Null-terminate the string
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


/**
 */
void toggle(int pinNum) {
  digitalWrite(pinNum, !digitalRead(pinNum));
}
