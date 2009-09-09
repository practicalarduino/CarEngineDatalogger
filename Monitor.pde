/**
 * processHostCommands
 */
void processHostCommands()
{
  // Check for state change from the front panel button
  if(logActive && !digitalRead(LOG_LED))
  {
    logActive = 0;
    digitalWrite(FLASH_STATUS_LED, LOW);
    FLASH.print("CLF ARDUINO.TXT");
    FLASH.print(13, BYTE);
    HOST.println("Stop logging");
  }
  if( !logActive && digitalRead(LOG_LED))
  {
    logActive = 1;
    digitalWrite(FLASH_STATUS_LED, HIGH);
    FLASH.print("OPW ARDUINO.TXT");
    FLASH.print(13, BYTE);
    HOST.println("Start logging");
  }
  
  // Check for commands from the host
  if( HOST.available() > 0)
  {
    char readChar = HOST.read();

    if(readChar == '1')
    {                                       // Open file and start logging
      HOST.println("Start logging");
      logActive = 1;
      digitalWrite(FLASH_STATUS_LED, HIGH);
      digitalWrite(LOG_LED, HIGH);
      FLASH.print("OPW ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if( readChar == '2') {           // Stop logging and close file
      HOST.println("Stop logging");
      if(digitalRead(FLASH_RTS_PIN) == HIGH)
      {
        HOST.println("VDIP BUFFER FULL");
      }
      logActive = 0;
      digitalWrite(FLASH_STATUS_LED, LOW);
      digitalWrite(LOG_LED, LOW);
      FLASH.print("CLF ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if (readChar == '3'){            // Display the file
      HOST.println("Reading file");
      FLASH.print("RD ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if (readChar == '4'){            // Delete the file
      HOST.println("Deleting file");
      FLASH.print("DLF ARDUINO.TXT");
      FLASH.print(13, BYTE);
    } else if (readChar == '5'){            // Directory listing
      HOST.println("Directory listing");
      FLASH.print("DIR");
      FLASH.print(13, BYTE);  
    } else if (readChar == '6'){            // Reset the VDIP  
      HOST.print(" * Initialising flash storage   ");
      pinMode(FLASH_RESET, OUTPUT);
      digitalWrite(FLASH_RESET, LOW);
      delay( 100 );
      digitalWrite(FLASH_RESET, HIGH);
      delay( 100 );
      FLASH.print("IPA");  // Sets the VDIP to ASCII mode
      FLASH.print(13, BYTE);
      HOST.println("[OK]");
    } else {                                // HELP!
      HOST.print("Unrecognised command '");
      HOST.print(readChar);
      HOST.println("'");
      HOST.println("1 - Start logging");
      HOST.println("2 - Stop logging");
      HOST.println("3 - Display logfile");
      HOST.println("4 - Delete logfile");
      HOST.println("5 - Directory listing");
      HOST.println("6 - Reset VDIP module");
    }
  }
}

/**
 * modeButton
 * ISR attached to falling-edge interrupt 1 on digital pin 3
 */
void modeButton()
{
  if((millis() - logButtonTimestamp) > 300)
  {
    logButtonTimestamp = millis();
    //HOST.println(logButtonTimestamp);
    digitalWrite(LOG_LED, !digitalRead(LOG_LED));
  }
}

/**
 * powerFail
 * ISR attached to falling-edge interrupt 0 on digital pin 2
 */
void powerFail()
{
  HOST.println();
  HOST.println("     POWER FAIL!     ");
  /* while(1 == 1)
  {
    HOST.println(".");
  } */
}
