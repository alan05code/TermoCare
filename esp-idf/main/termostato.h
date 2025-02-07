#include "stdlib.h"

//TestinVita
#define pinTiV 15
extern bool TiV;
extern int count;

//to MaS
extern bool setState;
extern bool Power; //alimentazione Riscaldamento/Clima
extern float varSetPoint;

//to Temperature
#define R0 10000.0
#define B 3435.0
#define T0 (25+273.15)
#define RS 124400.1324
#define Vcc 3300
extern float Vp, T, R, I;
int N;
//Continuously sample ADC1
extern uint32_t adc_reading;

//to Average Temperature
#define nRead 1000  // Numero di letture da utilizzare per il filtro
extern float Temp[nRead];                 // Array per memorizzare le letture delle temperature
extern int Index, Total;
extern float Tm, filteredValue;                        // Indice corrente dell'array Temp / totale / media

#define nEMA 12
#define alpha 0.15

//Seriale
extern long long TEnd;
#define Terminal_update 1000000  //REFRESH DEL TERMINALE (us)

//MaS
#define S_update 1        //Tempo di aggiornamento dello stato in (s)
extern long long S_TEnd;  //variabile per aggiornare lo stato
#define T_update 1000000  //Tempo di aggiornamento del terminale in (us)
extern long long T_TEnd;  //variabile per aggiornare lil terminale 

void ADC_Setup();

void InitMaS();
void MaS();

void Iniz_TempMedia();
void Iniz_Timers();


float TempMediaMobile();
void UpdateState();
float TempMediaEsponenziale();
float toTemperature(float Vp);
void SensorNTCRead();
void UpdateSetPoint(float SetPoint);

void Terminal();
void TestinVita();