/**
 * processFlashBuffer
 */
void processFlashBuffer()
{
  byte incomingByte;
  
  while (FLASH.available() > 0)
  {
    incomingByte = FLASH.read();
    if(incomingByte == 13) {
      Serial.println();
    }
    Serial.print(incomingByte, BYTE);
  }
}
