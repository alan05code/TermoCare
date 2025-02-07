//ADC SETTINGS

#define DEFAULT_VREF    3300        //Use adc2_vref_to_gpio() to obtain a better estimate
#define NO_OF_SAMPLES   16          //Multisampling

static const adc_channel_t channel;     //GPIO34 if ADC1, GPIO14 if ADC2
static const adc_bits_width_t width;
static const adc_atten_t atten;
static const adc_unit_t unit;

void check_efuse(void);
void ADC_Setup(void);
int ReadVoltage(void);
