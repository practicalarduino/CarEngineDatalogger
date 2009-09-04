void writeFloatToFlash( float value )
{
  if(value < 0)
  {
    FLASH.print("WRF 1");
    FLASH.print(13, BYTE);
    FLASH.print('-');
    value *= -1.0;
  }
  HOST.print("Sign-corrected value: ");
  printFloat(value, 5);
  int partLen = 1;   // 1 extra for the trailing decimal point
  int sendPart;
  sendPart = int(value);
  
  long int x = sendPart;
  while(x >= 10) {
    partLen++;
    x/=10;
  }
  HOST.println(sendPart);
  HOST.println(partLen);
  FLASH.print("WRF ");
  FLASH.print(partLen);
  FLASH.print(13, BYTE);
  FLASH.print(sendPart, DEC);
  FLASH.print('.');
  
  partLen = 1;   //
  sendPart = int((value - int(value)) * 100000);
  
  x = sendPart;
  while(x >= 10) {
    partLen++;
    x/=10;
  }
  HOST.println(sendPart);
  HOST.println(partLen);
  FLASH.print("WRF ");
  FLASH.print(partLen);
  FLASH.print(13, BYTE);
  FLASH.print(sendPart, DEC);
}
