# H8/300H 開発環境構築メモ 2002
Hardware: AKI-H8/3048F, AKI-Mother Board

```
$ uname -a
Linux io.satellite 2.2.16-3 #1 Fri Aug 18 14:51:29 JST 2000 i686 unknown
TurboLinux Workstation 6.0 (FTP)
$ gcc --version
2.95.2
$ gmake --version
GNU Make version 3.79, by Richard Stallman and Roland McGrath.
Built for i386-pc-linux-gnu
```

## binutils, gcc, newlib, gdb
[GNU Development Tools for the Hitachi H8/300[HS] Series](http://h8300-hms.sourceforge.net/)
色々と試してみたが、この通りにやったら上手くいった。バージョンもこれと同じようにした。

binutils
```
tar zxvf binutils-2.11.2.tar.gz
cd binutils-2.11.2
mkdir objdir
cd objdir
../configure --prefix=/usr/local --target=h8300-hms
gmake CFLAGS="-O2 -fomit-frame-pointer" all
gmake install
```
gcc and newlib
```
tar zxvf gcc-3.0.3.tar.gz
tar zxvf newlib-1.9.0.tar.gz
cd gcc-3.0.3
ln -s ../newlib-1.9.0/newlib .
patch -p1 < ../h8300-hms-gcc-3.0.3-1.patch
mkdir objdir #こうやって別のdir.でやらないとならなくなったそうです。
cd objdir
../configure \
        --prefix=/usr/local --target=h8300-hms \
        --enable-languages="c,c++" --with-newlib
gmake CFLAGS="-O2 -fomit-frame-pointer" all
gmake install #this has to be done by root
```
gdb
```
tar xfj gdb-5.1.1.tar.bz2
cd gdb-5.1.1
mkdir objdir
cd objdir
../configure --prefix=/usr/local --target=h8300-hms
gmake CFLAGS="-O2 -fomit-frame-pointer" all
gmake install #this has to be done by root
```
autoconf-2.13

gcc-2.8.1 の場合 make で autoheader がないと怒られたので autoconf を make install
```
$ csh ./configure
$ make
$ make check
# make install
```

## コンパイル、アセンブル、リンク
from .asm
```
h8300-hms-as helloworld.S -o helloworld.o
h8300-hms-ld helloworld.o -o helloworld -T h83048F.x # requires linker script
h8300-hms-objcopy -O srec helloworld helloworld.mot
```
from C
```
h8300-hms-gcc -mh -c led.c -o led.o
h8300-hms-gcc -mh -S led.c #おまけ アセンブラ吐き出し led.s
h8300-hms-as crt0.s -o crt0.o #作っておく
h8300-hms-ld -T h83048F.x  crt0.o led.o -o led
(Link Linker Script, Start Up Routine,も一緒に)
h8300-hms-objcopy -O srec led led.mot
```
- ldscript: `h83048F.x`
- start up routine: `crt0.s`
は TECH I 『技術者のためのUNIX系OS入門』より

- `gcc -mrelax` を使うと良いかも。http://www.ertl.ics.tut.ac.jp/~muranaka/devel/
- `crt0.o` はアセンブルしておかなくても `gcc` で直接使える？


## ROM ライタ
大抵の場合、最初に RAM に ROM 転送 program を書き込んでから、user の ROM program を書き込む。

### [h8tools](http://www.linet.gr.jp/~mituiwa/#h8dev2)
ライタ: `h8tools/3048eeprom`

`3048tool.c` 修正
```
97,103c97,103
<     tcsetpgrp(TheFd,getpgrp());
<     tcgetattr(TheFd,&TheTty);
<     cfsetispeed(&TheTty,B9600);
<     cfsetospeed(&TheTty,B9600);
<     TheTty.c_cflag |= HUPCL | CLOCAL ;
<     TheTty.c_cflag &= ~( PARENB | CSTOPB );
<     cfmakeraw(&TheTty);
```
ボーレート設定を確実に

http://www.paken.org/aaf/a4nerve/nerve.html
```
110,186c110,112
<     if(stty(TheFd, &TheTty ) == -1){
<       fprintf(stderr, "stty error\n" );
<       return -1;
<     }
<
<     for(i = 0;i < 64;i++) buffer[i] = 0;
<     do {
<       if((s = write(TheFd,buffer,64)) == -1) {
<           fprintf(stderr, "write error\n" );
<           exit(-1);
<       }
<       s = getb();
<     } while(s < 1);
< /*  return; */
```
return を comment out

http://strawberry-linux.com/h8/write.html
```
$ make
# make install
$ gcc -o /usr/bin/3048tool 3048tool.c
$ 3048tool Motrola S2 File [ serial-port ]
```
Motorola S2 Fileは S"2" Formatしか受け付けない。S2を生成する必要がある。

- 方法0: 最初からS2になっている場合も良くある。
- 方法1: h8300-hms-gccで-mrelaxを付けるとアドレスを短くしようと努力してくれるらしい。
- 方法2
```
$ h8300-hms-objcopy -O srec --srec-forceS3 helloworld helloworld.mot3
$ ./s3tos2 helloworld.mot3 helloworld.mot2
$ 3048tool helloworld.mot2 /dev/ttyS0
```
`--srec-forceS3` で S3 Format を強制的に作り、
[s3tos2](http://www.niigata-pc.ac.jp/~namikata/freebsd/h8/soft.html) Sフォーマット変換ツール
で S2 に変換。

#### Motorola S format
addressの長さ
- S1: 16bit (16進で4文字)
- S2: 24bit (16進で6文字)
- S3: 32bit (16進で8文字)
おまけ: [mot-mode.el](https://gist.github.com/geodenx/7276295dcbcab209e4edf8fc9c0f46d5)

### [Open SH/H8 writer](http://www.linet.gr.jp/~mituiwa/h8/)
[追記] May 30, 2003:
h8tools が version up したものが公開された。多くのデバイスに対応し、使い方も簡単なのでお勧め。

### `h8dld.c`
TECH I 『技術者のためのUNIX系OS入門』より

Motorola S formatとbinary両方受け付けるというけど…。失敗中。

以下失敗記録

AKI-H8 の Writer Flash に付いていた 3048.sub を boot program として利用
```
$ ./dh8dld 3048.sub program.bin
```
それぞれbinary フォーマットとSフォーマットに対応している。というのだけどなぁ。
```
$ h8300-hms-objcopy -O binary helloworld helloworld.bin
```
と、`helloworld.bin` を作ってみたけど、書き込み失敗

```
$ ./h8dld 3048.sub program.bin
```
でやってみたら書き込めた。
```
$ ./h8dld helloworld.bin 3048.sub
      634/      634      100%
Bootstrap Download Done(aa)
Bootstrap Program Download done.
Please Hit Enter key to start  download rom program.
```
ここで普通に何か押すとしばらくして終る。

そこで、`3048.sub` を binary にし helloworld を `.mot` にすればいいのか。
`3048.sub` は `.mot` 形式なのでこれからどうやって、binaryにすればいい？
```
$ ./h8dld 3048.sub program.mot
```
も失敗。

### [h8comm](http://iwatam-server.dyndns.org/hardware/h8comm/index.html)
少し試したが、失敗中。これは `.mot` ではなくて `.bin` を受け付けるらしい。


## Monitor
hardware: AKI-H8/300H 3048F (増設RAM無し)

### [h8tools](http://www.linet.gr.jp/~mituiwa/#h8dev2)
monitor: `h8tools/3048mon`
```
$ make
$ 3048tool h8mon.mot
$ h8term [/dev/ttyS0]
Power Reset
ようこそH8/3048Fモニターへ!!
H8/3048F> dump 0000

00000000 : 0000010000000100  0000010000000100
00000010 : 0000010000000100  0000010000000100
00000020 : 0000010000000100  0000010000000100
00000030 : 0000010000000100  0000010000000100
```

H8/3048F ldscript

![ldscript.png](ldscript.png)

monitor (3048mon)上で動くProgram (.mot)を作る。
[h83048Fmon.x](https://www.dropbox.com/s/a3xing6yv2go0vr/h83048Fmon.x?dl=0)
一部抜粋
```
MEMORY
{
    vectors : o = 0xfff010, l = 0x00100
    rom     : o = 0xfff110, l = 0x009f0
    ram     : o = 0xfffb00, l = 0x003f8
    stack   : o = 0xfffef8, l = 0x00004
}
```
Reference: `h8tools/3048mon/h8mon.x`

from .asm
```
$ h8300-hms-as helloworld.S -o helloworld.o
$ h8300-hms-ld helloworld.o -T h83048Fmon.x -o helloworld
$ h8300-hms-objcopy -O srec helloworld helloworld.mot
$ ./h8tools/h8term
H8/3048F> write helloworld.mot
(略)
H8/3048F> exec fff110
(LCDに表示)
```

from C
```
$ h8300-hms-gcc -mh -c led.c -o led.o # -mrelax?
$ h8300-hms-ld -T h83048Fmon.x crt0.o led.o -o led
$ h8300-hms-objcopy -O srec led led.mot # S1, S2 or S3?
```

```
$ ./h8tools/h8term
ようこそH8/3048Fモニターへ!!
H8/3048F> dump fff110

00FFF110 : 124587EEA18087FB  0726D00782196623
00FFF120 : 0900F9BB10087FDF  04007E270000FF2D
00FFF130 : 0108752F2C054B7D  2800E4DD3558FABE
00FFF140 : 2C00D3AD08C25D7B  8000EFFF94523FFB

H8/3048F> write led.mot
書き込み中................................
書き込みが終了しました。
H8/3048F> dump fff110

00FFF110 : 7A0700FFFEF85EFF  F1A040F401006DF6
00FFF120 : 0FF6FAFF6AAA000F  FFC86AAA000FFFC4
00FFF130 : FA236AAA000FFF64  790207D06BA2000F
00FFF140 : FF6AFAE16AAA000F  FF6001006D765470

H8/3048F> exec fff110
```
(LEDが点滅)
`helloworld.S`, `led.c`, `crt0.o` (TECH I 『技術者のためのUNIX系OS入門』より)

#### stack
- stack領域って？ldscriptでmonitor以外のところに割り当てたけどいいの？Vectorとか。割り込みはどうなるのか。

> なお、プログラムは、jsr命令で実行されますので、rts命令で モニターに戻ります。

を試してみる。今は強制終了で終らせている。というか、H8内部のProgramは周り続けている。

#### `rts`、Cだとどう書く？
```
asm("rts");
```


### Hitachi's monitor for AKI-H8
HitachiのWebからAKI-H8用のMonitor programをdownload。[akih8.zip](http://www.hitachisemiconductor.com/sic/jsp/japan/jpn/Sicd/Japanese/Seminar/down.htm)
`MONITOR.MOT` を焼き込む。（Motorola S1 formatなので、AKI-H8に付属していたWindowsのwriter (flash)を利用）

```
$ cu -l /dev/ttyS0 -s 19200
Connected.

(ここでAKI-H8の電源ON)
 H8/3048 Series Advanced Mode Monitor Ver. 2.2A
 Copyright (C) Hitachi, Ltd. 1995
 Copyright (C) Hitachi Microcomputer System, Ltd. 1995

: ?
 Monitor Vector 00000 - 000FF
 Monitor ROM    00100 - 05A1D
 Monitor RAM    FEF10 - FEFEB
 User    Vector FF000 - FF0FF

 .  : Changes contents of H8/300H registers.
 A  : Assembles source sentences from the keyboard.
 B  : Sets or displays or clear breakpoint(s).
 D  : Displays memory contents.
 DA : Disassembles memory contents.
 F  : Fills specified memory range with data.
 G  : Executes real-time emulation.
 H8 : Displays contents of H8/3042 peripheral registers.
 L  : Loads user program into memory from host system.
 M  : Changes memory contents.
 R  : Displays contents of H8/300H registers.
 S  : Executes single emulation(s) and displays instruction and registers.
: ~[localhost].

Disconnected.
```

ldscript

![ldscript-hitachi.png](ldscript-hitachi.png)

H8/3048 Series Advanced Mode Monitor Ver. 2.2A用

AKI-H8/3048F RAM増設無し
[h83048Fhmon.x](https://www.dropbox.com/s/fcpl628sfitf5u6/h83048Fhmon.x?dl=0)


#### kermit
cuでは貧弱というか、使い方が良く分からないのでkermitをinstall
cuだとFile転送 (~> filename)に時間がかかりすぎるし、ちゃんと書き込めてないかも。
http://www.tt.rim.or.jp/~hoso/H8/#kermit

[cku201.tar.gz](http://www.kermit-project.org/ckermit.html#source)
```
$ mkdir kermit
$ cd kermit
$ tar zxvf cku201.tar.gz
$ make linux
# make install
$ cp ckermit.ini ~/.kermrc
$ cat > ~/.mykermrc
set line /dev/ttyS0
set speed 19200
set ternubak bytesize 8
set command bytesize 8
set transmit prompt 0
SET CARRIER-WATCH OFF

$ h8300-hms-as chap2/helloworld.S -o helloworld.o
$ h8300-hms-ld helloworld.o -T h83048Fhmon.x -o helloworld
$ h8300-hms-objcopy -O srec helloworld helloworld.mot

$ h8300-hms-gcc -mh -c chap2/led.c -o led.o
$ h8300-hms-ld -T h83048Fhmon.x chap2/crt0.o led.o -o led
$ h8300-hms-objcopy -O srec led led.mot

$ kermit
Executing /root/.kermrc for UNIX...
Executing /root/.mykermrc...
?No keywords match - ternubak
Command stack:
  4. File  : /root/.mykermrc (line 3)
  3. Macro : XIF
  2. Macro : _xif
  1. File  : /root/.kermrc (line 767)
  0. Prompt: (top level)
Good Morning!
C-Kermit 8.0.201, 8 Feb 2002, for Linux
 Copyright (C) 1985, 2002,
  Trustees of Columbia University in the City of New York.
Type ? or HELP for help.
(/root/) C-Kermit>c
Connecting to /dev/ttyS0, speed 19200
 Escape character: Ctrl-\ (ASCII 28, FS): enabled
Type the escape character followed by C to get back,
or followed by ? to see other options.
----------------------------------------------------


 H8/3048 Series Advanced Mode Monitor Ver. 2.2A
 Copyright (C) Hitachi, Ltd. 1995
 Copyright (C) Hitachi Microcomputer System, Ltd. 1995

: L
C-\ C-c
(Back at io.satellite)
----------------------------------------------------
(/root/) C-Kermit>(/root/) C-Kermit>transmit led.mot # helloworld.motも同様に動作する
(/root/) C-Kermit>c
Connecting to /dev/ttyS0, speed 19200
 Escape character: Ctrl-\ (ASCII 28, FS): enabled
Type the escape character followed by C to get back,
or followed by ? to see other options.
----------------------------------------------------
  Top Address=FF000

  End Address=FF1FD

: g ff100
C-\ C-c
(Back at io.satellite)
----------------------------------------------------
(/root/) C-Kermit>quit
Closing /dev/ttyS0...OK
```
kermitを user で実行すると UUCP の `/var/lock` でだめと言われるので、rootで実行。`~/.mykermrc`, `~/.kermrc` の移動を忘れずに。

NMI 入力を行うとユーザプログラムを強制停止らしい。
```
: G 10100 [RET]
NMI（Abort Switch ON）入力
  Abort at PC=013014
  PC=013014  CCR=80:I.......  SP=00FFFF00
  ER0=00000000  ER1=00000000  ER2=00000000  ER3=00000000
  ER4=00000000  ER5=00000000  ER6=00000000  ER7=00FFFF00
```

### [h8term](http://www.niigata-pc.ac.jp/~namikata/freebsd/h8/soft.html)
`h8term.c` の device file nameを変更
```
#define DEVICE "/dev/ttyS0"
```

```
$ gcc -o h8term h8term.c
$ ./h8term 
************************
* H8 tiny Terminal     *
*    [ESC] key to menu *
************************

 H8/3048 Series Advanced Mode Monitor Ver. 2.2A
 Copyright (C) Hitachi, Ltd. 1995
 Copyright (C) Hitachi Microcomputer System, Ltd. 1995

: L
[Esc]
------------------ menu --------------------
    upload data       :1
    exit this program :2
    exit this menu    :esc
[2]
    Upload file name : led.mot
--------------------------------------------
  Top Address=FF000
  End Address=FF1FD
: g ff100
[Esc]
------------------ menu --------------------
    upload data       :1
    exit this program :2
    exit this menu    :esc
--------------------------------------------
```

#### Reference
- [3.1 リンカスクリプトって何?](http://iwatam-server.dyndns.org/hardware/h8comm/doc/CrossDevel-jp.html/ch-ldscript.html)
- http://www.niigata-pc.ac.jp/~namikata/freebsd/h8/h8ram.x
- http://www.niigata-pc.ac.jp/~namikata/freebsd/h8/
- [h8tools/3048mon/h8mon.x](http://www.linet.gr.jp/~mituiwa/)
- h83048F.x (TECH I 『技術者のためのUNIX系OS入門』より)

## GNU Assembler (GAS)
「AKI-H8マイコン専用マザーボード」のサンプル `MBTEST.MAR`を GAS に移植。[mbtest.s](https://www.dropbox.com/s/9zmorz0zej2hx9l/mbtest.S?dl=0)
```
$ h8300-hms-as mbtest.s -o mbtest.o
$ h8300-hms-ld mbtest.o -T h83048Fmon.x -o mbtest
$ h8300-hms-objcopy -O srec mbtest mbtest.mot
$ ./h8tools/h8term 
ようこそH8/3048Fモニターへ!!
H8/3048F> write mbtest.mot
書き込み中................................................................
書き込みが終了しました。
H8/3048F> exec fff110
```

移植前
```
SW_D .EQU H'FFEF10
```
移植後
```
SW_D = 0xFFEF10
```
.setや.equでもいける？

.BEQUを移植できないので、直Address指定
(GCCを使えば.BEQUを#defineできる。)

移植前
```
MOJI: .SDATA "AKI-H8 "
 .DATA.B 0x0CF,0x0BB,0x0DE,0x0B0,0x0CE
 .DATA.B 0x0DE,0x0B0,0x0C4,0x0DE
 .SDATA "1111 11111111   "
```
移植後
```
MOJI: .ascii "AKI-H8 "
 .byte 0x0CF,0x0BB,0x0DE,0x0B0,0x0CE
   .byte 0x0DE,0x0B0,0x0C4,0x0DE
 .ascii "1111 11111111   "
```
レジスタ名を小文字に変更: `ER1` -> `er1` など

`.SECTION` をcomment out
```
.global _start
```
など、`.global` を忘れずに(globalってなに？)
変数は `_start` とする(ldscript内で指定しているっぽい)。

### GCCでasemmber fileをassemble
[mbtest.S](https://www.dropbox.com/s/9zmorz0zej2hx9l/mbtest.S?dl=0)
```
$ h8300-hms-gcc -O -mh -mint32 -g -mrelax -nostdlib \
-T ../h83048Fmon.x mbtest.S -o mbtest.o
$ h8300-hms-objcopy -O srec mbtest.o mbtest.mot
$ ../h8tools/h8term
ようこそH8/3048Fモニターへ!!
H8/3048F> write mbtest.mot
書き込み中................................................................
書き込みが終了しました。
H8/3048F> exec fff110
```
`#define`でできました。
`filename.S` と大文字のSでないと `#define` で宣言したシンボルを利用するところでエラー。
```
$ man gcc
...
.s     アセンブリ言語ソースです。アセンブラにかけられます。
.S     アセンブリ言語ソースです。プリプロセッサ、アセンブラにかけられます。
...
```
`.end` の後は改行が必要。

移植前
```
LED1 .BEQU 0,P5DR
```
移植後
```
#define LED1 #0,@P5DR:8
```
bit命令 (BCLRなど)だったので、こうしたけど…。

(#include "file.h"も使えるかも。)

```
H' -> 0x
B' -> 0b
```

### [GCC options](http://www.ertl.ics.tut.ac.jp/~muranaka/devel/h8-gcc.txt)
http://lillith.sk.tsukuba.ac.jp/~kashima/aki-h8/
```
$ h8-gcc -T linker-script.x -nostartfiles -mh -mrelax \
-O2 -o out-file startup-file.o src-file1 src-file2 ...

-T linker-script.x : リンカスクリプトファイルの指定
-nostartfiles      : デフォルトのスタートアップルーチンを使用しない
-mh                : H8/300Hを指定
-mrelax            : 絶対アドレッシングを最適化
-O2                : 最適化レベル２
-o out-file.o      : COFF 形式出力ファイル名
startup-file.o     : 使用するスタートアップルーチン
src-fileX        : C言語、アセンブラソースファイルまたはオブジェクトファイル

Output memory map
$ h8300-hms-gcc -mh -o foo.coff -g -Xlinker -M foo.c -Ml,-T h83048Fhmon.x 2> Xlinker.log
$ h8300-hms-gcc -mh -o foo.coff -g -Xlinker -M foo.c \
-Ml,-T h83048Fhmon.x crt0.s 2> Xlinker_crt0.s.log

-Ml,option
-M

バイナリ出力ファイル変換
$ h8-objcopy -O srec coff-file srec-file.mot
-O srec         : モトローラSレコードフォーマットを指定
coff-file     : COFF 形式入力ファイル名
srec-file.mot     : Sフォーマットファイル出力ファイル名
```

### `a38h.exe` on wine
```
$ wine a38h.exe MBTEST.MAR
$ wine l38h.exe MBTEST.OBJ
$ wine c38h.exe MBTEST.ASM
```
で、`MBTEST.MOT` が生成される。


### Reference
- ["Using as  The GNU Assembler](http://www.gnu.org/manual/gas-2.9.1/html_mono/as.html)
- `h8tools/3048eeprom/writebyte.S` h8tools
- `hellowworld.S` TECH I 『技術者のためのUNIX系OS入門』
- `h8300-hms-gcc -mh -S led.c` で吐き出されたアセンブラ `led.s`
- 別のサンプル [3.S](https://www.dropbox.com/s/uipx94n0ww58cex/3.S?dl=0) SW, LED動作確認

## C Programming with GNU Tools
- [lcd.c](https://www.dropbox.com/s/i9fmc8aw29ls97k/lcd.c?dl=0)
- ~~3048fnew.h~~
AKI-mother BoardでLCD表示Routineを公開されている方が居たので、GCCに移植して利用してみた。
LED点灯後、あるいはSw0押した後LCDに文字列を出力

- [int.c](https://www.dropbox.com/s/ej6ydtp7tjox0nh/int.c?dl=0)
- ~~3048fnew.h~~
- 割り込みサンプルプログラム (Hitachi monitor: ldscript h83048Fhmon.x用)

header fileは、Renesasさんが最新のincludeファイルを配布していますので、そちらを利用下さい。
ただし、modeによっては、
```
#define DMAC0A  (*(volatile struct st_sam   *)0xFFFF20) /* DMAC 0A Addr */
```
を、
```
#define DMAC0A  (*(volatile struct st_sam   *)0xFFF20) /* DMAC 0A Addr */
```
のように、20-bit address 空間に書き換えてやる必要があります。
さらに、header file は version up にともない、レジスタの名前の付け方のポリシー変更されています。
`int.c` の内部も適当に書き換えて下さい。このポリシーについては Renesas のウェブに詳しく書かれています。

- http://www.niigata-pc.ac.jp/~namikata/freebsd/h8/
- http://www.tt.rim.or.jp/~hoso/H8/
- sample-gcc: http://www.ertl.ics.tut.ac.jp/~muranaka/h8/


## GDB

### [simulation](http://www.tt.rim.or.jp/~hoso/H8/#test-gdbsim)
```
$ h8300-hms-gcc -o int -g -mh int.c
$ h8300h-hms-gdb int
GNU gdb 5.1.1
Copyright 2002 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "--host=i686-pc-linux-gnu --target=h8300-hms"...
(gdb) set machine h8300h
(gdb) target sim
Connected to the simulator.
(gdb) load
Loading section .text, size 0x274 vma 0x100
Loading section .data, size 0x298 vma 0x374
Loading section .stack, size 0x4 vma 0x3fffc
Start address 0x102
Transfer rate: 10368 bits in <1 sec.
(gdb) run
Starting program: ~/gnu/int

Program received signal SIGINT, Interrupt.
0x00000240 in waittimer () at int.c:55
55     while ((ITU0.TSR.BYTE& 1) == 0);
(gdb) quit
The program is running.  Exit anyway? (y or n) y
```

### remote debug
gdb 5.1.1 に [h8300-hms-gdb-5.0-HITACHI_MON-1.tar.gz](http://homepage2.nifty.com/t_yasui/micro_mouse/h8/GCC-Cross3.html) (GDB: 5.0)
```
$ cd gdb-5.1.1
$ cd gdb
$ patch -p0 < ../../h8300-hms-gdb-5.0-HITACHI_MON-1/monitor.c.diff
$ patch -p0 < ../../h8300-hms-gdb-5.0-HITACHI_MON-1/remote-hms.c.diff # 失敗するので手動 patch
$ cd ..
$ mkdir objdir
$ cd objdir
$ ../configure --prefix=/usr/local --target=h8300-hms
$ gmake CFLAGS="-O2 -fomit-frame-pointer" all
# gmake install
```

```
$ h8300-hms-gcc -g -mh -c int.c -o int.o
$ h8300-hms-ld -T h83048Fhmon.x crt0.o int.o -o int
$ h8300-hms-gdb int
GNU gdb 5.1.1
Copyright 2002 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "--host=i686-pc-linux-gnu --target=h8300-hms"...
(gdb) set machine h8300h
(gdb) set remotebaud 19200
(gdb) target hms /dev/ttyS0
Remote target hms connected to /dev/ttyS0
0x00000000 in ?? ()
(gdb) load
.vectors : 0x00fff000 .. 0x00fff0f4
.text : 0x00fff100 .. 0x00fff2b6
.tors : 0x00fff2b6 .. 0x00fff2b6
.data : 0x00fffb00 .. 0x00fffb00
.stack : 0x00ffff0c .. 0x00ffff0c
Transfer rate: 5456 bits in <1 sec.
(gdb) run
Starting program: ~/gnu/int
[C-c C-c]
Interrupted while waiting for the program.
Give up (and stop debugging it)? (y or n) y
(gdb) quit
```
実行はできる~~けど、breakpointの設定などが出来ない。~~

追記 (Sep 11, 2002)
linker scriptの記述に間違いがありbreak pointの設定ができないことをご指摘頂きました。
ありがとうございました。
```
MEMORY
{
 vectors : o = 0xfff000, l = 0x00100
 rom     : o = 0xfff100, l = 0x00a00
 ram     : o = 0xfffb00, l = 0x0040c
 stack   : o = 0xffff0c, l = 0x00004
}
```
これでは、Mode 7(H8/3048F)の場合1Mの空間を超えてしまうので、
```
MEMORY
{
 vectors : o = 0xff000, l = 0x00100
 rom     : o = 0xff100, l = 0x00a00
 ram     : o = 0xffb00, l = 0x0040c
 stack   : o = 0xfff0c, l = 0x00004
}
```
このようにすることで、正しいアドレスを日立モニタに伝える事ができ break porint の設定ができました。
16M 空間の Mode の場合は前者の linker script で動作しました。(日立モニタ用に修正したgdb 5.2.1で確認)


[gdb-hmon](http://www.tt.rim.or.jp/~hoso/H8/#gdb-remote) (GDB: 4.17)

### `gdb-mode.el`
`M-x gdb [RET] h8300-hms-gdb foo [RET]`

`M-x 2` で window を分割し Source File を表示すると実行行に `=>` を表示してくれる。


## RAM 増設
HM628128 (Hitachi 1Mbit SRAM)をAKI-H8/3048Fに増設

Mode 5 (Inner ROM enable, 1M Byte mode)

配線: Tr技2001 9月 p.184
AKI-H8 (CN5-3,4 ジャンパ接続) (Mode 5)

Monitor: RAM増設に伴いHitachi monitorを修正
拡張ボード用ROMモニタ [make-300hmoni.lzh](http://www.ertl.ics.tut.ac.jp/~muranaka/h8/) を利用する。
やり方は同じで、`monitor.sub`, `Monitor.src` を以下の様に書き換えアセンブル、リンクし `monitor.MOT` を生成。

`300hmoni/bat/monitor.sub`
```
INPUT monitor
INPUT cmd01,cmd02,cmd03,cmd04,cmd05,cmd06,cmd07,cmd08,cmd09,cmd10
INPUT cmd11,cmd12,cmd13,cmd14,cmd15,cmd16,cmd17,cmd18,cmd19,cmd20
INPUT cmd21,      cmd23,cmd24,cmd25,      cmd27,cmd28,cmd29,cmd30
INPUT cmd31,cmd32,cmd33,cmd34,cmd35,cmd36,cmd37,cmd38
INPUT dmy26,dmy39
INPUT mod01,mod02,mod03,mod04,mod05,mod06,mod07,mod08,mod09,mod10
INPUT mod11,mod12,mod13,mod14,mod15,mod16,mod17,mod18,mod19,mod20
INPUT mod21,mod22,mod23,mod24,mod25,mod26,mod27,mod28,mod29,mod30
INPUT mod31,mod32,mod33,mod34,mod35,      mod37,mod38,mod39
INPUT advanced
INPUT cpu01,cpu02,cpu03,cpu04
DEFINE  $BRR(19)
DEFINE  $STACK(03FFFC)
PRINT   MONITOR.MAP
OUTPUT  MONITOR.ABS
START   VECTOR(0),ROM(130),RAM(0FEF10),USER(20000),SCI(0FFFFB8)
EXIT
```

```
DEFINE  $BRR(0C)
```
とすると、38400 bps になる。

`300hmoni/Monitor.src`
```
;************************************************************************
;*      H8/300H Monitor Program (Advanced Mode)         Ver. 2.2A       *
;*              Copyright (C) Hitachi, Ltd. 1995                        *
;*              Copyright (C) Hitachi Microcomputer System, Ltd. 1995   *
;************************************************************************
                .PROGRAM  INITIALIZE            ; Program Name
                .CPU      300HA                 ; CPU is H8/300H Advanced
                .SECTION  ROM,CODE,ALIGN=2      ; ROM Area Section
;************************************************************************
;*      Export Define                                                   *
;************************************************************************
                .EXPORT _INITIALIZE             ; User Initialize Module

ABWCR:          .EQU    H'FFFFEC
ASTCR:          .EQU    H'FFFFED
WCR:            .EQU    H'FFFFEE
WCER:           .EQU    H'FFFFEF
P1_DDR:         .EQU    H'FFFFC0
P2_DDR:         .EQU    H'FFFFC1
P5_DDR:         .EQU    H'FFFFC8
P8_DDR:         .EQU    H'FFFFCD

;************************************************************************
;*      User Initialize Module                                          *
;*              Input   ER5 <-- Return Address                          *
;*              Output  Nothing                                         *
;*              Used Stack Area --> 0(0) Byte                           *
;************************************************************************
_INITIALIZE:
; RAM用初期化
;  MOV.B #H'FD, R0L
;  MOV.B R0L, @ABWCR:8 ; CS1領域バス幅16ビット(P4:D0-D7)
;  MOV.B #H'FD, R0L
;  MOV.B R0L, @ASTCR:8 ; CS1領域2ステートアクセス
  MOV.B #H'FF, R0L
  MOV.B R0L, @P1_DDR ; P1をアドレスバス(A0-A7)
  MOV.B R0L, @P2_DDR ; P2をアドレスバス(A8-A15)
  MOV.B R0L, @P5_DDR ; P5をアドレスバス(A16-A19)
  MOV.B #H'E8, R0L
  MOV.B R0L, @P8_DDR ; P8-3 CS1出力

  JMP @ER5  ; Goto Monitor Program
  .END   ;
```
[monitor.MOT](https://www.dropbox.com/s/5p9rrxmh8cg8bpt/monitor.MOT?dl=0)

ldscript: [h83048Frhmon.x](https://www.dropbox.com/s/gfjq734tr6be0qq/h83048Frhmon.x?dl=0)
```
vectors : o = 0x20000, l = 0x00100
rom     : o = 0x20100, l = 0x1FEFC
ram     : o = 0xFF08C, l = 0x00E80
stack   : o = 0x3FFFC, l = 0x00004
```

samples
- <a href="https://www.dropbox.com/s/481hdlx8hiv1h8d/int_nic.c?dl=0">int_nic.c</a>
- <a href="https://www.dropbox.com/s/lrque547e0n13or/noi_nic.c?dl=0">noi_nic.c</a>

P1,2,3,8-3(^CS1)はSRAMの制御線になるので、user programで触ってはならない。

### Reference
- http://www.niigata-pc.ac.jp/~namikata/freebsd/h8/
- http://www.tt.rim.or.jp/~hoso/H8/


## OS
- [uClinux-h8](https://sourceforge.jp/projects/uclinux-h8/)
  - [uClinux](http://www.uclinux.org/)
  - [uClinux for H8](https://geodenx.blogspot.com/p/uclinux.html)
- [TOPPERS/JSP](http://www.toppers.jp/)
- [HOS](https://sourceforge.jp/projects/hos/)
  - [HOS (gnu)](http://www.tt.rim.or.jp/~hoso/H8/)


## Reference
- TECH I 『技術者のためのUNIX系OS入門』 CQ Publishing
- トランジスタ技術 2002年3月号
- Hitachi Manual 各種
- H8マイコン完全マニュアル
- H8ビギナーズガイド
