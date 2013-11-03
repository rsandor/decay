build: 
	ld65 obj/$< -o nes/$@ -t nes
	fceux nes/$@

# Build object files from assembly source
%.o: %.s
	ca65 $< -o $@ -t nes

