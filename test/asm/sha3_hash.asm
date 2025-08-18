; Compute SHA3-256 hash of "Hello"
; Store "Hello" in memory and hash it
PUSH5 0x48656c6c6f  ; "Hello" in hex
PUSH1 0x00          ; Memory offset 0
MSTORE8             ; Store 'H' at offset 0
PUSH1 0x48
PUSH1 0x00
MSTORE8
PUSH1 0x65
PUSH1 0x01
MSTORE8
PUSH1 0x6c
PUSH1 0x02
MSTORE8
PUSH1 0x6c
PUSH1 0x03
MSTORE8
PUSH1 0x6f
PUSH1 0x04
MSTORE8
PUSH1 0x05          ; Length of data (5 bytes)
PUSH1 0x00          ; Offset in memory (0)
SHA3                ; Compute SHA3-256 hash
STOP