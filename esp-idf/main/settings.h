#include "stdbool.h"
#include "driver/adc.h"

//Pins
#define pinPower 32 //cavo arancione
#define pinState 27 //transistor
#define SENSOR ADC1_CHANNEL_5 //sensore analogico (pin33)

//MaS
#define OFF 0
#define ON 1

//STATO TERMINALE
#define TERMINAL ON // ON / OFF

