; Bit shifting for powers of 2
PUSH1 0x01          ; Start with 1
PUSH1 0x08          ; Shift left by 8 bits
SHL                 ; Result: 256 (0x100)
DUP1                ; Keep 256
PUSH1 0x04          ; Shift right by 4 bits  
SHR                 ; Result: 16 (0x10)
MUL                 ; 256 * 16 = 4096
STOP