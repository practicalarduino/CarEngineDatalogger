/**
 * gpsdump
 * From the example code included in the TinyGPS library
 */
void gpsdump(TinyGPS &gps)
{
  long lat, lon;
  float flat, flon;
  unsigned long age, date, time, chars;
  int year;
  byte month, day, hour, minute, second, hundredths;
  unsigned short sentences, failed;

  gps.get_position(&lat, &lon, &age);
  Serial.print("Lat/Long(10^-5 deg): "); Serial.print(lat); Serial.print(", "); Serial.print(lon); 
  Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");
  
  feedgps(); // If we don't feed the gps during this long routine, we may drop characters and get checksum errors

  gps.f_get_position(&flat, &flon, &age);
  Serial.print("Lat/Long(float): "); printFloat(flat, 5); Serial.print(", "); printFloat(flon, 5);
  Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");

  feedgps();

  gps.get_datetime(&date, &time, &age);
  Serial.print("Date(ddmmyy): "); Serial.print(date);
  Serial.print(" Time(hhmmsscc): "); Serial.print(time);
  Serial.print(" Fix age: "); Serial.print(age); Serial.println("ms.");

  feedgps();

  gps.crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths, &age);
  Serial.print("Date: "); Serial.print(static_cast<int>(month));
  Serial.print("/"); Serial.print(static_cast<int>(day));
  Serial.print("/"); Serial.print(year);
  Serial.print("  Time: "); Serial.print(static_cast<int>(hour));
  Serial.print(":"); Serial.print(static_cast<int>(minute));
  Serial.print(":"); Serial.print(static_cast<int>(second));
  Serial.print("."); Serial.print(static_cast<int>(hundredths));
  Serial.print("  Fix age: ");  Serial.print(age); Serial.println("ms.");
  
  feedgps();

  Serial.print("Alt(cm): "); Serial.print(gps.altitude());
  Serial.print(" Course(10^-2 deg): "); Serial.print(gps.course());
  Serial.print(" Speed(10^-2 knots): "); Serial.print(gps.speed());
  Serial.println();
  Serial.print("Alt(float): "); printFloat(gps.f_altitude());
  Serial.print(" Course(float): "); printFloat(gps.f_course());
  Serial.println();
  Serial.print("Speed(knots): "); printFloat(gps.f_speed_knots());
  Serial.print(" (mph): ");  printFloat(gps.f_speed_mph());
  Serial.print(" (mps): "); printFloat(gps.f_speed_mps());
  Serial.print(" (kmph): "); printFloat(gps.f_speed_kmph());
  Serial.println();

  feedgps();

  gps.stats(&chars, &sentences, &failed);
  Serial.print("Stats: characters: "); Serial.print(chars);
  Serial.print(" sentences: "); Serial.print(sentences);
  Serial.print(" failed checksum: "); Serial.println(failed);
}

/**
 * feedgps
 */
bool feedgps()
{
  while (GPS.available())
  {
    if (gps.encode(GPS.read()))
      return true;
  }
  return false;
}
