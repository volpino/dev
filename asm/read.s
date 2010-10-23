.data
    welcome:      .string "Pappagallo ASM\nby fox\n>>> "
    welcome_len = .-welcome
    string:       .space 128
    string_len =  .-string
    byte_letti:   .long 0

.text
    .global main
main:
    /* Stampa il welcome */
    movl    $4,%eax
    movl    $1,%ebx
    movl    $welcome,%ecx
    movl    $welcome_len,%edx
    int     $0x80
    /* prende in input la stringa */
    movl    $3,%eax
    movl    $0,%ebx
    movl    $string,%ecx
    movl    $string_len,%edx
    int     $0x80
    movl    %eax,byte_letti
    /* stampa la stringa */
    movl    $4,%eax
    movl    $1,%ebx
    movl    $string,%ecx
    movl    $string_len,%edx
    int     $0x80 
    /* exit 0 */
    movl    $1,%eax
    movl    $0,%ebx
    int     $0x80
