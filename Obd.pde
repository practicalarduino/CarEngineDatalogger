/**
 * getObdValue
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
 * getRawObdResponse
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
