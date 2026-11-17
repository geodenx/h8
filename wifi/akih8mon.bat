SET PATH=C:\home\okazaki\h8\asm;%PATH%
REM -ADVCMD-

mkdir objs
a38h monitor.src -CPU=300HA
MOVE monitor.obj Objs
MOVE Monitor.lis Objs
cd advcmd
a38h cmd01.src -CPU=300HA
a38h cmd02.src -CPU=300HA
a38h cmd03.src -CPU=300HA
a38h cmd04.src -CPU=300HA
a38h cmd05.src -CPU=300HA
a38h cmd06.src -CPU=300HA
a38h cmd07.src -CPU=300HA
a38h cmd08.src -CPU=300HA
a38h cmd09.src -CPU=300HA
a38h cmd10.src -CPU=300HA
a38h cmd11.src -CPU=300HA
a38h cmd12.src -CPU=300HA
a38h cmd13.src -CPU=300HA
a38h cmd14.src -CPU=300HA
a38h cmd15.src -CPU=300HA
a38h cmd16.src -CPU=300HA
a38h cmd17.src -CPU=300HA
a38h cmd18.src -CPU=300HA
a38h cmd19.src -CPU=300HA
a38h cmd20.src -CPU=300HA
a38h cmd21.src -CPU=300HA
a38h cmd22.src -CPU=300HA
a38h cmd23.src -CPU=300HA
a38h cmd24.src -CPU=300HA
a38h cmd25.src -CPU=300HA
a38h cmd26.src -CPU=300HA
a38h cmd27.src -CPU=300HA
a38h cmd28.src -CPU=300HA
a38h cmd29.src -CPU=300HA
a38h cmd30.src -CPU=300HA
a38h cmd31.src -CPU=300HA
a38h cmd32.src -CPU=300HA
a38h cmd33.src -CPU=300HA
a38h cmd34.src -CPU=300HA
a38h cmd35.src -CPU=300HA
a38h cmd36.src -CPU=300HA
a38h cmd37.src -CPU=300HA
a38h cmd38.src -CPU=300HA
a38h cmd39.src -CPU=300HA
a38h cmd40.src -CPU=300HA
move *.obj ..\objs
move *.lis ..\objs
cd ..
REM -ADVCMD-
cd advdmy
a38h dmy01.src -CPU=300HA
a38h dmy02.src -CPU=300HA
a38h dmy03.src -CPU=300HA
a38h dmy04.src -CPU=300HA
a38h dmy05.src -CPU=300HA
a38h dmy06.src -CPU=300HA
a38h dmy07.src -CPU=300HA
a38h dmy08.src -CPU=300HA
a38h dmy09.src -CPU=300HA
a38h dmy10.src -CPU=300HA
a38h dmy11.src -CPU=300HA
a38h dmy12.src -CPU=300HA
a38h dmy13.src -CPU=300HA
a38h dmy14.src -CPU=300HA
a38h dmy15.src -CPU=300HA
a38h dmy16.src -CPU=300HA
a38h dmy17.src -CPU=300HA
a38h dmy18.src -CPU=300HA
a38h dmy19.src -CPU=300HA
a38h dmy20.src -CPU=300HA
a38h dmy21.src -CPU=300HA
a38h dmy22.src -CPU=300HA
a38h dmy23.src -CPU=300HA
a38h dmy24.src -CPU=300HA
a38h dmy25.src -CPU=300HA
a38h dmy26.src -CPU=300HA
a38h dmy27.src -CPU=300HA
a38h dmy28.src -CPU=300HA
a38h dmy29.src -CPU=300HA
a38h dmy30.src -CPU=300HA
a38h dmy31.src -CPU=300HA
a38h dmy32.src -CPU=300HA
a38h dmy33.src -CPU=300HA
a38h dmy34.src -CPU=300HA
a38h dmy35.src -CPU=300HA
a38h dmy36.src -CPU=300HA
a38h dmy37.src -CPU=300HA
a38h dmy38.src -CPU=300HA
a38h dmy39.src -CPU=300HA
a38h dmy40.src -CPU=300HA
move *.obj ..\objs
move *.lis ..\objs
cd ..
REM -ADVINT-
REM -ADVMOD-
cd advmod
a38h mod01.src -CPU=300HA
a38h mod02.src -CPU=300HA
a38h mod03.src -CPU=300HA
a38h mod04.src -CPU=300HA
a38h mod05.src -CPU=300HA
a38h mod06.src -CPU=300HA
a38h mod07.src -CPU=300HA
a38h mod08.src -CPU=300HA
a38h mod09.src -CPU=300HA
a38h mod10.src -CPU=300HA
a38h mod11.src -CPU=300HA
a38h mod12.src -CPU=300HA
a38h mod13.src -CPU=300HA
a38h mod14.src -CPU=300HA
a38h mod15.src -CPU=300HA
a38h mod16.src -CPU=300HA
a38h mod17.src -CPU=300HA
a38h mod18.src -CPU=300HA
a38h mod19.src -CPU=300HA
a38h mod20.src -CPU=300HA
a38h mod21.src -CPU=300HA
a38h mod22.src -CPU=300HA
a38h mod23.src -CPU=300HA
a38h mod24.src -CPU=300HA
a38h mod25.src -CPU=300HA
a38h mod26.src -CPU=300HA
a38h mod27.src -CPU=300HA
a38h mod28.src -CPU=300HA
a38h mod29.src -CPU=300HA
a38h mod30.src -CPU=300HA
a38h mod31.src -CPU=300HA
a38h mod32.src -CPU=300HA
a38h mod33.src -CPU=300HA
a38h mod34.src -CPU=300HA
a38h mod35.src -CPU=300HA
a38h mod36.src -CPU=300HA
a38h mod37.src -CPU=300HA
a38h mod38.src -CPU=300HA
a38h mod39.src -CPU=300HA
move *.obj ..\objs
move *.lis ..\objs
cd ..
REM -ADVSRC-
cd advsrc
a38h advanced.src -CPU=300HA
move *.obj ..\objs
move *.lis ..\objs
cd ..
REM -ADVTIP\3067-
cd advtip\3067
a38h cpu01.src -CPU=300HA
a38h cpu02.src -CPU=300HA
a38h cpu03.src -CPU=300HA
a38h cpu04.src -CPU=300HA
a38h cpu05.src -CPU=300HA
move *.obj ..\..\objs
move *.lis ..\..\objs
cd ..\..
COPY MONITOR.AKI OBJS\MONITOR.SUB
cd objs
L38H /SUB=MONITOR.SUB
C38H MONITOR
COPY MONITOR.MOT ..
cd ..
