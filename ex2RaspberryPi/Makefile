# マクロ定義
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
LDFLAGS = -m armelf -no-undefined
OC = arm-none-eabi-objcopy
OCFLAGS = -O binary
OBJS_MAIN = main.elf
OBJS_SUB = main.o display.o makeNum.o music.o sound.o makeNotes.o music_zense.o music_einekleine.o music_umiyuri.o music_karakuri.o music_rinsaku.o music_melissa.o result.o choose_zense.o choose_melissa.o choose_umiyuri.o choose_karakuri.o choose_einekleine.o choose_hungry.o select.o checkButton.o choose_rinsaku.o hungry_ghost.o
KERNEL7 = /media/boot/kernel7.img

# .sから.oを生成する型規則
%.o: %.s
	$(AS) $< -o $@
# .oから.elfを生成する型規則
%.elf: %.o
	$(LD) $(LDFLAGS) $< -o $@
# .elfから.imgを生成する型規則
%.img: %.elf
	$(OC) $< $(OCFLAGS) $@

# 擬似ターゲットであることを明示
.PHONY: clean all

all: main.img

main.elf: $(OBJS_SUB)
	$(LD) $(LDFLAGS) $+ -o $@

main.img: $(OBJS_MAIN)
	$(OC) $^ $(OCFLAGS) $@

cp_main: main.img
	cp $< $(KERNEL7)


# .oファイルやバックアップファイル等を削除
clean:
	rm -f *.o *~ a.out *.elf

