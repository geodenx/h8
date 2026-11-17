# WiFi with H8 (2004)

秋月電子通商 AKI-H8LAN ボードに無線 LAN CF (Compact Flash) カードを接続し、 無線 LAN (IEEE802.11b, WEP 128 bit 対応)、TCP/IP で双方向通信する。

Connect a Wireless LAN CF (Compact Flash) card to the Akizuki Denshi AKI-H8LAN board for bidirectional TCP/IP communication (IEEE802.11b, 128-bit WEP).

![System Diagram](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEizqfJiyx8ocLetyMXCeCGiLIRdHGliQvYEQrvbZz3fnd-RMKVxM_8FhdpkTaRVTtfP1dRI-_h9RSkp2OZa0cY9U3kRM7HH4GdnUoa49AJzTMttiEEzjc-AGf6gisnECEF0kd7Noifr2KOJ/s1600/system.png)

ラジコン(一方向通信)、リモートセンシング、リモートコントロールなどを、 少ないハードウェア資源で TCP/IP (双方向) 通信に置き換えることが狙い。 H8 で直接、無線 LAN カードを制御するので、USB コントローラや、10Base-T/802.11b ブリッジなどは不要。 既に制御系でH8を使っている場合は、マイコンの追加が不要。 ラジコンの通信チャンネルの不足問題も IPv4 で解決できる？

H8 のバスには 16 Mbit DRAM, 10Base-T Ethernet コントローラ (RTL8019AS), CF カードを接続。 OSとして uClinux が動作。PCMCIA 無線 LAN カードのデバイスドライバを移植した。 実績のある Linux の TCP/IP プロトコルスタックを使った通信が可能。 PCでのネットワークプログラミングで一般的なソケットインタフェースを使い、 通信プログラムを開発できる。

> We made the "wlan-h8" system composed of the AKIZUKI AKI-H8LAN board connected a wireless LAN Compact Flash (CF) card. It can communicate with TCP/IP on the wireless LAN (IEEE802.11b, WEP 128bit)
>
> The objective is the replacements for radio control, remote sensing or remote control and so on with smaller hardware resources. Since a H8 MCU controls the CF card directly, a USB controller or a 10Base-T/802.11b bridge is not required. If the system has already loaded H8 as a controller, you do not need to add an additional micro controller for the wireless LAN. It may be also a solution for the shortage of channels in a radio control.
>
> A 16 Mbit DRAM, a 10Base-T Ethernet controller (RTL8019AS) and a CF card are connected to the H8 external buses. We are utilizing uClinux as a operating system (OS) and have ported a PCMCIA wireless LAN card device driver. It enables to communicate by using a reliable TCP/IP protocol stack of Linux. Programmers are able to develop network programs with the socket interface, that is a common API as the network programming on UNIX.

---

## Hardware

* schematics: [h8-cf-2.2.ce3.png](h8-cf-2.2.ce3.png)
  * Jul 8, 2004: H8:~IRQ4 - CF:HIREQ-
  * Feb 8, 2005: CF:IREQ -> CD:-IREQ 極性修正 (polarity correction)
  * Aug 5, 2006: H8:D0-7 -> H8:D8-15
* wire assigments: [assign.h8-cf.txt](assign.h8-cf.txt)

AKI-H8LAN (AE3068)
* H8/3069F 20MHz; Flash ROM 512kByte, RAM 16kByte, memory mapped I/O
* DRAM 16M-DRAM(HM57117800TT-6) 16Mbit(2MByte)
* Ethernet Controller RTL8019AS

H8/3069F (mode 5) address space
| Address | Description |
| :--- | :--- |
| 0x000000 | vector table, ROM |
| 0x200000 (area1 ~CS1) | RTL8019AS (NE2000) |
| 0x400000 (area2 ~CS2) | DRAM (16Mbit) |
| 0x600000 (area3 ~CS3) | CF Card (attribute memory space) |
| 0x800000 (area4 ~CS4) | CF Card (I/O space) |
| 0xFEE000 | I/O Register(1), RAM, I/O Register(2) |

WLI-CF-S11G (MELCO Wireless LAN CF Card)
* 最大消費電力 (Power consumption max): 660mW (3.3V * 0.2A)
* Intersil PRISM2.5 ISL3873B (fn8019.pdf) Integrated MAC and Baseband Processor for PCMCIA and USB
* [melco.dump_cis.log](melco.dump_cis.log) (dump_cis on Linux)
* `CISTPL_DEVICE`, `CISTPL_DEVICE_A`, `CISTPL_DEVICE_OA`: [telco.cis.dev.png](telco.cis.dev.png)
* `CISTPL_CONFIG`, `CISTPL_CFTABLE_ENTRY`: [melco.cis.cfg.png](melco.cis.cfg.png)
* 8bit data bus connection (ISL3873B fn8019.pdf p.13) [bus.png](bus.png)
    * `HD[15:0]`: ホストインタフェースはワードアクセスを第1に設計されているが、すべての バイトアクセスモードも完全にサポートされいてる。詳細は次のHCE01-, HCE2-の項を見よ。なお、attribute memory空間は偶数バイトアクセスのみの 仕様になっている。
    * `HCE1-`, `HCE2-`: PC Cardのサイクルタイプとサイクル幅をCE信号とともに制御する。 PC Card standardに準拠したHCE1-とHCE2-、HA0の組合せを使用することによ り、ワードとバイトアクセスがサポートされている。

Other components
* 3.3V レギュレータ (regulater): 東芝 低ドロップ三端子レギュレ−タ TA48M033F(S) (正出力 +3.3V, 0.5A 面実装(DPAK) 千石100円)
* CF Card reset 回路 schematics (CF::RESET):
    ![Reset Circuit](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9YkjIPxiRxEptfTCx_XTEmVs_uLmVHCZNv8bShCu4YqWh3EOLdlgiN3HZ5xzTmYkqC9d8dzkXtSSI2WoFVgjgqpGWhkByY7usx3B2K3FcN-nWVKJQ7uiTJKKb2QqDYkhjPQpq4kpiypnx/s1600/reset.ce2.png)
    (R: 10kohm, C: 10uF, TC74HC14 Hex schmitt inverter)
* PCIC (PC Card Interface Controller):
    * TC74HC32: Toshiba 74HC32 Quad 2-Input OR Gate
    * TC74HC08: Toshiba 74HC08 Quad 2-Input AND Gate
* Sunhayato CK-14: CF -> Universal 変換基板 (translation board)

## PCB
CAD
- PCB http://bach.ece.jhu.edu/~haceaton/pcb/
- Eagle http://www.cadsoft.de/

- Version 2: [h8-cf-2.pcb](h8-cf-2.pcb) | [h8-cf-2.jpg](h8-cf-2.jpg)
![PCB Board](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEitt6Ox7Eux4dTaXi4Q3NwQSRfT328KK2ct3irCZ8l7jgVTMQGf0iR8tnIU-a82w7hRAwPCB7Try6rQ3B3pCRxuPgS5piFrk4_7iGiuqzqST-vZb6XnKq3-sKXbmvT_ztUSoUVEBnqJR6Ba/s320/h8-cf-2.board.jpg)
    - Updates from version 1: rotate CK-14 (CF), CF::RESET, CF::-CE1 = (H8:-CS3)&(h8::-CS4), 74HC32::Vcc=3.3V -> 5.0V
- Version 1: [h8-cf.pcb](h8-cf.pcb) | [h8-cf.png](h8-cf.png)

## Waveforms
[dump.tar.bz2](dump.tar.bz2)

NE2000, DRAM, CF attribute, CF I/O を一度 memory dump した後、CF を Software Reset し再び memory dump する。
monitor 上での実行用と uClinux 上の userland program としての実行用の2種類を含む。

```console
$ tar jxf dump.tar.bz2 
dump/ (monitor上での実行用)
dump/3069s.h
dump/Makefile
dump/crt0.s (start up routine)
dump/h83069Fmon.x (Renesas monitor (DRAM利用)用 linker script)
dump/h83069Fredboot.x (redboot用linker script)

dump/h83069From.x (ROM化用linker script)
dump/dump.c
dump/sci.c (SCI driver)
dump/sci.h (SCI driver)
dump/monitor.mot (Renesas monitor (内蔵RAM利用))
dump/h83069Flmon.x (Renesas monitor (内蔵RAM利用)用 linker script)
dump/dump.log (RedBootでの実行結果)

dump/linux/ (uClinuxのuserland programとして実行)
dump/linux/Makefile
dump/linux/3069s.h
dump/linux/dump.c (printf()を利用。他のresource(OSが利用)へのアクセスを避ける)
dump/linux/dump.failed.log (elf2flt-wlanh8.diffを当てる前のアクセスエラーlog)
dump/linux/crt0.S
dump/linux/dump.crt0_ram.patch.log (crt0_ram.S.diffを当てた後。正常値)
$ cd dump; make (dump.mot (Motorola S format)が生成)
$ minicom
RedBoot> load -v -m TFTP -b 0x400000 dump.mot; go 0x400000
$ cd linux; make (dump (BINFLT)生成、ROMFS (NFS)にして実行)

$ minicom
RedBoot> load -r -m TFTP -b 0x400000 aki3068net-image.bin
RedBoot> exec -c "console=ttySC1,38400n81"
/> /usr/dump
```

### WLI-CF-S11G (BUFFALO wireless LAN CF Card)
電源投入直後 (reset回路 C=10uF, R=10kohm)
* Vcc, `CF::RESET`: [reset.png](reset.png)
* 74HC14::2A(In) (RC), `CF::RESET`: [rc.png](rc.png)
* `CF::RESET`, `CF::-HIREQ`: [hireq.png](hireq.png)

RESET (ISL3873B fn8019.pdf p.14)  
RESETがde-assertされたときに、CISテーブルが初期化され、初期化を完了す るとHIERQ-がhighになる(リセット直後はHIREQ-はRDY/BSYのようにふるまい、 そして、カードの利用準備ができることを示すhighになる)。CISテーブルは Flashメモリに入っていて、ファームウェアの初期化中にRAMにコピーされる。 ホストシステムはCIS情報を読み、コンフィグレーションレジスタに書き込む ことで、カードを初期化することができる。

Read Attribute Space: `dump.c`
- CF::-WAIT [waitcf.png](waitcf.png)
- CF::-WAIT without CF: [waitnocf.png](waitnocf.png)
- CF::-OE, -WEをアナログで観測(ロジック観測波形に重ね合わせ) [analogplus.png](analogplus.png)
- CF::-OE, -WEをアナログで観測(アナログ信号のみ) [analogonly.png](analogonly.png)

Read Attribute Space `dump.c` (3 state, 3 wait, enable BSC.BCR.WAITE)
- [melco.dump.log](melco.dump.log)
- [melco.dump.png](melco.dump.png)
- [waiteff.png](waiteff.png)
- [waitexx.png](waitexx.png)
- `dump_cis` on Linux: [melco.dump_cis.log](melco.dump_cis.log)

### Cf. Epson memory-mode CF Card (SunDisk)
Read attribute space (dump.c) (? state ? wait)
- [epson.dump.log](epson.dump.log)
- [epson.png](epson.png)
- [epson.dump_cis.log](epson.dump_cis.log) (`dump_cis` on Linux)

---

## Software

### Cross development environment `h8300-elf`

binutils-2.14
```console
$ tar zxvf binutils-2.14.tar.gz
$ cd binutils-2.14
$ ./configure --target=h8300-elf
$ make && make install
```

gcc-3.3
```console
$ tar zxvf gcc-3.3.tar.gz
$ cd gcc-3.3
$ patch -p1 < ../gcc-3.3.diff
$ ./configure --target=h8300-elf --with-newlib \
 --with-headers=$HOME/.../include --enable-languages='c'
$ make && make install
```

elf2flt: [elf2flt.patch](http://keihanna.dl.sourceforge.jp/uclinux-h8/5236/elf2flt.patch) に加え、CF Cardの領域(attribute空間 (, I/O空間))にuserlandから書き込みを許可するためにpatchが必要 (device driverで叩く分には必要なさそうだが)。
この2つの修正を含んだ elf2flt (Jan 14, 2004のCVS)に対する
* [elf2flt-wlanh8.diff](elf2flt-wlanh8.diff)
* [elf2flt-wlanh8.tar.bz2](elf2flt-wlanh8.tar.bz2)
```console
$ tar jxvf elf2flt-wlanh8.tar.bz2
$ cd elf2flt-wlanh8
$ ./configure --target=h8300-elf --with-libbfd=/usr/local/lib \
 --with-bfd-include-dir=/usr/local/include \
 --with-binutils-include-dir=$HOME/download/binutils-2.14/include
$ make
# make install
```

### boot loader, monitor
eCos, RedBoot: uClinuxのbootに必要
- [eCos-h8](http://sourceforge.jp/projects/ecos-h8/) [sourceforge.jp]
- [eCos](http://sources.redhat.com/ecos/) [redhat.com]
- [RedBoot](http://sources.redhat.com/redboot/) [redhat.com]

Hitachi Monitor: テスト用。運用時には不要
- [akih8mon.bat](akih8mon.bat)
- [monitor.aki](monitor.aki)
- [monitor.MOT](monitor.MOT)
- [h83069Flmon.x](h83069Flmon.x) (linker script for GNU ld (h8300-elf))

http://www.mechatronics.mech.tohoku.ac.jp/~kumagai/tech/h8/ の「モニタをなんとかする」を参考に。
AKI-H8LAN (H8/3067?, 3068, 3069)用 内蔵RAMにprogramをload (DRAM未使用)

### OS
- [uClinux](http://www.uclinux.org/)
- [uClinux-h8](http://sourceforge.jp/projects/uclinux-h8/)
- 通常の構築、利用方法は別ページ掲載 [uClinux for H8/300H](../uclinux)
- ビルド方法: [H8MAX](http://strawberry-linux.com/h8max/) の package を利用 
- Patch: [wlanh8.diff](wlanh8.diff)

```console
$ tar jxvf uClinux-dist-h8300.tar.bz2
$ cd uClinux-dist-h8300
$ patch -p1 < wlanh8.diff
# linux-2.4.x/arch/h8300/platform/h8300h/aki3068net/crt0_ram.S: 
#  area3,4をCF用bus timingに設定
# linux-2.4.x/drivers/net/wireless/Config.in:
#  orinoco_wlanh8.cを追加 (make *config用)
# linux-2.4.x/drivers/net/wireless/Makefile:
#  orinoco_wlanh8.cを追加
# linux-2.4.x/drivers/net/wireless/orinoco_wlanh8.c:
#  orinocoのwlan-h8ボード用wrapper
# linux-2.4.x/include/asm-h8300/io.h:
#  16bit read writeを8bitに分ける

$ make menuconfig
    (Akizuki/aki3068net) Vendor/Product  <---
    (linux-2.4.x) Kernel Version  <---
    (uClibc) Libc Version  <---
    [ ] Default all settings (lose changes) (NEW)
    [*] Customize Kernel Settings (NEW)  <---
    [*] Customize Vendor/User Settings (NEW)  <---
    [ ] Update Default Vendor Settings (NEW)
    kernelの設定
 Network device support
  [*] Wireless LAN (non-hamradio)  <---
  [*]   Hermes chipset 802.11b support (Orinoco/Prism2/Symbol)  <---
  [*]     Wlan-h8 support (EXPERIMENTAL)  <---
 というようにwlan-h8基板用の設定がでるのでonにする。
        その他は面倒なので $ grep =y linux-2.4.x/.config
        CONFIG_UCLINUX=y
        CONFIG_UID16=y
        CONFIG_RWSEM_GENERIC_SPINLOCK=y
        CONFIG_EXPERIMENTAL=y
        CONFIG_BOARD_AKI3068NET=y
        CONFIG_H83068=y
        CONFIG_RAMKERNEL=y
        CONFIG_CPU_H8300H=y
        CONFIG_NET=y
        CONFIG_KCORE_ELF=y
        CONFIG_BINFMT_FLAT=y
        CONFIG_DEFAULT_CMDLINE=y
        CONFIG_BLK_DEV_BLKMEM=y
        CONFIG_NOFLASH=y
        CONFIG_INET=y
        CONFIG_NETDEVICES=y
        CONFIG_NET_ETHERNET=y
        CONFIG_NET_ISA=y <---

        CONFIG_NE2000=y
        CONFIG_NET_RADIO=y  <---
        CONFIG_HERMES=y  <---
        CONFIG_WLANH8_HERMES=y  <---
        CONFIG_NET_WIRELESS=y  <---
        CONFIG_SH_SCI=y
        CONFIG_SERIAL_CONSOLE=y
        CONFIG_RAMFS=y
        CONFIG_PROC_FS=y
        CONFIG_ROMFS_FS=y
        CONFIG_NO_KERNEL_MSG=y
        CONFIG_ZLIB_INFLATE=y
    userlandの設定 (RAMがぎりぎりなので、なるべくダイエット)
 busyboxを使う (default)
  shutdown, rebootなどは削除 (IDE (CF)無しなのでいい?)
 iwconfig (wireless_tools) busyboxではなく単体のバイナリ
  Network Applications
  --- Wireless-tools
   [*] wireless_tools support  <---
   [*] iwconfig  <---
$ make dep
$ make clean
$ LANG=C make
```

#### Wireless LAN Device Driver
`linux-2.4.x/drivers/net/wireless/orinoco_wlanh8.c`: `wlanh8.diff` に含まれている。

Network interfaces
- eth0: RTL8019AS
- eth1: WLI-CF-S11G

`orionco_plx.c` から移植  
`orinoco_plx.c`はPCMCIA slotを持つPCI bus card。
PCMCIA slot に WiFi PCカードを挿入して使われる。`orinoco_plx.c`から`orinoco.c`, `hermes.c`と順に呼ばれる。

Prism chipsetのdevice driverの参考資料 [driver.txt](driver.txt)

#### Usage
生成された kernel & userland image `image/aki3068net-image.bin` を TFTP server に置く。

```console
$ minicom
RedBoot> load -r -v -m TFTP -b 0x400000 aki3068net-image.bin
RedBoot> exec -c "console=ttySC1,38400n81"
(uClinux-H8 boot 略)

/> free
/> ifconfig eth0 172.21.27.21 netmask 255.255.255.0
/> ping 172.21.27.48
/> iwconfig eth1 essid 'hoge' key s:wep_key_string
/> iwconfig
/> ifconfig eth1 163.221.183.73 netmask 255.255.255.0
/> ping 163.221.183.48
/> cat /proc/net/dev
/> route
/> cat /proc/kmsg

...
<7>orinoco.c 0.13b (David Gibson <hermes@gibson.dropbear.id.au> and others)
<7>hermes.c: 4 Dec 2002 David Gibson <hermes@gibson.dropbear.id.au>
<7>orinoco_wlanh8.c (OKAZAKI Atsuya <okazaki@zd.wakwak.com>)
<7>orinoco_wlanh8: CIS: 01:03:00:00:FF:17:04:67:
<7>Detected Orinoco/Prism2 wlan-h8 device at irq:16, io addr:0x800000
<7>eth1: Station identity 001f:0004:0001:0003

<7>eth1: Looks like an Intersil firmware version 1.3.4
<7>eth1: Ad-hoc demo mode supported
<7>eth1: IEEE standard IBSS ad-hoc mode supported
<7>eth1: WEP supported, 104-bit key (と言われるが、128bitで使えた)
<7>eth1: MAC address 00:07:40:0F:15:6B
<7>eth1: Station name "Prism  I"
<7>eth1: ready
...
<6>eth1: New link status: Connected (0001)
```

`/etc/rc` (`romfs/etc/rc`) に書けば起動時に実行される。
RedBootもscriptを埋め込み、自動でTFTPからバイナリを読み込み、bootすることが出来る(らしい)。
[inflate_boot](http://sourceforge.jp/projects/uclinux-h8/files/) [sourceforge.jp] を使えば、ROM化、standalone運用も出来る(らしい)。

### [Linux PCMCIA](http://pcmcia-cs.sourceforge.net/) [sourceforge.net]
- `/sbin/dump_cis`:`dump_cis` - display PCMCIA Card Information Structures. `/sbin/dump_cis -v >` [melco.dump_cis.log](melco.dump_cis.log)
- `/sbin/pack_cis`: compile PCMCIA Card Information Structures
- `/sbin/cardinfo`: PCMCIA card monitor and control utility for X
- `/sbin/cardctl`: PCMCIA card control utility
- `/sbin/cardmgr`: PCMCIA device manager

Debian GNU/Linux (woody) での WLI-CF-S11G の利用
```console
# apt-get install kernel-image-2.4.18-bf2.4
# apt-get install pcmcia-modules-2.4.18-bf2.4
(reboot)
# modconf
# vi /etc/pcmcia/config
card "BUFFALO WLI-CF-S11G"
  version "BUFFALO", "WLI-CF-S11G"
  bind "orinoco_cs"
を追加
# /etc/init.d/pcmcia restart
# apt-get install wireless-tools
# iwconfig eth0 essid 'hoge' key s:wep_key_strings
```

---

## Example Application: NTP Clock
PICNIC による [NTP Clock](https://github.com/geodenx/ntp_clock) の WiFi 版
原子時計に繋がった NTP server (ntp3.jst.mfeed.ad.jp) から timestamp を取得し、LCD に表示。
  <a href="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj-liVkkDdTleKLh4BwmfKrbC-ih84kXpZfv-TgTNblPu732jPqCex01gyehw_Ek0uBGP_ibPnYHasrBpCIxBtiUNT-7rCKdEw9f5RTOWsuYKFUoHcr3IsL5aNqZAzYND42NFs1uUCVfcp4/s1600/lcd.png">
    <img src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj-liVkkDdTleKLh4BwmfKrbC-ih84kXpZfv-TgTNblPu732jPqCex01gyehw_Ek0uBGP_ibPnYHasrBpCIxBtiUNT-7rCKdEw9f5RTOWsuYKFUoHcr3IsL5aNqZAzYND42NFs1uUCVfcp4/s1600/lcd.png" border="0" />
  </a>

[ntp.tar.bz2](ntp.tar.bz2)

```console
$ tar jxvf ntp.tar.bz2
ntp/
ntp/Makefile
ntp/lcd.c (LCD driver in userland)
ntp/lcd.h
ntp/3069s.h
ntp/lcd.lb3 (回路図 LCD library for qbsch)
ntp/lcd.ce3 (回路図 for qbsch)
ntp/ntp.c (main routing)

ntp/lcd.png (回路図 png)
ntp/linux/ (HOST PC (Linux)上でのテスト開発用)
ntp/linux/ntp.c
ntp/linux/Makefile
$ vi Makefile (DIST=書き換え)
$ make
```

<div align="center">
  <a href="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi682IT4Gqal8X-GoU027YgadlxByESV7GBrnLgvNfep7MRxcXoevbNvI5fM-XgWUBWe-flPlBxabrXxvW7oKN_N2VB1NlKVlKH6Xxl3-gTvb76-84vkPzWy36zczKegveQtkbL_m0J00uL/s1600/ntp.jpg">
    <img src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi682IT4Gqal8X-GoU027YgadlxByESV7GBrnLgvNfep7MRxcXoevbNvI5fM-XgWUBWe-flPlBxabrXxvW7oKN_N2VB1NlKVlKH6Xxl3-gTvb76-84vkPzWy36zczKegveQtkbL_m0J00uL/s320/ntp.jpg" width="255" height="320" border="0" />
  </a>
</div>

生成されたntp (flt binary) をuClinux-dist-h8300/romfs/usr/に入れ、 uClinux-dist-h8300以下でimageを生成 ($ make image)。 以降、上記(Instructions for running)手順と同様。

```console
/> iwconfig eth1 essid 'foo' key s:wep_key_strings
/> ifconfig eth1 163.221.183.73 netmask 255.255.255.0
/> route add default gw 163.221.183.1
/> /usr/ntp 210.173.160.87 (ntp3.jst.mfeed.ad.jp)
```

`unsigned int sleep(unsigned int seconds)` で1秒を生成しているので、正確な1秒ではない。
RAM容量がぎりぎりなので、romfsのサイズを小さくするため、`*printf()` や `perror()`は除いた。

---

## References
* CQ出版 [『LANによるハードウェア制御』](http://www.cqpub.co.jp/hanbai/books/37/37351.htm) 第4-8章 Appendix「μClinux/H8を利用した無線LANの実験」
* CQ出版 [『PCカード/メモリカードの徹底研究』](http://www.cqpub.co.jp/hanbai/books/522100.htm)
* [CFA](http://www.compactflash.org/) *CF+ and CompactFlash Specification Revision 1.4* (cfspc1_4.pdf)
* O'REILLY [『Linuxデバイスドライバ 第2版』](http://www.oreilly.co.jp/BOOK/lidriver2/)
* H8/3069F-ZTAT ハードウェアマニュアル
* [いしかわさん](http://www.asahi-net.or.jp/%7Eqx5k-iskw/robot/wave.html) AVR
* [成松さん](http://www.narimatsu.net/nari_page/lcardPlus.html) L-Card (VR (mips))
* [秋田さん](http://www.fun.ac.jp/%7Eakita/plan/#1) H8-PCMCIA

## Contributors

* OKAZAKI Atsuya
* TOGAWA Satoshi
