	@ TEMPOは楽譜の左上にあるテンポに変更すること
	@ MIN_LENは、楽譜内で最短の音の長さに合わせて設定すること
	@	四分音符: 1, 八分音符: 2, 十六分音符: 4, 三十二分音符: 8
	.equ	TEMPO,         170
	.equ	MIN_LEN,       2
	.equ	TIMER_HZ,      1000*1000*60 / TEMPO / MIN_LEN
