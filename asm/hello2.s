// hello.S
// In AT&T Assembly possiamo tranquillamente usare i commenti stile C/C++
.data
.text
.global main
hello:
        .string        "Hello world!\n"
lol:
        .string        "I did it for the lulz :3\n"
len_lol = .-lol
main:
        movl           $4,%eax
        movl           $1,%ebx
        movl           $hello,%ecx
        movl           $13,%edx
        int            $0x80
        movl           $4,%eax
        movl           $1,%ebx
        movl           $lol,%ecx
        movl           $len_lol,%edx
        int            $0x80
        movl           $1,%eax
        movl           $0,%ebx
        int            $0x80

