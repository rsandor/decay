run: demo.nes
	fceux demo.nes

%.nes: %.o
	ld65 $< -o $@ -t nes

%.o: %.s
	ca65 $< -o $@ -t nes

