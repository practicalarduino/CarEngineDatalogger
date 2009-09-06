/**
 * processHostCommands
 */
void processHostCommands()
{
  if( HOST.available() > 0)
  {
    char readChar = HOST.read();

    if(readChar == '1')
    {                                       // Open file and start logging
      HOST.println("Start logging");
      logActive = 1;
      digitalWrite(FLASH_STATUS_LED, HIGH);
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
