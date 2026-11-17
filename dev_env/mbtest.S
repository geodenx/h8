;; sample program: mbtest.S
;; 	MBTEST.MAR を GCC (GAS) に移植
;; 
;;	Last modified: Feb 15, 2002
;;	OKAZAKI Atsuya (atsuya@mac.com)
;
;	サンプルソフト MBTEST.MOT
;	１６文字＊２行ＬＣＤの接続
;	データ＝ポート3
;	Ｅ　　＝ポート3のビット５
;	ＲＳ　＝ポート3のビット４
;
;■液晶表示の使い方
;１，ソフトウエアリセット
;	ファンクションセット１
;	ファンクションセット２
;	ファンクションセット３
;	ファンクションセット
;２，初期設定
;	ファンクションセット
;	表示ｏｎ
;	エントリーモード
;３、上記終了後
;1文字のデータ表示または、コマンド
;	ＲＡＭ H'FEF10(@LCD_D)にデータをセット後
;	データの場合はRSを1にセット、
;	コマンドの場合はRSを0にセットし
;	LCD_OUTをサブルーチンコールする。
;１６文字２行表示
;	ＲＡＭ H'FEF11(@LCD162)から３２文字文のデータをセット後
;	LCDDSPをサブルーチンコールする。
;
;	接続
;	Ｈ８マイコン	ＬＣＤ
;	Ｐ３ー０	Ｄ４
;	Ｐ３ー１	Ｄ５
;	Ｐ３ー２	Ｄ６
;	Ｐ３ー３	Ｄ７
;	Ｐ３−５	Ｅ
;	Ｐ３−４	ＲＳ
;	ＧＮＤ		Ｒ／Ｗ
#define	E_SIG	#5,@P3_D:8
#define	RS	#4,@P3_D:8
#define	LED1	#0,@P5DR:8
#define	LED2	#1,@P5DR:8
	
;-----ＣＰＵの指定-----	
;  	.CPU 300HA
	.h8300h
;-----シンボル-----
	.text
SW_D	=	0xFFEF10	;ＳＷ1-4の状態を入れるＲＡＭ
SW_D5	=	0xFFEF11	;ＳＷ5の状態を入れるＲＡＭ
LCD_D	=	0xFFEF12	;ＬＣＤへのデータを入れるＲＡＭ
				;（1バイト分）
LCD162	=	0xFFEF13	;16文字２行分のデータをいれるＲＡＭ

P2DR	=	0xFFFFC3	;ポート2データレジスタ 8P-DIP(S5)

P3_D	=	0xFFFFC6	;ポート3データレジスタ
				;ＬＣＤのデータ線
;E_SIG	.BEQU	5,P3_D		;イネーブル信号
;RS	.BEQU	4,P3_D		;ＲＳ信号

P4DR	=	0xFFFFC7	;ポート４データレジスタ

P5DR	=	0xFFFFCA	;ポート5データレジスタ
;LED1 	.BEQU	0,P5DR		;LED1
;LED2	.BEQU	1,P5DR		;LED2
	
;-----リセットベクトル-----
;  	.SECTION RESET0,DATA,LOCATE=0x00000
;  	.DATA.L	INIT		;リセットベクトル
;-----Ｉ／Ｏの初期設定-----	
;  	.SECTION ROM,CODE,LOCATE=0x00100
	.global _start
_start:	
INIT:
	mov.l	#0xfff10,er7;FFF10,ER7	;スタックポインタ設定
	MOV.B	#0x00,r0l	;ポート2を入力に設定(S5)
	MOV.B	r0l,@0xFFFFC1	;ポート2
	MOV.B	#0xFF,r0l	;ポート2をプルアップに設定
	MOV.B	r0l,@0xFFFFD8	;ポート2

	MOV.B	#0xFF,r0l	;ポート3を出力に設定
	MOV.B	r0l,@0xFFFFC4	;ポート3

	MOV.B	#0x00,r0l	;ポート4を入力に設定
	MOV.B	r0l,@0xFFFFC5	;ポート4
	MOV.B	#0xFF,r0l	;ポート4をプルアップに設定
	MOV.B	r0l,@0xFFFFDA	;ポート4

	MOV.B	#0xFF,r0l	;ポート5を出力に設定
	MOV.B	r0l,@0xFFFFC8	;ポート5
;-----ＬＣＤの初期設定-----
;ｰｰｰｰｰソフトウエアリセット-----
	JSR	@TIME00		;15mSのＷＡＩＴ	(4mS*4)
	JSR	@TIME00
	JSR	@TIME00
	JSR	@TIME00		

	MOV.B	#0b00100011,r0l	;ＬＣＤファンクションセット1
	MOV.B	r0l,@LCD_D
	BCLR	RS	; RS
	JSR	@LCD_OUT8

	JSR	@TIME00		;4mSのＷＡＩＴ

	MOV.B	#0b00100011,r0l	;ＬＣＤファンクションセット2
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT8
	JSR	@TIME00		;4mSのＷＡＩＴ

	MOV.B	#0b00100011,r0l	;ＬＣＤファンクションセット3
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT8
	JSR	@TIME00		;4mSのＷＡＩＴ

	MOV.B	#0b00100010,r0l	;ファンクションセット
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT8
	JSR	@TIME00		;4mSのＷＡＩＴ
;-----初期設定----
	MOV.B	#0b00101000,r0l	;ファンクションセット
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT4
	JSR	@TIME00		;4mSのＷＡＩＴ
	
	MOV.B	#0b00001110,r0l	;表示ＯＮ
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT4
	JSR	@TIME00		;4mSのＷＡＩＴ

	MOV.B	#0b00000110,r0l	;エントリーモード
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT4
	JSR	@TIME00		;4mSのＷＡＩＴ
;-----初期設定終了----
;-----液晶初期画面表示-----
	MOV.B	#0b00000001,r0l	;表示クリア
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT4

	JSR	@TIME00		;4mSのＷＡＩＴ

	MOV.B	#32,r0l
	MOV.L	#LCD162,er1	;液晶表示ＲＡＭのアドレスをセット
	MOV.L	#MOJI,er2	;初期文字データのアドレスをセット
SYOKI0:	MOV.B	@er2+,r0h	;初期文字データをレジスタにいれる。
	MOV.B	r0h,@er1	;レジスタ値を液晶表示ＲＡＭにいれる
	INC.L	#1,er1
	DEC.B	r0l		;文字数から１を引く
	BNE	SYOKI0		;文字数が０になるまでくりかえす。
	JSR	@LCDDSP
;-----ＭＡＩＮ-----
	MOV.B	#0,r0l		;ＲＡＭのクリア
	MOV.B	r0l,@SW_D
	MOV.B	r0l,@SW_D5
BOTAN:	MOV.B	@P4DR,r0l	;SW1-4の状態の取得
	MOV.B	@SW_D,r0h	;ＲＡＭの内容をレジスタに読む
	CMP.B	r0h,r0l		;ＳＷの状態をチェック
	BEQ	S5CHK		;変化が無ければS5CHKにジャンプ
	JSR	@S1_4		;変化が有るので処理ルーチンへ
S5CHK:	MOV.B	@P2DR,r0l	;S5の状態を取得
	MOV.B	@SW_D5,r0h	;ＲＡＭの内容をレジスタに読む
	CMP.B	r0h,r0l		;ＳＷの状態をチェック
	BEQ	BOTAN		;変化が無ければBOTANにジャンプ
	JSR	@S5		;変化が有るので処理ルーチンへ
	JMP	@BOTAN
;-----ＭＡＩＮＥＮＤ-----
;-----サブルーチン-----
;----液晶文字出力１６文字＊２行
LCDDSP:	PUSH.L	er0
	PUSH.L	er1
	MOV.B	#0b00000010,r0l	;カーソルホーム
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT4
	JSR	@TIME00		;4mSのＷＡＩＴ

;--1行目
	MOV.B	#16,r0l		;文字数のセット
	MOV.L	#LCD162,er1	;液晶表示ＲＡＭのアドレスをセット
LCDDSP1:	MOV.B	@er1+,r0h	;文字データをレジスタにいれる。
	MOV.B	r0h,@LCD_D	;文字データをRAMにいれる。
	BSET	RS		;データなのでRSを１にする。
	JSR	@LCD_OUT4	;サブルーチンコール
	BCLR	RS		;RSを０にもどす。
	DEC.B	r0l		;文字数から１を引く
	BNE	LCDDSP1		;文字数が０になるまでくりかえす。

	MOV.B	#0b11000000,r0l	;カーソルを２行目にする。
	MOV.B	r0l,@LCD_D
	BCLR	RS
	JSR	@LCD_OUT4
;--2行目
	MOV.B	#16,r0l		;文字数のセット
	MOV.L	#LCD162 + 16,er1	;液晶表示ＲＡＭのアドレスをセット
LCDDSP2:	MOV.B	@er1+,r0h	;文字データをレジスタにいれる。
	MOV.B	r0h,@LCD_D	;文字データをRAMにいれる。
	BSET	RS		;データなのでRSを１にする。
	JSR	@LCD_OUT4	;サブルーチンコール
	BCLR	RS		;RSを０にもどす。
	DEC.B	r0l		;文字数から１を引く
	BNE	LCDDSP2		;文字数が０になるまでくりかえす。

	POP.L	er1
	POP.L	er0
	RTS
;-----LCDへのデータ、コマンド出力-----
LCD_OUT8:	PUSH.L	er0	;レジスタ待避
	BSET	E_SIG		;液晶のＥ信号をセットする。
	MOV.B	@LCD_D,r0l	;データ(コマンド）をレジスタに入れる
	MOV.B	r0l,@P3_D	;液晶にデータ(コマンド）を出力
	JSR	@TIME10		;ＷＡＩＴ
	BCLR	E_SIG	;液晶のＥ信号を０にする。
	JSR	@TIME10		;ＷＡＩＴ
	POP.L	er0		;レジスタの復帰
	RTS
;-----LCDへのデータ、コマンド出力 4bit -----
LCD_OUT4:	PUSH.L	er0	;レジスタ待避
;--上位４ビット送出
	BSET	E_SIG		;液晶のＥ信号を１にする。
	MOV.B	@LCD_D,r0l	;データ(コマンド）をレジスタに入れる
	SHLR.B	r0l		;4ビットモードなので上位４ビットを
	SHLR.B	r0l		;下位に移動
	SHLR.B	r0l
	SHLR.B	r0l
	AND.B	#0b00001111,r0l	;データ線以外をマスクする。
	MOV.B	@P3_D,r0h	;ＲＳ信号の待避
	AND.B	#0b11110000,r0h	;ＲＳ信号、Ｅ信号以外をマスク
	OR.B	r0h,r0l		;ＲＳ信号，Ｅ信号、データ（４ビット）
				;を合成する。
	MOV.B	r0l,@P3_D	;合成したすべての信号を液晶に出力
	JSR	@TIME10		;ＷＡＩＴ
	BCLR	E_SIG		;液晶のＥ信号を０にする
	JSR	@TIME10		;ＷＡＩＴ
;--上位４ビット送出
	BSET	E_SIG		;液晶のＥ信号を１にする
	MOV.B	@LCD_D,r0l	;データ(コマンド）をレジスタに入れる
	AND.B	#0b00001111,r0l	;データ線下位4ビット以外をマスクする
	MOV.B	@P3_D,r0h	;ＲＳ信号の待避
	AND.B	#0b11110000,r0h	;ＲＳ信号、Ｅ信号以外をマスク
	OR.B	r0h,r0l		;ＲＳ信号，Ｅ信号、データ（４ビット）
				;を合成する
	MOV.B	r0l,@P3_D	;合成したすべての信号を液晶に出力
	JSR	@TIME10		;ＷＡＩＴ
	BCLR	E_SIG		;液晶のＥ信号を０にする
	JSR	@TIME10		;ＷＡＩＴ
	POP.L	er0		;レジスタの復帰
	RTS
;-----液晶表示S1-4-----
S1_4:	MOV.B	r0l,@SW_D 	;現在の状態をＲＡＭに格納
	MOV.B	#4,r1l		;文字数のセット
	MOV.L	#LCD162 + 20,er2	;液晶表示アドレスをセット
	MOV.B	@SW_D,r0l	;スイッチの状態をレジスタに読む
BOTAN1:	ROTL.B	r0l
	MOV.B	r0l,r0h
	AND.B	#0b00000001,r0h	;SWの状態をｱｽｷｰｺｰﾄﾞに変換
	OR.B	#0b00110000,r0h
	MOV.B	r0h,@-er2	;ｱｽｷｰｺｰﾄﾞを液晶表示ＲＡＭに格納
	DEC.B	r1l		;文字数から１を引く
	BNE	BOTAN1		;文字数が０になるまでくりかえす。
	JSR	@LCDDSP
;---LED
SW3LED:	MOV.B	@SW_D,r0l	;在の状態をＲＡＭに格納
	BTST	#6,r0l		;Ｓ3の状態をチェック
	BEQ	BOTAN2		;押されていればBOTAN2にジャンプ
	BCLR	LED1		;押されていないので消灯
	JMP	@SW4LED
BOTAN2:	BSET	LED1		;押されているので点灯
SW4LED:	BTST	#7,r0l		;Ｓ4の状態をチェック
	BEQ	BOTAN3		;押されていればBOTAN3にジャンプ
	BCLR	LED2		;押されていないので消灯
	RTS
BOTAN3:	BSET	LED2		;押されているので点灯
	RTS
;-----液晶表示S5-----	
S5:	MOV.B	r0l,@SW_D5 	;現在の状態をＲＡＭに格納
	MOV.B	#8,r1l		;文字数のセット
	MOV.L	#LCD162 + 29,er2	;液晶表示アドレスを読む
	MOV.B	@SW_D5,r0l	;ＲＡＭの内容をレジスタに読む
BOTAN4:	ROTL.B	r0l
	MOV.B	r0l,r0h
	AND.B	#0b00000001,r0h	;SWの状態をｱｽｷｰｺｰﾄﾞに変換
	OR.B	#0b00110000,r0h
	MOV.B	r0h,@-er2	;ｱｽｷｰｺｰﾄﾞを液晶表示ＲＡＭに格納
	DEC.B	r1l		;文字数から１を引く
	BNE	BOTAN4		;文字数が０になるまでくりかえす。
	JSR	@LCDDSP		;
	RTS
;-----4mSﾀｲﾏ-----
TIME00:	PUSH.L	er0
	MOV.L	#0x2000,er0
TIME01:	SUB.L	#1,er0
	BNE	TIME01
	POP.L	er0
	RTS

TIME10:	PUSH.L	er0
	MOV.L	#0xAA,er0	;450nS	TIMER
TIME11:	SUB.L	#1,er0
	BNE	TIME11
	POP.L	er0
	RTS
;-----サブルーチン終了-----	
;-----文字データ-----
	.ALIGN 2
;  	.SECTION LCDDATA,DATA,LOCATE=0x01000
;  MOJI:	.SDATA "AKI-H8 "
;  	.DATA.B	0x0CF,0x0BB,0x0DE,0x0B0,0x0CE
;  	.DATA.B	0x0DE,0x0B0,0x0C4,0x0DE
;  	.SDATA "1111 11111111   "
;  	.END	
MOJI:	.ascii	"AKI-H8 "
	.byte	0x0CF,0x0BB,0x0DE,0x0B0,0x0CE
  	.byte	0x0DE,0x0B0,0x0C4,0x0DE
	.ascii "1111 11111111   "
	.end
	