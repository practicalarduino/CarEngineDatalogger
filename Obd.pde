/**
 * getObdValue
 */
void getObdValue( byte mode, byte parameter )
{
  if(( mode == 0x01 ) && ( parameter == 0x0C ))
  {
    // 010C (RPM)
    byte obdRawValue[24];
    byte responseLength = 2;
    getRawObdResponse( mode, parameter, obdRawValue, responseLength );
    /*byte A = obdRawValue[0];
    byte B = obdRawValue[1]; */
    
    byte i = 0;
    while(i < 24) {
      HOST.print("b");
      HOST.print(i, DEC);
      HOST.print(": ");
      HOST.println(obdRawValue[i], BYTE);
      i++;
    }
    
    /* HOST.print( "RPM: " );
    HOST.println( obdRawValue[0], HEX );
    HOST.println( obdRawValue[1], HEX );
    HOST.println(((A*256) + B)/4); */
  } else if(( mode == 0x01 ) && ( parameter == 0x0D ))
  {
    // 010D (Vehicle speed)
    byte obdRawValue[10];
    byte responseLength = 1;
    getRawObdResponse( mode, parameter, obdRawValue, responseLength );
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
 * getRawObdResponse
 */
void getRawObdResponse( byte mode, byte parameter, byte* obdRawValue, byte responseLength )
{
  OBD.flush();  // Flush the receive buffer so we get a fresh reading
  //OBD.print( mode );
  //OBD.println( parameter );
  OBD.println( "010C" );
  //OBD.println();
  //OBD.println( "ATRV" );
  //OBD.print(13, HEX);
  byte i = 0;

  incomingByte = 1;
  //while(incomingByte != 0x0D)
  while(incomingByte != 0x3E)
  {
    if (OBD.available() > 0)
    {
      incomingByte = OBD.read();
      if(incomingByte == 0x0D)
      {
        HOST.println();
      } else {
        //HOST.print("r0: ");
        HOST.print(incomingByte, BYTE);
        obdRawValue[i] = incomingByte;
        i++;
      }
    }
    //delay(100);
  }
  /*incomingByte = 1;
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
  } */
}
