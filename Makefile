all: basic.hex

basic.hex: basic.bin
	srec_cat basic.bin -binary -offset=0x4000 -o basic.hex -intel -address-length=2
	perl -p -e 's/\n/\r\n/' < basic.hex > basic_crlf.hex

basic.bin: basic.o
	ld65 -t none -vm -m basic.map -o basic.bin basic.o

basic.o: basic.asm min_mon.asm
	ca65 -g -l min_mon.lst --feature labels_without_colons -o basic.o min_mon.asm

clean:
	$(RM) *.o *.lst *.map *.bin *.hex

distclean: clean
