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
 *   Serial  = host computer
 *   Serial1 = OBD-II interface
 *   Serial2 = GPS module
 *   Serial3 = Vinculum flash storage
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
  
  //delay(1000);
  //Serial.println("Sending ATRV");
  //Serial1.println("ATRV");
  //requestObdValue();
}


/**
 * Main program loop
 */
void loop()
{  
  HOST.println( "Getting GPS reading" );
  getGpsReading( gpsReading );
  HOST.println( gpsReading );
  delay( 5000 );
  
  HOST.println( "Getting RPM reading" );
  byte mode = 0x01;
  byte parameter = 0x0C;
  getObdValue( mode, parameter );
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
 * requestObdValue();
 */
void requestObdValue()
{
  int i;
  char responseValue[8];
  //char responseCode[8];

  HOST.println("Sent ATRV");
  OBD.println("ATRV");
  
  /*Serial.print(responseValue[0], HEX);
  Serial.print(responseValue[1], HEX);
  Serial.print(responseValue[2], HEX);
  Serial.print(responseValue[3], HEX);
  Serial.print(responseValue[4], HEX);
  Serial.print(responseValue[5], HEX);
  Serial.print(responseValue[6], HEX); */
  //Serial.println("===========================");
  //delay(1000);
}


/**
 */
void readObdResponse()
{
  int incomingByte = 0;  // for incoming serial data
  char readChar;
  int i = 0;
  //char response[8];
  boolean complete = 0;
  //Serial.print("Reading: ");
  while(complete == 0)
  {
    if (OBD.available() > 0) {
      incomingByte = OBD.read();
      readChar = (int)incomingByte;
      //response = readChar;
      
      HOST.print(readChar);
      if(readChar == 13)
      {
        complete = 1;
        //Serial.print("");
      //} else {
        //Serial.print(readChar);
        //response[i] = incomingByte;
        //i++;
      }
    }
  }
  HOST.println("");
  //Serial.println(" done");
  
  /*Serial.print("Hex response: ");
  while(response[i]) {
    Serial.print(response[i], HEX);
    i++;
  }
  Serial.println(" done");*/
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
  //gpsReading[i] = '\0';   // Null-terminate the string
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
    HOST.print( "RPM: " );
    HOST.print( obdRawValue[0], HEX );
    HOST.println( obdRawValue[1], HEX );
  } else {
    HOST.print("unknown parameter");
  }
}

/**
 */
void getRawObdResponse( byte mode, byte parameter, byte* obdRawValue, byte length )
{
  OBD.flush();  // Flush the receive buffer so we get a fresh reading
  //OBD.print( mode );
  //OBD.print( parameter );
  OBD.println( "ATRV" );
  //OBD.print(13, HEX);
  byte i = 0;

  incomingByte = 1;
  while(incomingByte != 0x0D)
  {
    if (OBD.available() > 0)
    {
      incomingByte = OBD.read();
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
