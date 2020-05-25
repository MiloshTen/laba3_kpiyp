;Input mas (30 elements - maximum). Input diapason(d2 - d1 = 20 - maximum). Create BAR GRAPH.

.model tiny;
org 100h

.data

    prnt1 db 0ah, 0dh, "Enter array 30 elements :", 0ah, 0dh, "$"
    prnt2 db 0ah, 0dh, "Enter range of numbers:", 0ah, 0dh, "$"
    prnt3 db 0ah, 0dh, "Low limit: ", "$"
    prnt4 db 0ah, 0dh, "High limit: ", "$"
    
    error_print_1 db 0ah, 0dh, "Error(overflow)!", "$"
    error_print_2 db 0ah, 0dh, "Error(is not a num)!", "$"
    error_print_3 db 0ah, 0dh, "Error(Unknown space)!", "$"
    error_print_4 db 0ah, 0dh, "Error(Unknown diapason)!", "$" 
    
    just_print db 0ah, 0dh, "$"
    space_print db " ", "$"
    
    mas_digits dw 2 dup(?)
    mas_counts dw 21 dup(?)       
    mas dw 30 dup(?)
    flag_pm db 0
    const_10 dw 10
        
.code

start:
    
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    mov ah, 09h
    lea dx, prnt1
    int 21h
    
    call out_just_print
    
    xor si,si     
    xor di,di               
    xor dx,dx
    
input_num:       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;INPUT
    
    mov ah, 01h
    int 21h
    
    cmp al, 0dh  
    je click_enter
    
    cmp al, 20h
    je click_space
    
    cmp al, 30h
    je null_value
        
    cmp al, '-'
    jne not_minus
    
    mov bx, 0
    mov flag_pm, 1
    je input_num
        
not_minus:
    
    mov bx, 0
    cmp al, 30h 
    jl not_num
    cmp al, 39h
    jg not_num
    
    sub al, 30h
    mov cl, al
    mov ax, dx
    mul const_10
    xor ch, ch
    add ax, cx
    
    cmp flag_pm, 1
    je is_a_minus
    
    cmp ax, -32768
    ja overflow
    
    ;ja jb jg jl
    
    mov dx, ax
    jmp input_num

is_a_minus:
    
    cmp ax, 32768
    ja overflow
    mov dx, ax
    jmp input_num
    
overflow:
    
    mov ah, 09h
    lea dx, error_print_1
    int 21h
    
    mov ah, 4ch
    int 21h
    ret

click_enter:
    
    cmp flag_pm, 1
    je click_enter_minus  
    
    cmp bx, 20h
    je before_after  
    
    mov mas[si], dx
    add si, 2
    mov mas[si], '$'
    jmp after_inp
 
before_after:
    
    mov mas[si], '$'
    jmp after_inp    
   
click_enter_minus:
    
    neg dx
    mov mas[si], dx
    add si, 2
    mov mas[si], '$'
    jmp after_inp
    
click_space:
    
    mov bx, 20h
    cmp bp, 0
    jne null_more
    
    cmp dx, 0
    je input_num 
    
    cmp flag_pm, 1
    jne is_a_plus
    je minus_value

is_a_plus:
    
    mov mas[si], dx
    inc di
    xor dx, dx
    xor bp, bp
    
    cmp si, 58
    je after_inp
    
    add si, 2
    mov flag_pm, 0
    jmp input_num
            
not_num:  

    mov ah, 09h
    lea dx, error_print_2
    int 21h
    jmp _end 
   
after_inp:
               
    call out_just_print
    
    mov ah, 09h
    lea dx, prnt2
    int 21h
    
    mov ah, 09h
    lea dx, prnt3
    int 21h
    
    xor si, si
    xor di, di
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx 
    
    jmp input_limit_low
        
null_value:
    
    inc bp
    jmp not_minus
    
null_more:
    
    cmp flag_pm, 1 
    je minus_value
    jmp is_a_plus
  
minus_value:
    
    neg dx
    jmp is_a_plus    

input_limit_low:     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INPUT LIMIT
    
    mov ah, 01h
    int 21h 
    
    cmp al, 0dh
    je check_first_enter
    
    cmp al, 20h
    je er_3_out
    
    cmp al, '-'
    jne not_minus_2
    
    mov flag_pm, 1  
    
    jmp input_limit_low
   
check_first_enter:

    cmp bl, 0
    je _end
      
    cmp flag_pm, 1
    jne check_diaposon_num
    
    neg dx
    
    jmp check_diaposon_num
    
    mov ah, 09h
    lea dx, prnt4
    int 21h
         
not_minus_2:
    
    cmp al, 30h 
    jl not_num
    
    cmp al, 39h
    jg not_num
    
    inc bl
    sub al, 30h
    mov cl, al
    mov ax, dx
    mul const_10
    xor ch, ch
    add ax, cx
    
    cmp flag_pm, 1
    je is_a_minus_2
    
    cmp ax, 32767 
    ja overflow

    mov dx, ax
    jmp input_limit_low
                  
check_diaposon_num:         ;;;;;;;;;;;;;;;;;;CHECK LIMIT
                          
    mov mas_digits[si], dx
    add si, 2
    
    cmp si, 2
    jg two_limits
    
    mov ah, 09h
    lea dx, prnt4
    int 21h
    
    xor di, di
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov flag_pm, 0 

    jmp input_limit_low                                                                  

is_a_minus_2:
    
    cmp ax, 32768
    ja overflow
       
    mov dx, ax
    jmp input_limit_low
    
two_limits:
    
    xor si, si
    
    mov ax, mas_digits[si + 2]
    
    cmp mas_digits[si], ax
    jge er_4_out
    
    sub ax, mas_digits[si]
    
    cmp ax, 20
    jg er_4_out
    
    mov si, mas_digits[0]
    
    jmp output_diap

output_diap:
    
    call out_just_print
    call out_just_print   
    jmp start_to_out    
    
generate:                               ;;;;;;;;;;;;;;;;;OUTPUT LIMIT
    
    xor dx, dx
    div const_10
    add dx, 30h
    push dx
    inc cx
    
    cmp ax, 0
    je out_dig
    jmp generate
    
out_dig:   
    
    pop dx
    mov ah, 02h
    int 21h
    
    loop out_dig
    xor cx,cx
    
    call out_space_print
    inc si   
    cmp si, bx
    jg loop_1
    jmp start_to_out
     
start_to_out:
    
    xor cx, cx
    mov ax, si
    mov bx, mas_digits[2]
    
    cmp si, 0
    jl minus_out
    
    jmp generate 

minus_out:
    
    call out_minus_print
    mov ax, si
    neg ax 
    jmp generate
           
loop_1:                         ;;;;;;;;;;;;;;;;;;CREATE BAR GRAPH

    call out_just_print
    xor si, si
    xor di, di
    mov ax, mas_digits[0]
    jmp met_1
    
met_1:
    
    cmp mas[si], ax
    je met_2
    
    cmp mas[si], '$'
    je loop_2
    
    add si, 2
    jmp met_1
    
met_2:
    
    inc mas_counts[di]
    add si, 2
    jmp met_1

loop_2:
    
    xor si, si
    inc ax
    add di, 2
      
    cmp ax, mas_digits[2]
    jg finished
    
    jmp met_1

finished:
    
    mov mas_counts[di], '$'
    call out_just_print
    xor si, si
    xor di, di
    xor cx,cx
    jmp output_result
    
output_result:                           ;;;;;;;;;;;;;;;;;;OUTPUT BAR GRAPH
    
    mov ax, mas_counts[si]
    cmp ax, '$'
    jne gen_res
    jmp _end

gen_res:
        
    xor dx, dx
    div const_10
    add dx, 30h
    push dx
    inc cx
    
    cmp ax, 0
    je out_res
    jmp gen_res
    
out_res:

    pop dx
    mov ah, 02h
    int 21h
    
    loop out_res
    
    xor cx,cx
    add si, 2
    
    call out_space_print    
    jmp output_result          

er_3_out:                              ;;;;;;;;;;;;;;;PROCEDUS & ERRORS
    
    mov ah, 09h
    lea dx, error_print_3
    int 21h
    jmp _end
    
er_4_out:
    
    mov ah, 09h
    lea dx, error_print_4
    int 21h
    jmp _end
                    
out_just_print proc
    mov ah, 09h
    lea dx, just_print
    int 21h
ret

out_space_print proc
    mov ah, 09h
    lea dx, space_print
    int 21h
ret

out_minus_print proc
    mov ah, 02h
    mov dl, '-'
    int 21h
ret         
    
_end:
    
    mov ah, 4ch
    int 21h
        
end start
      