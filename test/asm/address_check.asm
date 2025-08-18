; Get contract address and check if it's non-zero
ADDRESS             ; Get current contract address
DUP1                ; Duplicate for comparison
ISZERO              ; Check if address is zero
NOT                 ; Invert (1 if address is non-zero)
STOP