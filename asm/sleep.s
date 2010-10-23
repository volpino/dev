.text
.data
.global main
main:
    movl    $162,%eax
    movl    $1000000000,%ebx
    int     $0x80
    movl    $1,%eax
    movl    $0,%ebx
    int     $0x80
