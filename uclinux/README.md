# uClinux for H8 (2003)


## uClinux H8/300H を秋月 H8/3068 ボードで動かす (Binary)
バイナリイメージをDRAM上にloadしてuClinuxをboot

[uClinux H8/300H を秋月 H8/3068 ボードで動かす](https://sourceforge.jp/projects/uclinux-h8/document/uclinux-aki3068net/ja/2/uclinux-aki3068net.html)

[SourceForge: ucliux-h8](https://sourceforge.jp/projects/uclinux-h8/)を読みながら作業

リリースファイルから
- eCos/RedBootのROMイメージ
- コンパイル済みカーネル
- テスト用ルートイメージ
をdownloadし、解凍

May 19, 2003 現在、リリースされているの RedBoot には exec が組み込まれている


### Serial (RS232C)
[Open H8 Writer](http://www.linet.gr.jp/%7Emituiwa/h8/writer.html)で RedBoot を ROM に焼く(どの方法でも共通)

minicom (RS232C)でシリアル接続する
```
$ ./h8write -3068 redboot.mot # 3069の場合clockの指定も必要
$ minicom  # C-a pで38400bps 8N1に
++DP83902A - eeprom ESA: 00:02:cb:01:49:86
Ethernet eth0: MAC address 00:02:cb:01:49:86
Can't get BOOTP info for device!

RedBoot(tm) bootstrap and debug environment [ROM]
Non-certified release, version UNKNOWN - built 00:19:19, Jun 16 2002

Platform: Akizuki H8/3068 Network micom (H8/300H)
Copyright (C) 2000, 2001, 2002, Red Hat, Inc.

RAM: 0x00400000-0x005f4000, 0x00400000-0x005f4000 available
RedBoot> help
...
RedBoot> channel

Current console channel id: 0
RedBoot> load -r -v -b 0x400000 -m ymodem -c 0 linux.bin
(ここでlinux.binを転送。C-a sでymodemを選択しファイルを転送)
Raw file loaded 0x00400000-0x00487e6d, assumed entry at 0x00400000
xyzModem - CRC mode, 4351(SOH)/0(STX)/0(CAN) packets, 5 retries
RedBoot> load -r -v -b 0x4a0000 -m ymodem -c 0 rootimage.bin
 (同様にrootimage.binを転送)
Rae file loaded 0x004a0000-0x00502400, assumed entry at 0x004a0000
xyzModem - CRC mode, 3146(SOH)/0(STX)/0(CAN) packets, 3 retries
RedBoot> exec -c "console=/dev/ttyS1"

(linux-2.4.xの場合)
RedBoot> load -r -v -b 0x400000 -m ymodem -c 0 linux.bin
RedBoot> load -r -v -b 0x580000 -m ymodem -c 0 rootimage.bin
RedBoot> exec -c "console=ttySC1,38400n81"

Now booting linux kernel:
 Entry Address 0x00400000
 Cmdline : console=/dev/ttyS1

uClinux for H8/300H
H8/300H Porting by Yoshinori Sato
Flat model support (C) 1998,1999 Kenneth Albanowski, D. Jeff Dionne
Calibrating delay loop.. ok - 3.23 BogoMIPS
Memory available: 848k/1616k RAM, 0k/0k ROM (5280k kernel data, 406k code)
Swansea University Computer Society NET3.035 for Linux 2.0
NET3: Unix domain sockets 0.13 for Linux NET3.035.
Swansea University Computer Society TCP/IP for NET3.034
IP Protocols: ICMP, UDP, TCP
uClinux version 2.0.39.uc2 (ysato@vc6300cb1) (gcc version 2.95.3 20010315 (release))
Hitachi SCI driver version 0.01
hitachi-sci.c(1478): info=4789d2 num=0
ttySC0 at 0xffffb0 (irq = 52 - 55)
hitachi-sci.c(1478): info=478ad6 num=1
ttySC1 at 0xffffb8 (irq = 56 - 59)
hitachi-sci.c(1478): info=478bda num=2
ttySC2 at 0xffffc0 (irq = 60 - 63)
Ramdisk driver initialized : 16 ramdisks of 4096K size
lkmem copyright 1998,1999 D. Jeff Dionne
Blkmem copyright 1998 Kenneth Albanowski
Blkmem 1 disk images:
: 4A0000-5023FF (RO)
ne.c:v1.10 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)
NE*000 ethercard probe at 0x200000: 00 02 cb 01 49 86
eth0: NE1000 found at 0x200000, using IRQ 17.
VFS: Mounted root (romfs filesystem) readonly.
init start
# ls -F

bin/   dev/   etc/   proc/
# cd bin
# ls
arg_test     cat          hello        ifattach     init         ls
ount        ptrace_test  sh           signal       target       umount
# hello
Hello World
```
binary imageをシリアル(ymodem)で転送。
文書の通り BOOTP や TFPT を利用した方が便利そう。

(注) Debianの場合、`minicom` だけでなく `[xy]modem` で転送するならば `lrzsz` も必要。
```
$ apt-cache search lrzsz
lrzsz - Tools for zmodem/xmodem/ymodem file transfer
```


### [RedBoot](http://sources.redhat.com/redboot/)
The RedBoot User's Guide is available


RedBoot boot 後の IP address の設定
```
RedBoot> ip_address -l 192.168.0.43 -h 192.168.0.191
IP: 192.168.0.43, Default server: 192.168.0.191, DNS server IP: 0.0.0.0
```
BOOTP がなくても RedBoot で IP の設定ができ、ping 応答する。


uClinux boot 後の IP の設定方法
```
# ifattach --addr 192.168.0.43 --mask 255.255.255.0 --net 192.168.0.0 --gw 192.168.0.254 eth0
```
uClinux 起動後に `ifattach` で IP を設定。ping 応答する。

#### TFTP
Serial 転送だと時間がかかるので、TFTP を利用
- [netkit-tftp-0.17](ftp://ftp.uk.linux.org/pub/linux/Networking/netkit)
- [tftp-hpa-0.30](http://www.kernel.org/pub/software/network/tftp/)
等
```
$ configure
$ make
# make install
```
`/etc/inetd.conf` で TFTP を有効にし、`kill -HUP (inetd PID)`  
`linux.bin` と `rootimage.bin` を TFTP server に用意
```
$ pwd
/tftpboot
$ ls
linux.bin  rootimage.bin
```
Debian の場合
```
# apt-get install tftpd
$ grep tftpd /etc/inetd.conf
tftp            dgram   udp     wait    nobody  /usr/sbin/tcpd  /usr/sbin/in.tftpd /boot
```
`/boot` 以下に `linux.bin` と `rootimage.bin` を用意する。`inetd` を reboot

RedBoot において TFTP で kernel と rootimage を load
```
RedBoot> ip_address -l 192.168.0.43 -h 192.168.0.191
IP: 192.168.0.43, Default server: 192.168.0.191, DNS server IP: 0.0.0.0
RedBoot> load -r -v -m TFTP -b 0x400000 linux.bin
Raw file loaded 0x00400000-0x00487e6d, assumed entry at 0x00400000
RedBoot> load -r -v -m TFTP -b 0x4a0000 rootimage.bin
Raw file loaded 0x004a0000-0x00502400, assumed entry at 0x004a0000
RedBoot> exec -c "console=/dev/ttyS1"

(linux-2.4.xの場合)
RedBoot> load -r -v -m TFTP -b 0x400000 linux.bin
RedBoot> load -r -v -m TFTP -b 0x580000 rootimage.bin
RedBoot> exec -c "console=ttySC1,38400n81"
```

### DHCP
DHCP (BOOTP) serverを用意。

(Debianの場合)
```
# apt-get install dhcp3-server
$ man dhcpd.conf
# vi /etc/default/dhcp3-server (eth1)
# vi /etc/dhcp3/dhcpd.conf (fixed-address)
(以下、一部抜粋)
host wlan-h8 {
  hardware ethernet 00:02:cb:01:4c:c7;
  fixed-address 172.21.27.21;
}
```
hardware ethernet (MAC address) に fixed-address でIPを割り当てておく。 その他、subnet の設定。
```
$ minicom
+DP83902A - eeprom ESA: 00:02:cb:01:4c:c7
Ethernet eth0: MAC address 00:02:cb:01:4c:c7
IP: 172.21.27.21/255.255.255.0, Gateway: 172.21.27.48
Default server: 172.21.27.48, DNS server IP: 0.0.0.0

RedBoot(tm) bootstrap and debug environment [ROM]
Non-certified release, version UNKNOWN - built 18:26:09, Apr  3 2003

Platform: Akizuki H8/3068 Network micom (H8/300H)
Copyright (C) 2000, 2001, 2002, Red Hat, Inc.

RAM: 0x00400000-0x005f4000, 0x00400000-0x005f4000 available
RedBoot> ip_address
IP: 172.21.27.21/255.255.255.0, Gateway: 172.21.27.48
Default server: 172.21.27.48, DNS server IP: 0.0.0.0
```
電源を入れるだけで、IP や Host address (Default server) が自動的に割り当てられる。


### NFS root
sourceforge.jp から NFS root 用 kernel (linux-2.0.x で確認)を downlaod  
`rootimage.tar.gz` も download し展開。 展開した directory を NFS server として export。
```
$ pwd
/home/atsuya-o/elec/wlan/rootimage
$ find
.
./bin
./bin/ls
./bin/sh
./bin/cat
./bin/init
./bin/hello
./bin/mount
./bin/ifattach
./bin/arg_test
./bin/signal
./bin/target
./bin/umount
./bin/ptrace_test
./dev
./dev/tty1
./dev/console
./dev/ttyS0
./dev/ttyS1
./etc
./proc
$ ls -lR dev/* (mknodで作られる)
crw-r--r--    1 root     root       4,   0  8月 12  2001 console
crw-r--r--    1 root     root       4,   1  9月 24  2001 tty1
crw-r--r--    1 root     root       4,  64  8月 12  2001 ttyS0
crw-r--r--    1 root     root       4,  65  4月 21  2002 ttyS1
# vi /etc/exports
# /usr/sbin/exportfs -v -a
$ /usr/sbin/exportfs -v
/home/atsuya-o/elec/wlan/rootimage
                172.21.27.21(rw,async,wdelay,root_squash)
```
RedBoot で kernel のみ load しておき、後は NFS root として boot
```
RedBoot> load -r -v -m TFTP -b 0x400000 linux.bin
RedBoot> exec -c "console=/dev/ttyS1 nfsroot=172.21.27.48:/home/atsuya-o/elec/wlan/rootimage"
```


## Build kernel
バイナリの kernel を頂いてくるのではなく、自分でソースから kernel を build してみる。

### Development environment
binutils-2.12.1
```
$ tar Ixzf binutils-2.12.1.tar.bz2
$ cd binutils-2.12.1
$ ./configure --target=h8300-elf
$ make
# make install
```

gcc-3.2.1
```
$ tar Ixvf gcc-3.2.1.tar.bz2
$ cd gcc-3.2.1
$ patch -p1 &lt; ../gcc.diff  # (https://sourceforge.jp/frs/index.php?group_id=65 gcc patch (for 3.2.1))
(gcc.diff  10.9 KB  2002-11-24 22:50)
$ ./configure --target=h8300-elf --enable-languages='c,c++'
$ make
# make install
```

### Make kernel
- [uClinux](http://www.uclinux.org/)
- [uClinux Distribution](http://www.uclinux.org/pub/uClinux/dist/)
- [Full Source Distribution (20030305)](http://www.uclinux.org/pub/uClinux/dist/uClinux-dist-20030305.tar.gz)
を download。
uclinux.org で配布しているパッケージの H8/300 対応差分 (H8S用)を download
[h8-dist-20030305-20030430.patch.gz](http://www.uclinux.org/pub/uClinux/ports/h8/h8-dist-20030305-20030430.patch.gz)

追記 (June 8, 2003)
Full Source Distribution (20030522)
[uClinux-dist-20030522.tar.gz](http://www.uclinux.org/pub/uClinux/dist/uClinux-dist-20030522.tar.gz)
が release され、 H8S 対応の patch が取り込まれた。
```
$ wget http://www.uclinux.org/pub/uClinux/dist/uClinux-dist-20030305.tar.gz
$ wget http://www.uclinux.org/pub/uClinux/ports/h8/h8-dist-20030305-20030430.patch.gz
$ tar zxvf uClinux-dist-20030305.tar.gz
$ cd uClinux-dist
$ zcat ../h8-dist-20030305-20030430.patch.gz | patch -p0
$ cd linux-2.4.x/
$ vi Makefile
ARCH := h8300
CROSS_COMPILE   = h8300-elf-
$ make menuconfig # (debianの場合libncurses5-devが必要。# apt-get install libncurses5-dev)
$ grep -v ^# .config | grep -v ^$
CONFIG_UCLINUX=y
CONFIG_UID16=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
CONFIG_EXPERIMENTAL=y
CONFIG_BOARD_AKI3068NET=y
CONFIG_H83068=y
CONFIG_CLK_FREQ=20000
CONFIG_RAMKERNEL=y
CONFIG_NE_BASE=0x200000
CONFIG_NE_IRQ=5
CONFIG_CPU_H8300H=y
CONFIG_NET=y
CONFIG_KCORE_ELF=y
CONFIG_BINFMT_FLAT=y
CONFIG_BINFMT_ZFLAT=y
CONFIG_BINFMT_SHARED_FLAT=y
CONFIG_DEFAULT_CMDLINE=y
CONFIG_KERNEL_COMMAND="console=ttySC0,38400n81"
CONFIG_BLK_DEV_BLKMEM=y
CONFIG_NOFLASH=y
CONFIG_PACKET=y
CONFIG_INET=y
CONFIG_NETDEVICES=y
CONFIG_NET_ETHERNET=y
CONFIG_NET_ISA=y
CONFIG_NE2000=y
CONFIG_SH_SCI=y
CONFIG_SERIAL_CONSOLE=y
CONFIG_RAMFS=y
CONFIG_PROC_FS=y
CONFIG_ROMFS_FS=y
CONFIG_SYSCALL_PRINT=y
$ LANG=C make dep clean linux.bin
```
カーネル(linux.bin)ができる。

### Build userland</h4><p>ユーザランドを自分で構築する。

#### [uClibc](http://www.uclibc.org/)
uClibc-0.9.19.tar.bz2
```
$ vi Rules.mak
CROSS=h8300-elf-
$ make menuconfig (まだ最低限しか試していない)
$ grep -v ^# .config | uniq
ARCH_HAS_NO_MMU=y
ARCH_HAS_C_SYMBOL_PREFIX=y
WARNINGS="-Wall"
KERNEL_SOURCE="/home/atsuya-o/elec/wlan/uClinux-dist/linux-2.4.x"
UCLIBC_UCLINUX_BROKEN_MUNMAP=y
EXCLUDE_BRK=y
C_SYMBOL_PREFIX="_"
HAVE_DOT_CONFIG=y
MALLOC=y
DEVEL_PREFIX="/usr/local/$(TARGET_ARCH)-linux-uclibc"
SYSTEM_DEVEL_PREFIX="$(DEVEL_PREFIX)"
DEVEL_TOOL_PREFIX="$(DEVEL_PREFIX)/usr"
$ make
# make install
```

uClibc (libc.a) を uClinux とは関係なく利用

uClinux の userland でなくても、newlib を C library として使うように uClibc も利用できる。
ここでは H8 のプログラム開発を OS 無しで行なっている場合、uClibc の利用方法を簡単に記述する。

sample program: [sample.tar.bz2](https://www.dropbox.com/s/khuf0780m8k495o/sample.tar.bz2?dl=0)
make すると以下のような command が実行される。
```
$ h8300-elf-gcc -mh -mrelax -mint32  -nostartfiles -nodefaultlibs \
-nostdlib -Wall -v -I.  -I/usr/local/h8300-linux-uclibc/include -o hello \
crt0.s hello.c sci.c -Wl,-Th83069Fredboot.x \
-Wl,-Map,hello.map -L/usr/local/h8300-linux-uclibc/lib -lc -lgcc \
-Wl,-static -Wl,-v
$ h8300-elf-objcopy -O srec hello hello.mot
$ h8300-elf-objcopy -O binary hello hello.bin
```
`hello.c` の中で `sprintf()` (libc.a) 利用し、static に link する。 objcopy で srec (Motorola S format) や binary に変換する。

(注) linker script  
`LDFLAGS += -Wl,-Map,$@.map` により `.rodata.str1.1` などが 0x000000 にできていた。 これでは実機のメモリ空間に転送できない。
http://www.skyfree.org/jpn/interface/questions.html
「Red Hat 環境での .rodata セクションについて 2002/6/20 竹下様」
と同じ問題なので linker script を修正
```
$ diff -C 3 sample/h83069Fredboot.x dump/h83069Fredboot.x
*** sample/h83069Fredboot.x     Tue May 13 11:51:23 2003
--- dump/h83069Fredboot.x       Thu Feb  6 00:10:04 2003
***************
*** 112,118 ****
  .text : {
          *(.text)
          *(.strings)
!       *(.rodata*)
         _etext = . ;
        } > rom
  .tors : {
--- 112,118 ----
  .text : {
        *(.text)
        *(.strings)
!       *(.rodata)
         _etext = . ;
        } > rom
  .tors : {
```

#### elf2flt
uclinux.org で配布されている `elf2flt` は h8300h 未対応だったので、cvs.uclinux.org から check out。
```
$ cvs -d:pserver:anonymous@cvs.uclinux.org:/var/cvs login
Logging in to :pserver:anonymous@cvs.uclinux.org:2401/var/cvs
CVS password: 
$ cvs -z3 -d:pserver:anonymous@cvs.uclinux.org:/var/cvs co -P elf2flt
$ cd elf2flt
$ ./configure --target=h8300-elf \
--with-libbfd=/usr/local/lib/libbfd.a \
--with-libiberty=/usr/local/lib/libiberty.a \
--with-bfd-include-dir=/usr/local/include \
--with-binutils-include-dir=/home/atsuya-o/download/binutils-2.12.1/include
 (binutilsのsrc)

$ make
# make install
/usr/bin/install -c -s -m 755 flthdr /usr/local/bin/h8300-elf-flthdr
/usr/bin/install -c -s -m 755 flthdr /usr/local/h8300-elf/bin/flthdr
/usr/bin/install -c -s -m 755 elf2flt /usr/local/bin/h8300-elf-elf2flt
/usr/bin/install -c -s -m 755 elf2flt /usr/local/h8300-elf/bin/elf2flt
[ -f /usr/local/bin/h8300-elf-ld.real ] || \
        mv /usr/local/bin/h8300-elf-ld /usr/local/bin/h8300-elf-ld.real
[ -f /usr/local/h8300-elf/bin/ld.real ] || \
        mv /usr/local/h8300-elf/bin/ld /usr/local/h8300-elf/bin/ld.real
/usr/bin/install -c -m 755 ./ld-elf2flt /usr/local/bin/h8300-elf-ld
/usr/bin/install -c -m 755 ./ld-elf2flt /usr/local/h8300-elf/bin/ld
/usr/bin/install -c -m 644 ./elf2flt.ld /usr/local/h8300-elf/lib
```
本物の `h8300-elf-ld` を `h8300-elf-ld.real` に置き換えている。

(注) `ld-elf2flt.in`

elf (Executable and Linking Format) からflt (Binary Flat Format) にうまく変換できなかった。

`ld-elf2flt.in` を修正した。
patchを作りました。`-m h8300helf` を強引に追加。
[elf2flt.h8300helf.diff.gz](https://www.dropbox.com/s/ljh65fejfw0r5pj/elf2flt.h8300helf.diff.gz?dl=0) ($ cvs update @ May 21, 2003対応)
```
$ cd elf2flt
$ make distclean
$ zcat ../elf2flt.h8300helf.diff.gz | patch -p1
patching file ld-elf2flt.in
$ ./configure --target=h8300-elf \
--with-libbfd=/usr/local/lib/libbfd.a \
--with-libiberty=/usr/local/lib/libiberty.a \
--with-bfd-include-dir=/usr/local/include \
--with-binutils-include-dir=/home/atsuya-o/download/binutils-2.12.1/include
$ make
# make install
```

#### 簡単な /bin/init で boot 確認
`/bin/init` は本来 shell を exec したり様々な処理をする。しかし、まず初めに kernel の boot 完了し、/bin/init を exec することを確認したい。

そこで `printf("hello world!\n");` のみの簡単な `init.c` を書き動作を確認した。
ついでに、userland program の make 方法の確認にもなりそう。

[init.tar.bz2](https://www.dropbox.com/s/fv8rla5zcqda4cz/init.tar.bz2?dl=0)
```
$ tar jxvf init.tar.bz2
$ cd init
$ make
h8300-elf-gcc -mh -mint32 -static -nostartfiles
/usr/local/h8300-linux-uclibc/lib/crt0.o
-I. -I/usr/local/h8300-linux-uclibc/include -Wall -v -save-temps -o init
init-hello.c -L/usr/local/h8300-linux-uclibc/lib -Wl,-elf2flt
-Wl,-move-rodata -Wl,--verbose
```
init (flt) ができた。

#### genromfs
Debian の場合
```
# apt-get install genromfs
$ /usr/sbin/genromfs -h
genromfs 0.5.1
Usage: /usr/sbin/genromfs [OPTIONS] -f IMAGE
Create a romfs filesystem image from a directory

  -f IMAGE               Output the image into this file
  -d DIRECTORY           Use this directory as source
  -v                     (Too) verbose operation
  -V VOLUME              Use the specified volume name
  -a ALIGN               Align regular file data to ALIGN bytes
  -A ALIGN,PATTERN       Align all objects matching pattern to at least ALIGN bytes
  -x PATTERN             Exclude all objects matching pattern
  -h                     Show this help
```
root file system (romfs) を作成する。
```
$ mkdir rootfs; cd rootfs;
$ mkdir bin
$ cp ../init/init(.elf.bflt) bin/init (自作したinitをcopy)

# mknod dev/console c 5 1
# mknod dev/tty0 c 4 0
# mknod dev/ttySC0 c 4 64
# mknod dev/ttySC1 c 4 65
$ mkdir etc
$ mkdir proc
$ cd ../; ls -l rootfs/dev/
crw-r--r--    1 root     root       5,   1  5 19 18:08 console
crw-r--r--    1 root     root       4,   0  5 19 18:09 tty0
crw-r--r--    1 root     root       4,  64  5 19 17:56 ttySC0
crw-r--r--    1 root     root       4,  65  5 19 17:56 ttySC1
$ /usr/sbin/genromfs -v -f rootfs.bin -d rootfs/
```

### boot
自分で make した kernel (linux.bin)、genromfs で生成した romfs (rootfs.bin) を TFTP server に置いて実機で boot。
```
$ minicom -c on
RedBoot> load -r -v -m TFTP -b 0x400000 linux.bin
RedBoot> load -r -v -m TFTP -b 0x580000 rootfs.bin
RedBoot> exec -c "console=ttySC1,38400n81"
```


## uClinux-dist (source distribution package for uClinux)
ここに置いてある patch は uclinux-h8 本家 [uclinux-h8.sourceforge.jp] に取り込まれました。
開発環境の patch なども本家のものを使って下さい。ここの情報は古くなっていますのでご注意ください。 (Aug 9, 2003)
[Full Source Distribution (20030522)](http://www.uclinux.org/pub/uClinux/dist/)

userland program 強化のため、uClinux-dist (uClinuxのdistribution) を利用する。
uClinux-dist に vender/Hitachi/aki3068net/* を追加し、 uClinux-dist を aki3068net 対応にする。
これにより、簡単に aki3068net 用の kernel と root file system を構築できる。

ただし、前章の kernel や uClibc の設定を変更しているため、若干の開発環境の調整が必要であった。

### Compilation
uClinux-dist に含まれている userland program を compile するために、 前章の `uClibcの.config` などを変更している。
そのため、開発環境の再調整が必要だった。

#### Header file
uClibcの浮動小数点演算対応のための調整

H8 は FPU (Floating point number Processing Unit) を持っていないので、浮動小数点演算は uClibc で対応させる。

`uClibc/.config` より一部抜粋
```
UCLIBC_HAS_FLOATS=y
# HAS_FPU is not set
UCLIBC_HAS_SOFT_FLOAT=y
```
gcc の patch に含まれている `float.h` から他の header file が呼ばれるが、 userland の compile だと header file が見つからないので用意してやる。
```
$ pwd
/usr/local/lib/gcc-lib/h8300-elf/3.2.1/include
# mkdir config
# mkdir config/h8300
# cp ~atsuya-o/download/gcc-3.2.1/gcc/config/h8300/h8300.h config/h8300/
# cp ~atsuya-o/download/gcc-3.2.1/gcc/config/dbxcoff.h .
```

#### elf2flt
userland program を make したときの `h8300-elf-ld` (elf2flt) の DWARF Error に対応(無視)

elf2flt は .elf, .elf2flt, .gdb を作ってから flt を作るが、elf から flt を作るように強引に改変した。

patch [elf2flt.h8300helf.patch.gz](https://www.dropbox.com/s/38q0zilehjftpa9/elf2flt.h8300helf.patch.gz?dl=0)

June 8, 2003 現在の elf2flt [cvs.uclinux.org] に対応)を当てて再 install。
(上記の`-m h8300helf` の patch を含んでます。debug のための情報を冗長に出力)
```
$ cd elf2flt
$ make distclean
$ zcat ../elf2flt.h8300helf.patch.gz | patch -p1
patching file ld-elf2flt.in
$ ./configure --target=h8300-elf \
--with-libbfd=/usr/local/lib/libbfd.a \
--with-libiberty=/usr/local/lib/libiberty.a \
--with-bfd-include-dir=/usr/local/include \
--with-binutils-include-dir=/home/atsuya-o/download/binutils-2.12.1/include
$ make
# make install
```

#### Build
http://www.uclinux.org/pub/uClinux/dist/uClinux-dist-20030522.tar.gz
を download して展開。patch を当て、make するだけで kernel と root file system ができる。
[aki3068net-dist-20030522-20030614.patch.gz](https://www.dropbox.com/s/2iyowp50h4x9310/aki3068net-dist-20030522-20030614.patch.gz?dl=0) (network非対応)

この patch は `vender/Hitachi/` 以下に `aki3068net` を作り、中に file を作る。

(`vender/Hitachi/`ではなくて`vender/Akizuki/`にすべき？)

```
$ wget http://www.uclinux.org/pub/uClinux/dist/uClinux-dist-20030522.tar.gz
$ tar zxvf uClinux-dist-20030522.tar.gz
$ cd uClinux-dist/
$ zcat ../aki3068net-dist-20030522-20030614.patch.gz  | patch -p1
$ make menuconfig
    (Hitachi/aki3068net) Vendor/Product
    (linux-2.4.x) Kernel Version
    (uClibc) Libc Version
    [*] Default all settings (lose changes) (NEW)
    [ ] Customize Kernel Settings (NEW)
    [ ] Customize Vendor/User Settings (NEW)
    [ ] Update Default Vendor Settings (NEW)
$ make dep
$ LANG=C make
```
これで `uClinux-dist/images/linux.bin` (kernel) と `uClinux-dist/images/rootfs.img` (root file system) が出来上がる。

network 対応 patch (Jun 18, 2003)

[aki3068net-dist-20030522-20030618.patch.gz](https://www.dropbox.com/s/g07cox78pha79lm/aki3068net-dist-20030522-20030618.patch.gz?dl=0)
```
$ tar zxvf uClinux-dist-20030522.tar.gz
$ cd uClinux-dist/
$ zcat ../aki3068net-dist-20030522-20030618.patch.gz  | patch -p1
$ make menuconfig
(以下同様)
```
これらのパッチは `uclinux-h8` 本家に取り込まれました。(Aug 9, 2003)

#### Boot
`uClinux-dist/images/linux.bin`, `uClinux-dist/images/rootfs.img` を TFTP server 上に配置し、 RedBoot で load し exec
```
$ minicom -c on
RedBoot> load -r -v -m TFTP -b 0x400000 linux.bin
Raw file loaded 0x00400000-0x004cf8cf, assumed entry at 0x00400000
RedBoot> load -r -v -m TFTP -b <b>0x5c0000</b> rootfs.img
 (network非対応patchだと<b>0x580000</b>)

Raw file loaded 0x005c0000-0x005e8fff, assumed entry at 0x005c0000
RedBoot> exec -c "console=ttySC1,38400n81"
Now booting linux kernel:
 Entry Address 0x00400000
 Cmdline : console=ttySC1,38400n81
Linux version 2.4.20-uc0 (atsuya-o@wonder48) (gcc version 3.2.1)
 #1 Wed Jun 18 21:23:33 JST 2003
uClinux H8/300H
Target Hardware: AE-3068
H8/300 series support by Yoshinori Sato <ysato@users.sourceforge.jp>
Flat model support (C) 1998,1999 Kenneth Albanowski, D. Jeff Dionne
On node 0 totalpages: 1472
zone(0): 0 pages.
zone(1): 1472 pages.
zone(2): 0 pages.
Kernel command line: console=ttySC1,38400n81
Calibrating delay loop... 3.30 BogoMIPS
Memory available: 884k/962k RAM, 0k/0k ROM (666k kernel code, 157k data)
Dentry cache hash table entries: 1024 (order: 1, 8192 bytes)
Inode cache hash table entries: 512 (order: 0, 4096 bytes)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
Buffer-cache hash table entries: 1024 (order: 0, 4096 bytes)
Page-cache hash table entries: 2048 (order: 1, 8192 bytes)
POSIX conformance testing by UNIFIX
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
Starting kswapd
SuperH SCI(F) driver initialized
ttySC0 at 0x00ffffb0 is a SCI
ttySC1 at 0x00ffffb8 is a SCI
ttySC2 at 0x00ffffc0 is a SCI
ne.c:v1.10 9/23/94 Donald Becker (becker@scyld.com)
Last modified Nov 1, 2000 by Paul Gortmaker
NE*000 ethercard probe at 0x200000:&lt;4&gt;eth0: interrupt from stopped card
 00 02 cb 01 4c c7
eth0: NE1000 found at 0x200000, using IRQ 17.
Blkmem copyright 1998,1999 D. Jeff Dionne
Blkmem copyright 1998 Kenneth Albanowski
Blkmem 1 disk images:
0: 5C0000-5E8FFF [VIRTUAL 5C0000-5E8FFF] (RO)
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 512 buckets, 4Kbytes
TCP: Hash tables configured (established 512 bind 1024)
VFS: Mounted root (romfs filesystem) readonly.
Freeing unused kernel memory: 0k freed (0x4b2000 - 0x4b1000)
Welcome to
          ____ _  _
         /  __| ||_|
    _   _| |  | | _ ____  _   _  _  _ 
   | | | | |  | || |  _ \| | | |\ \/ /
   | |_| | |__| || | | | | |_| |/    \
   |  ___\____|_||_|_| |_|\____|\_/\_/
   | |
   |_|

Hitachi/aki3068net port.
For further information check:
http://www.uclinux.org/

# ls
tmp sbin var usr proc mnt lib home etc dev bin
# ifconfig eth0 172.21.27.29 netmask 255.255.255.0
# ping 172.21.27.48

172.21.27.48 is alive!
# route add default gw 172.21.27.1
# 
```

### Serial console on SCI0 (/dev/ttySC0)
これまで serial console に SCI1 を用いてきた。ここでは SCI0 を用いる。
SCI1 は aki3068net ボードの CN4 (D-sub 9pin コネクタ) に接続されているが、SCI0 は JP1 に接続されている。 JP1 に D-sub 9pin コネクタを追加し、ストレートケーブルで PC と接続する。

![sci0_photo](https://github.com/geodenx/h8/assets/2067742/95d2f125-b2cc-4ac7-a414-e51272ad2562)
![sci0_schematic](https://github.com/geodenx/h8/assets/2067742/fcbc9edc-4485-4fba-aa0e-543e0dcab141)

最初、SCI1 (CN4) 経由で RedBoot により serial console のポートに SCI0 を指定して kernel を boot する。 
```
(SCI1と同様にkernelとroot file systemをload後)
RedBoot&gt; exec -c "console=ttySC0,38400n81"
```
SCI0 に接続した PC (ポート)から boot message が流れる。

### Userland sample
uClinux-distで作ったkernel上で動くuserland programのサンプル。
sample program:
- [hello.c](https://www.dropbox.com/s/q9prullynq0msx3/hello.c?dl=0)
- [Makefile](https://www.dropbox.com/s/tg6eu4n6sgubgfw/Makefile?dl=0)
`make` して、`uClinux-dist/romfs/bin` 以下に格納。
`uClinux-dist/` のディレクトリで `make image` すると `uClinux-dist/images/rootfs.img` に `hello` が含まれる。
上記と同様に kernel を boot し、hello を実行。
```
# hello
Hello, world form uclinux-h8!
```


## H8MAX
H8MAX で、uclinux-h8 を動作させる。 (Sep 11, 2003)

![h8max](https://github.com/geodenx/h8/assets/2067742/0ba8864a-e123-45aa-92d9-00e8134f0f78)

### Development environment</h5><p>開発環境が古くなってきたので、入れ換える。
binutils-2.14
```
$ tar zxvf binutils-2.14.tar.gz
$ cd binutils-2.14
$ ./configure --target=h8300-elf
$ make
# make install
```
gcc-3.3
```
$ tar zxvf gcc-3.3.tar.gz
$ cd gcc-3.3
$ patch -p1 &lt; ../gcc-3.3.diff
$ ./configure --target=h8300-elf \
 --with-newlib \
 --with-headers=/home/atsuya-o/download/newlib-1.11.0/newlib/libc/include \
 --enable-languages='c'
$ make
# make install
```
elf2flt
```
$ wget http://keihanna.dl.sourceforge.jp/uclinux-h8/5236/elf2flt.patch
$ cd elf2flt-cvs
(cvs 同期)
$ patch -p0 &lt; ../elf2flt.patch
(rejectされた部分は手動でパッチ)
$ ./configure --target=h8300-elf --with-libbfd=/usr/local/lib \
 --with-bfd-include-dir=/usr/local/include \
 --with-binutils-include-dir=/home/atsuya-o/download/binutils-2.14/include
$ make
# make install
```

### Build kernel and romfs, and boot
Build kernel and romfs with uClinux-dist
```
$ wget http://ip-sol.jp/h8max/down/uClinux-dist-h8300.tar.bz2
$ tar jxvf uClinux-dist-h8300.tar.bz2
$ cd uClinux-dist-h8300
$ make menuconfig
    (strawberry-linux/H8MAX) Vendor/Product
    (linux-2.4.x) Kernel Version
    (uClibc) Libc Version
    [*] Default all settings (lose changes) (NEW)
    [ ] Customize Kernel Settings (NEW)
    [ ] Customize Vendor/User Settings (NEW)
    [ ] Update Default Vendor Settings (NEW)
$ make dep
(genromfs, flthdrをpathの通る場所に置いておく、あるいはpathを通す)

$ export LANG=C
$ make
```
`uClinux-dist-h8300/images/h8max-image.bin` が kernel+romfs。 これを TFTP server に置く

### Boot RedBoot and uClinux
```
$ wget http://ip-sol.jp/h8max/down/redboot.mot.gz
$ gunzip redboot.mot.gz
(SW1を書き込みモードに設定)
# ./h8write -d -f25 -3069 redboot.mot
# vi /etc/dhcp3/dhcpd.conf
host h8max {
  hardware ethernet 00:02:cb:01:67:cf;
  fixed-address 172.21.27.22;
}
# /etc/init.d/dhcp3-server restart
(SW1を実行時(mode5)に設定)
$ minicom -c on
RedBoot> load -r -v -m TFTP -b 0x400000 h8max.bin
RedBoot> exec -c "console=ttySC1,38400n81"

(boot.messages省略)
/> ifconfig eth0 172.21.27.29 netmask 255.255.255.0
/> ping 172.21.27.48
172.21.27.48 is alive!
/>
```


## Reference
- uclinux-h8
  - Project Documentation http://sourceforge.jp/projects/uclinux-h8/docman/
- H8MAX
  - http://strawberry-linux.com/h8/h8max.html
  - http://www.nishimoto-site.net/~h8max/
- uClinux
  - uClinux.org http://www.uclinux.org/
  - uCdot http://www.ucdot.org/
- flt
  - Flat Binary http://www.beyondlogic.org/uClinux/bflt.htm
- elf
  - The Linux ELF HOWTO
  - Using ld
- Linux
  - https://www.kernel.org/doc/html/v4.18/admin-guide/serial-console.html
  - https://www.kernel.org/doc/Documentation/filesystems/romfs.txt
  - `usr/src/linux/Documentation/nfsroot.txt`
  - linux-2.4.x/drivers/block/blkmem.c
- eCos
  - ecos-h8 http://ecos-h8.sourceforge.jp/
  - Project Documentation https://sourceforge.jp/projects/ecos-h8/docman/
  - eCos http://sources.redhat.com/ecos/
- others
  - man h8300-elf-gcc
  - man h8300-elf-ld
  - man h8300-elf-readelf
  - man h8300-elf-nm
  - man genromfs
  - man mknod
  - man bootparam
  - CQ出版『Interface』2002 7月号
  - CQ出版『組み込みLinux入門』
