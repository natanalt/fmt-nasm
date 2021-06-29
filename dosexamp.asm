;;; DOS example for the fmt macro
;;;
;;; It's meant to be built as a standalone COM executable, like:
;;;  $ nasm -f bin dosexamp.asm -o dosexamp.com
;;;

cpu 8086

; Segment definitions (code goes first, then strings)

segment code vstart=0x100
segment strings vfollows=code

segment code

%define FMT_STRING_SEG strings
%include "fmt.asm"

main:
    
    print ""
    print "Nat's fmt print macro test"
    print "--------------------------"
    
    print "trans rights"
    mov ax, 'a'
    print "{ax:b}"
    print "{ax:u}"
    print "{ax:c}"
    print "cs={cs} ds={ds} es={es} ss={ss}"
    mov al, 'h'
    mov bl, 'i'
    print "{al:c}{bl:c}{bl:c}{bl:c}{bl:c}{bl:c}"
    print "2 * 2 + 2 = {b:u:2 * 2 + 2}"
    print "address of main: {cs}:{W:main}"
    print "size of main: {w:u:main.end - main} bytes"
    print "size of main: 0b{w:b:main.end - main} bytes"
    print "size of main: 0x{w:x:main.end - main} bytes"
    print "w:c test {w:c:'0' + 2}"
    
    print "--------------------------"
    print "Test finished."
    print "Hopefully nothing exploded."
    print "byeeeeeeeeeeeeee"
    print ""
    
    mov ax, 0x4C00
    int 0x21
    .end:


; ds:si - null terminated string
log_print_string:
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov dx, si
    
    cld
    xor cx, cx
    .lenloop:
        lodsb
        test al, al
        jz .finloop
        inc cx
        jmp .lenloop
    .finloop:

    mov bx, 1
    mov ah, 0x40
    int 0x21
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; al - value
log_print_byte_dec:
    push ax
    
    ; Just use the 16-bit implementation
    xor ah, ah
    call log_print_word_dec
    
    pop ax
    ret


; al - value
log_print_byte_hex:
    push bx
    
    mov bx, digits
    
    push ax
        shr al, 1
        shr al, 1
        shr al, 1
        shr al, 1
        xlatb
        call log_print_byte_chr
    pop ax
    
    push ax
        and al, 0xF
        xlatb
        call log_print_byte_chr
    pop ax
    
    pop bx
    ret


; al - value
log_print_byte_bin:
    push ax
    push cx
    
    mov cx, 16
    .loop:
        push ax
        push cx
        
        mov cl, 15
        shr ax, cl
        add al, '0'
        call log_print_byte_chr
        
        pop cx
        pop ax
        
        shl ax, 1
        loop .loop
    
    pop cx
    pop ax
    ret


; al - value
log_print_byte_chr:
    push ax
    push dx
    
    mov ah, 0x0E
    int 0x10
    
    ;mov dl, al
    ;mov ah, 0x05
    ;int 0x21
    
    pop dx
    pop ax
    ret
    .tmp db 0


; ax - value
log_print_word_dec:
    push ax
    push bx
    push dx
    push si
    
    std
    mov di, .tmp + 4
    
    .print_loop:
        mov bx, 10
        xor dx, dx
        div bx
        
        xchg dx, ax
        add al, '0'
        stosb
        mov ax, dx
        
        cmp ax, 0
        jne .print_loop
    
    cld
    mov si, di
    inc si
    call log_print_string
    
    pop si
    pop dx
    pop bx
    pop ax
    ret
    .tmp db "65535", 0


; ax - value
log_print_word_hex:
    push ax
    
    xchg ah, al
    call log_print_byte_hex
    mov al, ah
    call log_print_byte_hex
    
    pop ax
    ret


; ax - value
log_print_word_bin:
    push ax
    push cx
    
    mov cx, 16
    .loop:
        push ax
        push cx
        
        mov cl, 15
        shr ax, cl
        add al, '0'
        call log_print_byte_chr
        
        pop cx
        pop ax
        
        shl ax, 1
        loop .loop
    
    pop cx
    pop ax
    ret


; ax - character
; This implementation just assumes ASCII strings.
; If your target platform supports multibyte characters, support them here.
log_print_word_chr:
    jmp log_print_byte_chr


; This example implementation prints a CRLF newline between prints
log_print_finish:
    push ax
    
    mov al, 13
    call log_print_byte_chr
    mov al, 10
    call log_print_byte_chr
    
    pop ax
    ret


digits db "0123456789ABCDEF", 0
