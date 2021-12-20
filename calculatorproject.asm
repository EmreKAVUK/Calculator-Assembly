.model small    
.stack 32
.data
header db "Emre's calculator"
firstnum db '1.Number : '
secondnum db '2.Number : '
firstval db 4 dup(?)
secondval db 4 dup(?)
firstvalue db 0     
secondvalue db 0 
result dw 0 
resultmessage db 'Result :'
dimensionx db ? ;Use calculate sonuc's length(string)
again db 'Do you want to continue?(y/n)' 
dimensionz db ?
bye db 'Bye Bye'
dimensionw db ?
sign db ?
signmessage db 'enter the symbol of the operation (+,-,/,*)' 
dimensionp db ?
.code

mov ax,data;
mov ds,ax;
mov es,ax;

;Create screen
mov ah,0;set video mode
mov al,0;desired video mode 40x25. 16 colors. 8 pages.
int 10h;

write macro colorcode,dimension,row,column,adres
    mov al,1;write mode
    mov bh,0;page number
    mov bl,colorcode;
    mov cx,dimension;length of string
    mov dh,row;
    mov dl,column;
    mov bp,offset adres;
    mov ah,13h;write string
    int 10h;
    
    
write endm
 
continue:
call clear_screen;
call clear_variable;


write 11101100b,firstnum-header,0,10,header;  
write 00000010b,secondnum-firstnum,6,0,firstnum; 

mov cx,0;
lea si,firstval;
lea di,firstval; Learn number of digits 

get_first:
    cmp cx,3; number of digits
    jz get_second;
    call get_data;
    jmp get_first;
    
get_second:
write 00000010,secondnum-firstnum,8,0,secondnum;
                                                                                                 
mov cx,0;
lea si,secondval;
lea di,secondval; 

get_secondd:
    cmp cx,3; number of digits
    jz calculate;
    call get_data;
    jmp get_secondd;

calculate:
lea si,firstval;
lea di,firstvalue;
call convertnum;   

lea si,secondval;
lea di,secondvalue;
call convertnum;

write 00000010b,dimensionp-signmessage,9,0,signmessage;
mov ah,0;  take data from user
int 16h; 
cmp al,43
jz sum;
cmp al,42;
jz mult; 
cmp al,45;
jz subs;
cmp al,47;
jz divs;

sum:
;SUM 
mov ax,0000h;
mov al,[firstvalue];
add result,ax;
mov ax,0000h; 
mov al,[secondvalue];
add result,ax;
jmp pass1;

;MULTIPLE
mult:
mov ax,0000h;
mov al,[firstvalue];
add result,ax;
mov ax,0000h; 
mov al,[secondvalue];

mul result;
mov result,ax;
jmp pass1;

;Subtract
subs:
mov ax,0000h;
mov al,[firstvalue];
add result,ax;
mov ax,0000h; 
mov al,[secondvalue];
sub result,ax;
jmp pass1;

;Division
divs:  
mov dx,0000;
mov ax,0000h;
mov al,[secondvalue];
add result,ax;
mov ax,0000h; 
mov al,[firstvalue];


div result;
mov result,ax;
jmp pass1;

pass1:


write 00000010b,dimensionx-resultmessage,10,0,resultmessage;
mov ax,[result];123 100 ah:23 al:1 23 10 ah:3 al:2
cmp ax,10;
jb one_digit;
cmp ax,100;
jb two_digit;
jmp three_digit;last choice three digit


one_digit:
mov ax,[result];
add ax,48;
mov ah,0eh;
int 10h;
jmp finish; 

two_digit:
mov ax,[result];For ex 23 /10 al:2 ah:3 we print first al
mov bl,10;
div bl; div use ax register 
mov bl,ah;Save ah's value because we use ah print string under
add al,48;
mov ah,0eh;print al
int 10h;
mov al,bl;
add al,48;
mov ah,0eh;
int 10h;
jmp finish;

three_digit:
mov ax,[result];
mov bl,100;
div bl;
mov bl,ah;
add al,48;
mov ah,0eh;
int 10h;
mov ax,0000h;
mov al,bl;
mov bl,10;
div bl
mov bl,ah;
add al,48;
mov ah,0eh;
int 10h;
mov al,bl;
add al,48; 
mov ah,0eh;
int 10h;



finish: 
write 00000010b,dimensionz-again,14,7,again;
mov ah,0;
int 16h;
cmp al,121;
jz continue;
call clear_screen;
write 00000010b,dimensionw-bye,10,15,bye;
 


                                              
mov ah,4ch; stop program
int 21h;

get_data proc
    mov ah,0;  take data from user
    int 16h; 
    cmp al,0dh;Enter's value is 0dh in ascii code
    jz isfull;jz: If Zero flag is 0,it's work 
    jmp numbercontrol
    
    isfull:
    cmp cx,0; if cx = 0 zero it's empty if press number cx+1
    jz empty;
    mov cx,3;
    
    empty:
    ret;Return to calling location
    
    numbercontrol:
    ;Check is it number or character(string,symbol etc...)
    cmp al,47; ascii 47 => 0
    ja big;
    ret;
    
    big:
    cmp al,58; ascii 58 => 9
    jb small;
    ret;
    small:
    mov ah,0eh;Write Character
    int 10h;  
    
    mov [si],al;   put number
    inc si;  
    
    
    inc cx 
    mov [di+3],cl; Keep number of digits 4.value
    ret;
get_data endp 

convertnum proc
    cmp [si+3],3;I write firstval's 4. value is digit num if digit num =3
    jz threedigit;
    
    cmp [si+3],2
    jz twodigit; 
    
    cmp [si+3],1;
    jz onedigit;
    
    
    threedigit:
    mov al,[si];
    sub al,48; 48 = 30h like transform decimal;
    mov bl,100;
    mul bl; a *bl
    add [di],al; 
    mov al,[si+1];
    sub al,48; 48 = 30h;
    mov bl,10;
    mul bl; a *bl
    add [di],al;
    mov al,[si+2];
    sub al,48; 48 = 30h;
    add [di],al; 
    ret;need to exit
    
    twodigit:
    mov al,[si];incoming number from user
    sub al,48; 48 = 30h;
    mov bl,10;
    mul bl; a *bl
    add [di],al;
    mov al,[si+1];
    sub al,48; 48 = 30h;
    add [di],al;
    ret
    
    onedigit:
    mov al,[si];
    sub al,48; 48 = 30h;
    add [di],al;  
    
ret   
    
convertnum endp   

clear_screen proc
    mov ah,7;clear screen command
    mov al,0;
    mov bh,00000010;set background
    mov ch,0;left top
    mov cl,0;
    mov dh,25;
    mov dl,40;
    int 10h;
    ret;
clear_screen endp  

clear_variable proc
    mov cx,4;
    lea si,firstval;
    lea di,secondval;
    dongu:
    mov [si],0;
    mov [di],0;
    inc di;
    inc si;
    loop dongu; 
    
    mov [firstvalue],0;
    mov [secondvalue],0;
    mov [result],0;
    mov ax,0;
    mov bx,0;
    mov cx,0;
    mov dx,0;
    mov si,0;
    mov di,0;
    ret
clear_variable endp

end;