/**
 * getObdValue
 */
//void getObdValue( char* mode, char* parameter )
void getObdValue( char *pid, class PString *logEntry )
{
  if( pid == "010C" ) // RPM
  {
    int obdResponse[2];
    byte responseLength = 2;
    getRawObdResponse( pid, obdResponse );
    /*
    byte A = obdResponse[0];
    byte B = obdResponse[1];
    HOST.print( "RPM: " );
    HOST.println( obdRawValue[0], HEX );
    HOST.println( obdRawValue[1], HEX );
    HOST.println(((A*256) + B)/4); */
  } else if( pid == "010D" )
  {
    // 010D (Vehicle speed)
    // blah blah blah
  } else {
    HOST.print("unknown parameter");
  }
}


/**
 * getRawObdResponse
 */
void getRawObdResponse( char *pid, int *obdResponse )
{
  byte i = 0;
  byte incomingByte;

  OBD.flush();  // Flush the receive buffer so we get a fresh reading
  OBD.println( pid );

  while( incomingByte != '>' )    // 0x3E is the ">" prompt returned by the adaptor
  {
    if( OBD.available() > 0 )
    {
      incomingByte = OBD.read();
      if( incomingByte != 0x0D )
      {
        //HOST.print(incomingByte, BYTE);
        obdResponse[i] = incomingByte;
        //obdResponse[i] = strtoul(incomingByte, NULL, 16);  // 16 = hex
        i++;
      } else {
        //HOST.println();
      }
      obdResponse[i++] = '\0';  // Add a null character to the end
    }
  }
}


/**
 * configureObdAdapter
 */
void configureObdAdapter()
{
  OBD.println( "ATZ" );   // Force a reset of the adapter
  OBD.println( "ATE0" );  // Disable command echo
  OBD.println( "ATS0" );  // Disable spaces between response bytes
}


/**
 */
float obdConvert_0104( unsigned int A, unsigned int B, unsigned int C, unsigned int D ) {
  return (float)A*100.0f/255.0f;
}


// From http://code.google.com/p/opengauge/source/browse/trunk/obduino/obduino.pde
// for inspiration
byte elm_compact_response(byte *buf, char *str)
{
  byte i=0;

  // start at 6 which is the first hex byte after header
  // ex: "41 0C 1A F8"
  // return buf: 0x1AF8
  // NB: it's not 6 for us, because we suppress command echo and spaces
  //str+=6;
  while(*str!='\0')
    buf[i++]=strtoul(str, &str, 16);  // 16 = hex

  return i;
}
