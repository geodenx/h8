/****************************************************************
 * H8NIC Project
 * LCD driver
 *
 *	PB  - LCD (Data4bit)
 *	PB0 - D4
 *	PB1 - D5
 *	PB2 - D6
 *	PB3 - D7
 *	PB4 - E
 *	PB5 -
 *	PB6 - Rs
 *	PB7 - R/~W
 *
 * Reference:
 *    http://member.nifty.ne.jp/softbone/OneBoard/H8Template/
 *    http://www.kajitani.mce.uec.ac.jp/user/kazu/tech/gcc/
 *
 * $Id: lcd.c,v 1.1 2002/03/20 18:06:31 okazaki Exp $
 *
 *****************************************************************/

#include <3048fnew.h>
#include "lcd.h"

static void LcdWriteIR(unsigned char data);
static unsigned char LcdReadIR(void);
static void LcdWriteDR(unsigned char data);
static unsigned char LcdReadDR(void);
static void LcdWrite(unsigned char data);
static unsigned char LcdRead(void);
static void LcdWriteIR4(unsigned char data);
static short LcdBusy(void);
static void Delay(unsigned long msec);

static short lcdx, lcdy;

/*  Public routine: Initialize LCD */
void LcdInit(void)
{
    // Reset LCD 
    PB.DDR = 0xff;		/* LCD制御ライン */
    PB.DR.BYTE = 0;

    // 初期化シーケンス 
    Delay(20);			// Wait 20 ms 
    LcdWriteIR4(0x03);
    Delay(5);
    LcdWriteIR4(0x03);
    Delay(1);
    LcdWriteIR4(0x03);
    Delay(1);
    LcdWriteIR4(0x02);		// Data length 4bits 
    Delay(1);

    while (LcdBusy());
    LcdWriteIR(0x28);		// Set function 

    while (LcdBusy());
    LcdWriteIR(0x08);		// Display off, cursor off, blink off 

    while (LcdBusy());
    LcdWriteIR(0x01);		// Clear display 

    while (LcdBusy());
    LcdWriteIR(0x06);		// Entry mode : cursor increment 

    while (LcdBusy());
    LcdWriteIR(0x0C);		// Display on, cursor off, blink off 

    lcdx = lcdy = 0;
}

/*  Public routine: 表示場所設定 */
void LcdLocate(short x, short y)
{
    short addr;

    switch (y)
	{
	case 0:
	    addr = 0x00 + x;
	    break;
	case 1:
	    addr = 0x40 + x;
	    break;
	case 2:
	    addr = 0x14 + x;
	    break;
	case 3:
	    addr = 0x54 + x;
	    break;
	default:
	    return;
	}

    lcdx = x;
    lcdy = y;
    while (LcdBusy());
    LcdWriteIR(0x80 | addr);		// Set DD RAM address
}

/*  Public routine: Clear LCD, go to home */
void LcdCls(void)
{
    while (LcdBusy());
    LcdWriteIR(0x01);
    lcdx = lcdy = 0;
}

/*  Public routine: Display cursor */
void LcdDispCursor(short on)
{
    while (LcdBusy());
    LcdWriteIR(0x0C | (on ? 0x02 : 0));
}

/*  Public routine: Back Space */
void LcdBS(void)
{
    if (!lcdx)
	return;
    lcdx--;
    LcdLocate(lcdx, lcdy);
}

/*  Public routine: Put char */
void LcdPutCh(char c)
{
    if (c == '\b') {
	LcdBS();
	return;
    }
    while (LcdBusy());
    LcdWriteDR(c);
    lcdx++;
}

/*  Public routine: Put strings */
void LcdPutStr(const char *str)
{
    while (*str)
	LcdPutCh(*(str++));
}


/*****************************************************************
 *  Private routine
 *****************************************************************/
static void nop(void)
{
}


//	LCD Drive primitive
//	Data length = 4bits

#define ASSERT_RS()	{ PB.DR.BIT.B6 = 1; }
#define ASSERT_E()	{ PB.DR.BIT.B4 = 1; }
#define ASSERT_RW()	{ PB.DR.BIT.B7 = 1; }

#define NEGATE_RS()	{ PB.DR.BIT.B6 = 0; }
#define NEGATE_E()	{ PB.DR.BIT.B4 = 0; }
#define NEGATE_RW()	{ PB.DR.BIT.B7 = 0; }

#define WRITE_MODE()	{ PB.DDR = 0xff; }
#define WRITE_DATA(x)	{ PB.DR.BYTE = (PB.DR.BYTE & 0xf0) | ((x) & 0x0f); }

#define READ_MODE()	{ PB.DDR = 0xf0; }
#define READ_DATA()	(PB.DR.BYTE)

static void LcdWriteIR(unsigned char data)
{
    NEGATE_RS();
    LcdWrite(data);
}


static unsigned char LcdReadIR(void)
{
    NEGATE_RS();
    return LcdRead();
}


static void LcdWriteDR(unsigned char data)
{
    ASSERT_RS();
    LcdWrite(data);
}


static unsigned char LcdReadDR(void)
{
    ASSERT_RS();
    return LcdRead();
}


static void LcdWrite(unsigned char data)
{
    WRITE_MODE();

    NEGATE_RW();
    nop();

    ASSERT_E();
    WRITE_DATA(data >> 4);
    nop();
    NEGATE_E();

    nop();
	
    ASSERT_E();
    WRITE_DATA(data);
    nop();
    NEGATE_E();
}


static unsigned char LcdRead(void)
{
    unsigned char data;

    READ_MODE();

    ASSERT_RW();
    nop();

    ASSERT_E();
    nop();
    data = READ_DATA() << 4;
    NEGATE_E();
	
    nop();

    ASSERT_E();
    nop();
    data |= READ_DATA() & 0x0f;
    NEGATE_E();

    return data;
}


static void LcdWriteIR4(unsigned char data)
{
    WRITE_MODE();

    NEGATE_RS();
    NEGATE_RW();
    nop();

    ASSERT_E();
    WRITE_DATA(data);
    nop();
    NEGATE_E();
}


static short LcdBusy(void)
{
    return LcdReadIR() & 0x80;
}

static void Delay(unsigned long msec)
{
    unsigned long t;
    unsigned short i;
    for(t = 0; t < msec; t++) {
	for(i = 0; i < 100; i++); // ms 
    }
}

