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
