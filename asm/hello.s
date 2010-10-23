.data
.text
.global main
hello:
        .string        "Hello world!\n"
main:
        movl           $4,%eax
        movl           $1,%ebx
        movl           $hello,%ecx
        movl           $13,%edx
        int            $0x80
        movl           $162,%eax
        movl           $0,%ebx
        movl           $1000000000,%ecx
        int            $0x80
        movl           $1,%eax
        movl           $0,%ebx
        int            $0x80

