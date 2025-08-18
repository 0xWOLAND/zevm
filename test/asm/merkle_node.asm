; Compute merkle tree node from two hashes
; Hash1 at memory[0:32], Hash2 at memory[32:64]
PUSH32 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
PUSH1 0x00
MSTORE              ; Store first hash
PUSH32 0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321
PUSH1 0x20
MSTORE              ; Store second hash
PUSH1 0x40          ; 64 bytes (both hashes)
PUSH1 0x00          ; Starting at offset 0
SHA3                ; Compute parent hash
STOP