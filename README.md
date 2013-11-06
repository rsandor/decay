# Decay NES Audio Engine
By Ryan Sandor Richards

### Expected Memory Layout

The decay sound engine assumes the following memory layout:

```
+---------------+-----------------------------------------+-----------+
| Address       | Purpose                                 | Size      |
+---------------+-----------------------------------------+-----------+
| $00 - $0F     | Sub routine arguments                   | 256 bytes |
| $10 - $FF     | Temporary sub routine variables         |           |
+---------------+-----------------------------------------+-----------+
| $0100 - $01FF | Stack                                   | 256 bytes |
+---------------+-----------------------------------------+-----------+
| $0200 - $02FF | OAM (Sprite) Memory                     | 256 bytes |
+---------------+-----------------------------------------+-----------+
| $0300 - $03FF | Decay sound engine state                | 256 bytes |
+---------------+-----------------------------------------+-----------+
| $0400 - $07FF | Program Specific Variables              | 1 KB      |
+---------------+-----------------------------------------+-----------+
```

While your program does not have to follow this layout *exactly* it must reserve at least one page (256 bytes) of RAM for use by decay. You can change the page offset in the `decay/header.s` file.





	lda #.LOBYTE(song_label)
	sta $00
	lda #.HIBYTE(song_label)
	sta $01
	jsr decay_load_song



	DecayLoadSong song_label
