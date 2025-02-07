#include "settings.h"
#include "termostato.h"
#include "adcSetup.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"
#include "driver/gpio.h"

//Seriale
long long TEnd;

//MaS
long long S_TEnd;  //variabile per aggiornare lo stato
long long T_TEnd;  //variabile per aggiornare lil terminale
float varSetPoint = 22.5;

//TestinVita
bool TiV;
int count=0;

//to MaS
bool setState;
bool Power; //alimentazione Riscaldamento/Clima

//to Temperature
float Vp, T, R, I;
int N;

//to Average Temperature
float Temp[nRead];                 // Array per memorizzare le letture delle temperature
int Index, Total;
float Tm, filteredValue;                        // Indice corrente dell'array Temp / totale / media

enum S{
  Inattivo,  //POWER OFF
  Riscaldamento, //CAVO BIANCO
  Clima //CAVO ROSA
} State;

enum MType{
    MediaMobile,
    MediaEsponenziale
} MediaTYPE = MediaEsponenziale;

void Iniz_TempMedia() {
  adc1_config_width(ADC_WIDTH_BIT_12); // precisione = 12 bit
  adc1_config_channel_atten(SENSOR, ADC_ATTEN_DB_11); // (ADC2_CHANNEL_6 = pin14) / Attenuazione (11dB)
  
  //Inizializza l'array Temp
  for (int i = 0; i < nRead; i++) {
    Temp[i] = 0;
  }

  Index = 0;
  Total = 0;  
  Tm = 0; 
}

void Iniz_Timers() {
  TEnd = esp_timer_get_time() + Terminal_update;
  T_TEnd = esp_timer_get_time() + T_update;
  S_TEnd = esp_timer_get_time() + S_update;
}

//LOOP
float toTemperature(float Vp) {
  I = Vp/RS;
  R = (Vcc-Vp)/I;
  T = B / (log(R/RS)+(B/T0)) - 273.15;
  T = (T*100)/100.0; // Arrotonda a una cifra
  return T;
}

float TempMediaEsponenziale() { //Media Mobile
  int i;
  for ( i = 0; i < nRead; i++){
    count++;
    Tm = ReadVoltage();
    filteredValue = (alpha * Tm) + ((1 - alpha) * filteredValue);
    Tm = filteredValue;
  }
  return Tm;
}

float TempMediaMobile() {
  //LETTURA SENSORE - OTTIMIZZAZIONE IN TENSIONE - CONVERSIONE IN RAW
  int i;
  for ( i = 0; i < nRead; i++){
    count++;
    N = ReadVoltage();
    Total -= Temp[Index]; // Sottrai il valore più vecchio dalla somma totale
    Temp[Index] = N; // Aggiorna il valore nell'array Temp con la nuova lettura
    Total += Temp[Index]; // Aggiungi il valore più recente alla somma totale
    Index++;
    if (Index >= nRead) { // Se l'indice raggiunge la dimensione dell'array, riportalo a zero
      Index = 0;
    }
  }
  Tm = Total / nRead; //media delle letture
  return Tm;
}

void UpdateState() {
  // //media e conversione in temperatura
  if (MediaTYPE == MediaMobile) {
    T = toTemperature(TempMediaMobile());
  } else if (MediaTYPE == MediaEsponenziale) {
    T = toTemperature(TempMediaEsponenziale());
  } else {
    printf("ERRORE NELLA LETTURA");
  }
  
  //variabili
  float TR_IN = (varSetPoint - 0.5);
  float TR_OUT = (varSetPoint);
  float TC_IN = (varSetPoint + 0.5);
  float TC_OUT = (varSetPoint);

  //aggiornamento dello stato
  switch (State){
    case Inattivo:
    setState = OFF;
    Power = OFF;
    if (T < TR_IN) State = Riscaldamento;
    if (T > TC_IN) State = Clima;
  break;
  case Riscaldamento:
    setState = OFF;
    Power = ON;
    if (T >= TR_OUT) State = Inattivo;
  break;
  case Clima:
    setState = ON;
    Power = ON;
    if (T <= TC_OUT) State = Inattivo;
  break;
  default: printf("\nERROR in switch(State)");
    break;
  }

  //set degli output
  gpio_set_level(pinPower, Power);
  gpio_set_level(pinState, setState);
}

void SensorNTCRead() {
  if (MediaTYPE == MediaMobile) {
    TempMediaMobile();
  } else if (MediaTYPE == MediaEsponenziale) {
    TempMediaEsponenziale();
  } else {
    printf("ERRORE NELLA LETTURA");
  }
}

void UpdateSetPoint(float SetPoint) {
  varSetPoint = SetPoint;
}

//Debug
void Terminal(){
  if(TEnd < (esp_timer_get_time() - 10000)) {  //il 10000 è per gestione di interrupt
    TEnd = esp_timer_get_time() + Terminal_update;

    printf("\nTick in ");
    printf("%.2f",T_update/1000000.0);
    printf("s -> ");
    printf("%d",count);
    count = 0;

    printf("\nTemperatura: %.2f",T);
    printf("\nSetPoint: %.2f", varSetPoint);
    printf("\nStato: %d ",State);
    printf("\nPower: %d ",Power);
    printf("\nStato Rosa: %d",!gpio_get_level(26));
    printf("\nStato Bianco:%d",!gpio_get_level(25));
    printf("\n");
  }
}

void TestinVita() {
  TiV = !TiV;
  gpio_set_level(pinTiV, TiV);
}

void InitMaS(void) {
  //Configure ADC
  ADC_Setup();
  
  //dichiarazione dei pin
  gpio_pad_select_gpio(pinPower);
  gpio_set_direction(pinPower, GPIO_MODE_OUTPUT);
  gpio_pad_select_gpio(pinState);
  gpio_set_direction(pinState, GPIO_MODE_OUTPUT);
  gpio_pad_select_gpio(pinTiV);
  gpio_set_direction(pinTiV, GPIO_MODE_OUTPUT);

  gpio_set_direction(25, GPIO_MODE_INPUT);
  gpio_set_pull_mode(25, GPIO_PULLUP_ONLY);
  gpio_set_direction(26, GPIO_MODE_INPUT);
  gpio_set_pull_mode(26, GPIO_PULLUP_ONLY);

  adc1_config_width(ADC_WIDTH_BIT_DEFAULT);
  adc1_config_channel_atten(SENSOR,ADC_ATTEN_DB_0);

  Iniz_TempMedia();
  Iniz_Timers();
}