# Decay
An NES Sound Engine by Ryan Sandor Richards

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

While your program does not have to follow this layout *exactly* it must reserve the page at address `$0300` for use by decay.

 
