; Modular addition used in elliptic curves
; (a + b) mod p where p is a prime
PUSH32 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f  ; secp256k1 field prime
PUSH32 0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798  ; Point x
PUSH32 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8  ; Point y
ADDMOD              ; (x + y) mod p
STOP