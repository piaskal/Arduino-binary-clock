#include "Wire.h"

int latchPin = 8;
int clockPin = 12;
int dataPin = 11;
int clockAddress = 0xA3 >> 1;


void setup() {
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  Wire.begin();
  Serial.begin(115200);
  initClock() ;
}

int data[16];
int x = 0;
void loop() {
 
  Wire.beginTransmission(clockAddress);
  Wire.send(0);
  Wire.endTransmission();
  
  Wire.requestFrom(clockAddress, 16);
  for(int i=0;i<16;++i) {
    data[i] = Wire.receive();
  }
  
  

    for(int i=0;i<16;++i) {
      Serial.print(data[i]);
      Serial.print(", ");
    }
  Serial.println();

    digitalWrite(latchPin, LOW);
    
    shiftOut(dataPin, clockPin, MSBFIRST, data[4]);  
    shiftOut(dataPin, clockPin, MSBFIRST, data[3]);   
    shiftOut(dataPin, clockPin, MSBFIRST, data[2]);  

    digitalWrite(latchPin, HIGH);
    delay(1000);
}

void initClock() 
{
  Wire.beginTransmission(clockAddress);	// Issue I2C start signal
  Wire.send(0);  
  Wire.send(0); 	
  Wire.send(0); 	
  Wire.send(0x00); 	//seconds
  Wire.send(0x36);	//minutes
  Wire.send(0x22);	//hour
  /*
  Wire.send(0);	
  Wire.send(0);	
  Wire.send(0); 	
  Wire.send(0);	
  Wire.send(0);
  Wire.send(0);
  Wire.send(0);
  Wire.send(0);
  Wire.send(0);
  Wire.send(0);
  */
  Wire.endTransmission();
}
