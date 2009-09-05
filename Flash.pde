void writeFloatToFlash( float value )
{
  //printFloat(value, 5);
  char buffer[25]; // just give it plenty to write out any values you want to test
  floatToString(buffer, value, 5);
  HOST.println(buffer);
  HOST.print("Length: ");
  int length = 0;
  char character;
  while(character != '\0')
  {
    character = buffer[length];
    length++;
  }
  HOST.println(length);
  FLASH.print("WRF ");
  FLASH.print(length - 1);
  FLASH.print(13, BYTE);
  FLASH.print(buffer);
}


void writeLongToFlash( long value )
{
  int length = 1;
  long x = value;             // need to copy valToWrite as getting no of characters will consume it
  while ( x >= 10 ) {         // counts the characters in the number
    length++;              // thanks to D Mellis for this bit
    x /= 10;     
  }
  HOST.println(value);
  HOST.print("Length: ");
  HOST.println(length);
  FLASH.print("WRF ");
  FLASH.print(length);
  FLASH.print(13, BYTE);
  FLASH.print(value);
}








void writeFloatToFlashOld( float value )
{
  if(value < 0)
  {
    HOST.println("It's negative");
    FLASH.print("WRF 1");
    FLASH.print(13, BYTE);
    FLASH.print(45, BYTE);  // -
    value *= -1.0;
  }
  HOST.print("Sign-corrected value: ");
  printFloat(value, 5);
  HOST.println();
  int partLen = 2;   // 1 extra for the decimal point
  long int sendPart;
  sendPart = int(value);
  
  long int x = sendPart;
  while(x >= 10) {
    partLen++;
    x/=10;
  }
  HOST.println(sendPart);
  HOST.println(partLen);
  /* FLASH.print("WRF ");
  FLASH.print(partLen);
  FLASH.print(13, BYTE);
  FLASH.print(sendPart);
  FLASH.print('.'); */
  FLASH.print("WRF ");
  FLASH.print('4');
  FLASH.print(13, BYTE);
  FLASH.print('145');
  FLASH.print('.');
  
  
  partLen = 1;   //
  sendPart = long((value - long(value)) * 100000);

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
