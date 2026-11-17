/*****************************************************************
* AKI-H8 interrupt sample program on Hitachi monitor
*
*                Feb 28, 2002
*                OKAZAKI Atsuya (atsuya@mac.com)
*
* $ h8300-hms-gcc -mh -c int.c -o int.o
* $ h8300-hms-ld -T h83048Fhmon.x chap2/crt0.o int.o -o int
* $ h8300-hms-objcopy -O srec int int.mot
* $ h8term
* : L
*    (transmit int.mot)
* : G FF100
*
 *****************************************************************/
#include "3048fnew.h"

#pragma interrupt
void int_imia1(void)
{
    ITU1.TSR.BIT.IMFA = 0;       /* Stop interrupt request       */
    P4.DR.BIT.B1 = !P4.DR.BIT.B1;
}

void initITU()
{
    ITU1.TCR.BYTE = 0x23 ;        /* clear GRA comparematch,1/8clock      */
    ITU1.TIOR.BYTE = 0 ;          /* not use ITU pins                     */
    ITU1.TIER.BIT.IMIEA = 1 ;     /* Enable comparematch-A interrupt      */
    ITU1.GRA = 0xffff ;              /* 500us = 62.5ns * 8 * ( 0xffff )       */
    ITU.TSTR.BYTE = 0xe3 ;        /* Start ITU ch0 ch1                    */
}

void init(void)	/* I/Oポートの初期化 */
{
/*      P1.DDR = 0xFF;		/* 1111-1111   bit0..7を出力に設定する */
/*      P2.DDR = 0x00;		/* 0000-0000   bit0..7を入力に設定する */
/*      P3.DDR = 0xFF;		/* 1111-1111   bit0..7を出力に設定する */
    P4.DDR = 0x03;		/* 0000-0011 P40,1 = LED, P42,3 = SW*/
    P4.PCR.BYTE = 0x0C;		/* 0000-1100 */
/*      P5.DDR = 0xFF;		/* 1111-1111   bit0..7を出力に設定する */
/*      P6.DDR = 0xFF;		/* 1111-1111   bit0..7を入力に設定する */
/*      P1.DR.BYTE = 0xFF; */
/*      P2.DR.BYTE = 0xFF; */
/*      P3.DR.BYTE = 0x00; */

    ITU0.TCR.BYTE = 0x23;       /* clear GRA comparematch,1/8clock      */
    ITU0.GRA = 2000;
//    ITU.TSTR.BYTE = 0xe1;
    initITU();
}

void waittimer()
{
    while ((ITU0.TSR.BYTE& 1) == 0);
    ITU0.TSR.BYTE = 0xfe;
}

void waitms(int i)
{
    for (; i ; i--)
	waittimer();
}

main()
{
    int i = 0;

    init();

    asm("andc.b #127,ccr");
  
    while(1){
	i++;
	P4.DR.BIT.B0 = !P4.DR.BIT.B0;
	waitms(500);
    }
}
