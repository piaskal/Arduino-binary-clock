#include "Wire.h"

int latchPin = 8;
int clockPin = 12;
int dataPin = 11;
int clockAddress = 0xA3 >> 1;
int hourButtonPin = 2;
int minuteButtonPin = 3;


void setup() {
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  pinMode(hourButtonPin, INPUT);
  pinMode(minuteButtonPin, INPUT);
  Wire.begin();
//  Serial.begin(115200);
  initClock() ;
}

byte bcdSecond;
byte bcdMinute;
byte bcdHour;


boolean lastHourPressed = false;
boolean lastMinutePressed = false;

void loop() {
 
  Wire.beginTransmission(clockAddress);
  Wire.send(2); //start reading from clock register 2
  Wire.endTransmission();
  
  Wire.requestFrom(clockAddress, 3);
  bcdSecond= Wire.receive();
  bcdMinute= Wire.receive();
  bcdHour= Wire.receive();
  
  boolean hourPressed = digitalRead(hourButtonPin) == HIGH;
  boolean minutePressed = digitalRead(minuteButtonPin) == HIGH;
  boolean clockUpdateNeeded = false;
  
  if ((lastHourPressed != hourPressed) && hourPressed) { 
    clockUpdateNeeded = true;
    int hour = decodeBCD(bcdHour) + 1;
    if (hour > 23) hour = 0;
    bcdHour = encodeBCD(hour);
  }
  lastHourPressed = hourPressed;
  
  if  ((lastMinutePressed != minutePressed) && minutePressed) {
    clockUpdateNeeded = true;
    int minute =  decodeBCD(bcdMinute) + 1;
    if (minute > 59) minute = 0;
    bcdMinute = encodeBCD(minute);
  }
  lastMinutePressed = minutePressed;
    
  if(clockUpdateNeeded) {
    setTime(bcdHour, bcdMinute, 0);
  }

  digitalWrite(latchPin, LOW);
  shiftOut(dataPin, clockPin, MSBFIRST, bcdHour);  
  shiftOut(dataPin, clockPin, MSBFIRST, bcdMinute);   
  shiftOut(dataPin, clockPin, MSBFIRST, bcdSecond);  
  digitalWrite(latchPin, HIGH);
}


byte decodeBCD(byte bcdValue)
{
 return  (10 * (bcdValue >> 4)) + (0xf & bcdValue);
}

byte encodeBCD(byte value)
{
  return ((value/10)<< 4) | (value % 10);
}

void setTime(byte hour, byte minute, byte second)
{
  Wire.beginTransmission(clockAddress);	
  Wire.send(2); //start writing from clock register 2
  Wire.send(second); 
  Wire.send(minute); 
  Wire.send(hour); 
  Wire.endTransmission();
}

void initClock() 
{
  Wire.beginTransmission(clockAddress);	
  Wire.send(0);  
  for (int i=0;i<16;i++) //load 0 into all 16 clock registers
    Wire.send(0); 	
  Wire.endTransmission();
}
