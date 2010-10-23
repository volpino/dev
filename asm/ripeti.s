.data
    string: .string "LOL\n"
    len_string = .-string
    #ripeti: .space 3
    #ripeti_len = .-ripeti
.text
    .global main

main:
    #/* read */
    #movl    $3,%eax
    #movl    $0,%ebx
    #movl    $ripeti,%ecx
    #movl    $ripeti_len,%edx
    #int     $0x80
    movl    $5,%edi

loop:
    #stampo N
    movl    $4,%eax
    movl    $1,%ebx
    movl    $string,%ecx
    movl    $len_string,%edx
    int     $0x80
    #incremento
    decl    %edi
    #confronto
    cmpl    $-1,%edi
    jne     loop
    #exit 0
    movl    $1,%eax
    movl    $0,%ebx
    int     $0x80
