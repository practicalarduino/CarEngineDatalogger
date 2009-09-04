/**
 * printFloat
 */
void printFloat(double number, int digits)
{
  // Handle negative numbers
  if (number < 0.0)
  {
     HOST.print('-');
     number = -number;
  }

  // Round correctly so that print(1.999, 2) prints as "2.00"
  double rounding = 0.5;
  for (uint8_t i=0; i<digits; ++i)
    rounding /= 10.0;
  
  number += rounding;

  // Extract the integer part of the number and print it
  unsigned long int_part = (unsigned long)number;
  double remainder = number - (double)int_part;
  HOST.print(int_part);

  // Print the decimal point, but only if there are digits beyond
  if (digits > 0)
    HOST.print("."); 

  // Extract digits from the remainder one at a time
  while (digits-- > 0)
  {
    remainder *= 10.0;
    int toPrint = int(remainder);
    HOST.print(toPrint);
    remainder -= toPrint; 
  } 
}

/**
 * toggle
 */
void toggle(int pinNum) {
  digitalWrite(pinNum, !digitalRead(pinNum));
}
