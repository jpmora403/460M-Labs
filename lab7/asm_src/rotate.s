        andi $1, $1, 0
        ori $1, $1, 1      ; init $1 to 1
        andi $2, $2, 0
        ori $2, $2, 0x80   ;init $2 to 0x80
        andi $3, $3, 0
        ori $3, $3, 0x81 

loop:   sll $1, $1, 1
        bne $1, $2, loop    ;loop = -2

       ; andi $1, $1, 0
       ; ori $1, $1, 1 ;reset $1
        xor $1, $1, $3 
        j 4


