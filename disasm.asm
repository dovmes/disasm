.MODEL small
buferioDydis equ 15
.STACK 100h
.DATA
pagalba db 'Dovydas Meskuotis, PS 1 kursas, 2 grupe. 2022',10,'Disasembleris, naudojimas: disasm in.com out.asm',10,'$'
neatpazinta db 'NEATPAZINTA'
darSkaityti db 0
failasIN db  50 dup(0)
handleIN dw 0
failasOUT db 50 dup(0)
handleOUT dw 0
buferis db buferioDydis dup(0)
buferisOUT db buferioDydis dup(0)

tipas db 8,8,8,8,6,6,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,10,0,8,8,8,8,6,6,10,0,0,0,0,0,0,0,10,0,8,8,8,8,6,6,10,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,9,9,0,0,0,0,8,8,8,8,8,0,8,8,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0,0,3,1,0,0,12,12,0,0,3,1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,0,0,0,0,3,3,7,2,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,5,5
segmentoRegistrai db 'escsssds'
registraiZodiniai db 'axcxdxbxspbpsidi'
registraiBaito db 'alcldlblahchdhbh'
segmentoReg db 0


w db 0
m0d db 0 
rm db 0
reg db 0
d db 0
komandosIlgis db 0

reikiaSegmentoRegistro db 0
segmentas db 0,0
poslinkis dw 100h

naujaEilute db 10
tarpas db ' '
skliaustai db '[]'
dvitaskis db ':'
pliusas db '+'
kablelis db ','
adresui db 'bx+sibx+dibp+sibp+disidibx'
adresuiPoslinkiai db 0,5,10,15,20,22,24,24
ilgiai db 5,5,5,5,2,2,2,2
kiekSpausdinti db 4
reikiaSkliaustu db 0
lygus1 db 0

jumpai db "jo  jno jb  jnb je  jne jbe ja  js  jns jp  jnp jl  jge jle jg  "
jumpIlgiai db 3,4,3,4,3,4,4,3,3,4,3,4,3,4,4,3
jumpJCXZ db "jcxz "

byteptr db 'byte ptr '
wordptr db 'word ptr '
dwordptr db 'dword ptr '
reikiadWord db 0

komandaPUSH db 'push '
komandaPOP db 'pop '
komandaINC db 'inc '
komandaDEC db 'dec '
komandaRET db 'ret '
komandaRETF db 'retf '
komandaINT db 'int '
komandaLOOP db 'loop '
komandaMUL db 'mul '
komandaDIV db 'div '
komandaJMP db 'jmp '
komandaCALL db 'call ' 
komandaSUB db 'sub '
komandaADD db 'add '
komandaCMP db 'cmp '
komandaMOV db 'mov '

.CODE
start:
  mov ax, @data
  mov ds, ax

  mov cx, 0
  mov cl, es:[80h]
  dec cl
  mov si, 0
  mov di, 0

failuiIN:
  cmp si, cx
  je atidaryti
  mov dl, es:[82h+si]
  inc si
  cmp dl, ' '
  je failuiOUT
  mov [failasIN+si-1], dl
  jmp failuiIN
failuiOUT:
  cmp si, cx
  je atidaryti
  mov dl, es:[82h+si]
  mov [failasOUT+di], dl
  inc si
  inc di
  jmp failuiOUT
atidaryti:

  lea dx, failasIN
  mov ax, 3d00h
  int 21h
  jnc persokti1
  call spausdintiPagalba
persokti1:
  mov handleIN, ax

  lea dx, failasOUT
  mov ax, 3c00h
  mov cx, 0
  int 21h
  jnc persokti2
  call spausdintiPagalba
persokti2:
  mov handleOUT, ax

  mov cx, 0
  mov si, 0
  mov di, 0

skaityti:

  cmp darSkaityti, 0
  jne persokti3
  cmp cx, 6
  ja persokti3
  call nuskaityti
  mov si, 0
persokti3:
  cmp cx, 0
  jg persokti4
  call pabaiga
persokti4:
  call apdorotiadresacijosBaita
  mov bx, 0
  mov bl, [buferis+si]

  push cx
  cmp reikiaSegmentoRegistro, 1
  je neraSegmento

  mov dx, [poslinkis]
  mov kiekSpausdinti, 4
  call spausdintiRegistra

  call detiTarpa
  ;001sr 110 – segmento registro keitimo prefiksas 
  cmp byte ptr[tipas+bx], 10
  jne neraSegmento
  and bl, 00011000b
  shr bl, 3
  add bl,bl
  mov reikiaSegmentoRegistro, 1
  mov dl, [segmentoRegistrai+bx]
  mov [segmentas], dl
  mov dl, [segmentoRegistrai+bx+1]
  mov [segmentas+1], dl
  mov cx, 1
  call spausdintiKomanda
  pop cx
  mov komandosIlgis, 1
  call atnaujinti
  jmp skaityti
  neraSegmento:

  cmp byte ptr[tipas+bx], 0  
  jne praleisti1
nera:
  mov cx, 1
  call spausdintiKomanda
  call detiTarpa
  lea dx, neatpazinta
  mov cx, 11
  call detiIBuferi
  call nauja
  pop cx
  mov komandosIlgis, 1
  call atnaujinti
  jmp skaityti
praleisti1:
  cmp byte ptr[tipas+bx], 1
  jne praleisti2
  mov cx, 1
  call spausdintiKomanda
  call detiTarpa
  call apdoroti1
  call nauja
  pop cx
  mov komandosIlgis, 1
  call atnaujinti
  jmp skaityti
praleisti2:
  cmp byte ptr[tipas+bx], 2
  jne praleisti3
  mov cx, 2
  call spausdintiKomanda
  call detiTarpa
  call apdoroti2
  call nauja
  pop cx
  mov komandosIlgis, 2
  call atnaujinti
  jmp skaityti
praleisti3:
  cmp byte ptr[tipas+bx], 3
  jne praleisti4
  mov cx, 3
  call spausdintiKomanda
  call detiTarpa
  call apdoroti3
  call nauja
  pop cx
  mov komandosIlgis, 3
  call atnaujinti
  jmp skaityti
praleisti4:
  cmp byte ptr[tipas+bx], 4
  jne praleisti5
  cmp reg, 100b
  je praleisti4_
  cmp reg, 110b
  je praleisti4_
  jmp nera
praleisti4_:
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call detiTarpa
  call apdoroti4
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti5:
  cmp byte ptr[tipas+bx], 5
  jne praleisti6
  cmp reg, 111b
  jne praleisti5_
  jmp nera
praleisti5_:
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call apdoroti5
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti6:
  cmp byte ptr[tipas+bx], 6
  jne praleisti7
  mov komandosIlgis, 2
  mov bl, w
  add komandosIlgis, bl
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call detiTarpa
  call apdoroti6
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti7:
  cmp byte ptr[tipas+bx], 7
  jne praleisti8
  mov cx, 5
  call spausdintiKomanda
  call detiTarpa
  call apdoroti7
  call nauja
  pop cx
  mov komandosIlgis, 5
  call atnaujinti
  jmp skaityti
praleisti8:
  cmp byte ptr[tipas+bx], 8
  jne praleisti9
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call detiTarpa
  call apdoroti8
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti9:
  cmp byte ptr[tipas+bx], 9
  jne praleisti10
  cmp reg, 111b
  je praleisti9_
  cmp reg, 101b
  je praleisti9_
  cmp reg, 000b
  je praleisti9_
  jmp nera
praleisti9_:
  call gautiS
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call detiTarpa
  call apdoroti9
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti10:
  cmp byte ptr[tipas+bx], 11
  jne praleisti11
  mov bl, [buferis+si]
  and bl, 00001000b
  shr bl, 3
  mov w, bl
  mov komandosIlgis, 2
  add komandosIlgis, bl
  mov bl, [buferis+si]
  and bl, 00000111b
  mov reg, bl
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call detiTarpa
  call apdoroti6
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti11:
  cmp byte ptr[tipas+bx], 12
  jne praleisti12
  cmp reg, 000b
  je praleisti11_
  jmp nera
praleisti11_:
  inc komandosIlgis
  mov bl, w
  add komandosIlgis, bl
  mov cx, 0
  mov cl, komandosIlgis
  call spausdintiKomanda
  call detiTarpa
  call apdoroti12
  call nauja
  pop cx
  call atnaujinti
  jmp skaityti
praleisti12:
  call pabaiga
apdoroti1 proc
  mov w, 1
  ;000sr 110 – PUSH segmento registras
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11100111b
  cmp bl, 00000110b
  jne praleistiapdoroti1
  lea dx, komandaPush
  mov cx, 5
  call detiIBuferi
  mov bl, [buferis+si]
  shr bx, 3
  call spausdintiRegistra2
  ret
  praleistiapdoroti1:
  ;000sr 111 – POP segmento registras
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11100111b
  cmp bl, 00000111b
  jne praleistiapdoroti11
  lea dx, komandaPop
  mov cx, 4
  call detiIBuferi
  mov bl, [buferis+si]
  shr bx, 3
  call spausdintiRegistra2
  ret
  praleistiapdoroti11:
  ;0100 0reg – INC registras (žodinis)
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111000b
  cmp bl, 01000000b
  jne praleistiapdoroti12
  lea dx, komandaINC
  mov cx, 4
  call detiIBuferi
  mov bl, [buferis+si]
  call spausdintiRegistra2
  ret
  praleistiapdoroti12:
  ; 0100 1reg – DEC registras (žodinis)
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111000b
  cmp bl, 01001000b
  jne praleistiapdoroti13
  lea dx, komandaDEC
  mov cx, 4
  call detiIBuferi
  mov bl, [buferis+si]
  call spausdintiRegistra2
  ret
  praleistiapdoroti13:
  ; 0101 0reg – PUSH registras (žodinis)
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111000b
  cmp bl, 01010000b
  jne praleistiapdoroti14
  lea dx, komandaPUSH
  mov cx, 5
  call detiIBuferi
  mov bl, [buferis+si]
  call spausdintiRegistra2
  ret
  praleistiapdoroti14:
  ;0101 1reg – POP registras (žodinis)
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111000b
  cmp bl, 01011000b
  jne praleistiapdoroti15
  lea dx, komandaPOP
  mov cx, 4
  call detiIBuferi
  mov bl, [buferis+si]
  call spausdintiRegistra2
  ret
  praleistiapdoroti15:
  ;1100 0011 – RET
  cmp [buferis+si], 11000011b
  jne praleistiapdoroti16
  lea dx, komandaRET
  mov cx, 4
  call detiIBuferi
  ret
  praleistiapdoroti16:
  ;1100 1011 - RETF
  cmp [buferis+si], 11001011b
  jne praleistiapdoroti17
  lea dx, komandaRETF
  mov cx, 5
  call detiIBuferi
  ret
  praleistiapdoroti17:
  ret
apdoroti1 endp
apdoroti2 proc
  ; JUMPAI 0111 0000 - 0111 1111
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11110000b
  cmp bl, 01110000b 
  jne praleistiApdoroti21
  mov bl, [buferis+si]
  sub bx, 01110000b
  mov cx, 0
  mov cl, [jumpIlgiai+bx]
  add bx, bx
  add bx, bx
  lea dx, [jumpai+bx]
  call detiIBuferi
  call spausdintiPoslinki
  ret
praleistiApdoroti21:
  ; 1110 0011 poslinkis – JCXZ 
  cmp [buferis+si], 11100011b
  jne praleistiApdoroti22
  lea dx, [jumpJCXZ]
  mov cx, 5
  call detiIBuferi
  call spausdintiPoslinki
  ret
praleistiApdoroti22:
  ;1100 1101 numeris – INT numeris
  cmp [buferis+si], 11001101b
  jne praleistiApdoroti23
  lea dx, [komandaINT]
  mov cx, 4
  call detiIBuferi
  mov dh, [buferis+si+1]
  mov [kiekSpausdinti], 2
  call spausdintiRegistra
  ret
praleistiApdoroti23:
  ;1110 0010 poslinkis - LOOP
  cmp [buferis+si], 11100010b
  jne praleistiApdoroti24
  lea dx, [komandaLOOP]
  mov cx, 5
  call detiIBuferi
  mov dx, [poslinkis]
  mov bx, 0
  mov bl, [buferis+si+1]
  cmp bl, 127
  jb praleistiPoslinki3
  mov bh, 11111111b
praleistiPoslinki3:
  mov bl, [buferis+si+1]
  add dx, bx
  add dx, 2
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  ret
praleistiApdoroti24:
  ;1110 1011 poslinkis – JMP žymė (vidinis artimas)
  cmp [buferis+si], 11101011b
  jne praleistiApdoroti25
  lea dx, [komandaJMP]
  mov cx, 4
  call detiIBuferi
  call spausdintiPoslinki
  ret
praleistiApdoroti25:
  ret
apdoroti2 endp
apdoroti3 proc
  ;1100 1010 bojb bovb – RETF betarpiškas operandas
  cmp [buferis+si], 11001010b
  jne praleistiApdoroti31
  lea dx, [komandaRETF]
  mov cx, 5
  call detiIBuferi
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  mov [kiekSpausdinti], 4
  call spausdintiRegistra
  ret
praleistiApdoroti31:
  ;1100 0010 bojb bovb – RET betarpiškas operandas
  cmp [buferis+si], 11000010b
  jne praleistiApdoroti32
  lea dx, [komandaRET]
  mov cx, 4
  call detiIBuferi
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  mov [kiekSpausdinti], 4
  call spausdintiRegistra
  ret
praleistiApdoroti32:
  ;1110 1000 adr.j.b. adr.v.b. – CALL žymė (vidinis tiesioginis)
  cmp [buferis+si], 11101000b
  jne praleistiApdoroti33
  lea dx, [komandaCALL]
  mov cx, 5
  call detiIBuferi
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  add dx, poslinkis
  add dx, 3
  mov [kiekSpausdinti], 4
  call spausdintiRegistra
  ret
praleistiApdoroti33:
  ;1110 1001 pjb pvb – JMP žymė (vidinis tiesioginis) ??? 
  cmp [buferis+si], 11101001b
  jne praleistiApdoroti34
  lea dx, [komandaJMP]
  mov cx, 4
  call detiIBuferi
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  add dx, poslinkis
  add dx, 3
  mov [kiekSpausdinti], 4
  call spausdintiRegistra
  ret
praleistiApdoroti34:
  ;1010 000w ajb avb – MOV akumuliatorius atmintis
  mov bl, [buferis+si]
  and bl, 11111110b
  cmp bl, 10100000b
  jne praleistiApdoroti35
  lea dx, [komandaMOV]
  mov cx, 4
  call detiIBuferi
  mov bl, 0
  call spausdintiRegistra2
  call detiKableli
  mov reikiaSkliaustu, 1
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  ret
  ;1010 001w ajb avb – MOV atmintis akumuliatorius
praleistiApdoroti35:
  mov bl, [buferis+si]
  and bl, 11111110b
  cmp bl, 10100010b
  jne praleistiApdoroti36
  lea dx, [komandaMOV]
  mov cx, 4
  call detiIBuferi
  mov reikiaSkliaustu, 1
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  call detiKableli
  mov bl, 0
  call spausdintiRegistra2
  ret
praleistiApdoroti36:
  ret
apdoroti3 endp
apdoroti4 proc
  call detiTarpa
  ;1111 011w mod 100 r/m [poslinkis] – MUL registras/atmintis
  cmp reg, 100b
  jne praleistiApdoroti41
  lea dx, komandaMUL
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  ret
  praleistiApdoroti41:
  ;1111 011w mod 110 r/m [poslinkis] – DIV registras/atmintis
  cmp reg, 110b
  jne praleistiApdoroti42
  lea dx, komandaDIV
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiApdoroti42: 
  ret
apdoroti4 endp
apdoroti5 proc
  call detiTarpa
  ;1111 111w mod 000 r/m [poslinkis] – INC registras/atmintis
  cmp reg, 000b
  jne praleistiApdoroti51
  lea dx, komandaINC
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiApdoroti51:
  ;1111 111w mod 001 r/m [poslinkis] – DEC registras/atmintis
  cmp reg, 001b
  jne praleistiApdoroti52
  lea dx, komandaDEC
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiApdoroti52:
  ;1111 1111 mod 110 r/m [poslinkis] – PUSH registras/atmintis
  cmp reg, 110b
  jne praleistiApdoroti53
  lea dx, komandaPUSH
  mov cx, 5
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiApdoroti53:
  ;1111 1111 mod 100 r/m [poslinkis] – JMP adresas (vidinis netiesioginis)
  cmp reg, 100b
  jne praleistiApdoroti54
  lea dx, komandaJMP
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiApdoroti54:
  ;1111 1111 mod 101 r/m [poslinkis] – JMP adresas (išorinis netiesioginis)
  cmp reg, 101b
  jne praleistiApdoroti55
  lea dx, komandaJMP
  mov cx, 4
  call detiIBuferi
  mov reikiadWord, 1
  call adresacijosBaitas
  ret
praleistiApdoroti55:
  ;1111 1111 mod 010 r/m [poslinkis] – CALL adresas (vidinis netiesioginis)
  cmp reg, 010b
  jne praleistiApdoroti56
  lea dx, komandaCALL
  mov cx, 5
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiApdoroti56:
  ;1111 1111 mod 011 r/m [poslinkis] – CALL adresas (išorinis netiesioginis)
  cmp reg, 011b
  jne praleistiApdoroti57
  lea dx, komandaCALL
  mov cx, 5
  call detiIBuferi
  mov reikiadWord, 1
  call adresacijosBaitas
  ret
praleistiApdoroti57:
  ret
apdoroti5 endp
apdoroti6 proc
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111110b
  ;0010 110w bojb [bovb] – SUB akumuliatorius -= betarpiškas operandas
  cmp bl, 00101100b
  jne praleistiapdoroti61
  lea dx, komandaSUB
  mov cx, 4
  call detiIBuferi
  call apdoroti6_2
  ret
praleistiapdoroti61:
  ;0011 110w bojb [bovb] – CMP akumuliatorius ~ betarpiškas operandas
  cmp bl, 00111100b
  jne praleistiapdoroti62
  lea dx, komandaCMP
  mov cx, 4
  call detiIBuferi
  call apdoroti6_2
  ret
praleistiapdoroti62:
  ;0000 010w bojb [bovb] – ADD akumuliatorius += betarpiškas operandas
  cmp bl, 00000100b
  jne praleistiapdoroti63
  lea dx, komandaADD
  mov cx, 4
  call detiIBuferi
  mov bx, 0
  call apdoroti6_2
  ret
praleistiapdoroti63:
  ;1011 wreg bojb [bovb] – MOV registras betarpiškas operandas
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11110000b
  cmp bl, 10110000b
  jne praleistiapdoroti64
  lea dx, [komandaMOV]
  mov cx, 4
  call detiIBuferi
  mov bl, reg
  call apdoroti6_2
  ret
praleistiapdoroti64:
  ret
apdoroti6 endp
apdoroti6_2 proc
  cmp w, 1
  je praleistiapdoroti6_2
  call spausdintiRegistra2
  call detiKableli
  mov dh, [buferis+si+1]
  mov kiekSpausdinti, 2
  call spausdintiRegistra
  ret
praleistiapdoroti6_2:
  call spausdintiRegistra2
  call detiKableli
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  ret
apdoroti6_2 endp
apdoroti7 proc
  ;1001 1010 ajb avb srjb srvb – CALL žymė (išorinis tiesioginis)
  cmp [buferis+si], 10011010b
  jne praleistiapdoroti71
  lea dx, [komandaCALL]
  mov cx, 5
  call detiIBuferi
  call apdoroti7_2
  ret
praleistiapdoroti71:
  ;1110 1010 ajb avb srjb srvb – JMP žymė (išorinis tiesioginis)
  cmp [buferis+si], 11101010b
  jne praleistiapdoroti72
  lea dx, [komandaJMP]
  mov cx, 4
  call detiIBuferi
  call apdoroti7_2
  ret
praleistiapdoroti72:
  ret
apdoroti7 endp
apdoroti7_2 proc
  mov kiekSpausdinti, 4
  mov dl, [buferis+si+3]
  mov dh, [buferis+si+4]
  call spausdintiRegistra
  lea dx, [dvitaskis]
  mov cx, 1
  call detiIBuferi
  mov dl, [buferis+si+1]
  mov dh, [buferis+si+2]
  call spausdintiRegistra
  ret
apdoroti7_2 endp
apdoroti8 proc
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111100b
  ;0000 00dw mod reg r/m [poslinkis] – ADD registras += registras/atmintis
  cmp bl, 00000000b
  jne praleistiapdoroti81
  lea dx, [komandaADD]
  mov cx, 4
  call detiIBuferi
  jmp pabapdoroti8
praleistiapdoroti81:
  ;0010 10dw mod reg r/m [poslinkis] – SUB registras -= registras/atmintis
  cmp bl, 00101000b
  jne praleistiapdoroti82
  lea dx, [komandaSUB]
  mov cx, 4
  call detiIBuferi
  jmp pabapdoroti8
praleistiapdoroti82:
  ;0011 10dw mod reg r/m [poslinkis] – CMP registras ~ registras/atmintis
  cmp bl, 00111000b
  jne praleistiapdoroti83
  lea dx, [komandaCMP]
  mov cx, 4
  call detiIBuferi
  jmp pabapdoroti8
praleistiapdoroti83:
  ;1000 10dw mod reg r/m [poslinkis] – MOV registras registras/atminti
  cmp bl, 10001000b
  jne praleistiapdoroti84
  lea dx, [komandaMOV]
  mov cx, 4
  call detiIBuferi
  jmp pabapdoroti8
praleistiapdoroti84:
  ;1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis
  cmp [buferis+si], 10001111b
  jne praleistiapdoroti85
  lea dx, [komandaPOP]
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  ret
praleistiapdoroti85:
  ;1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras registras/atmintis
  mov bx, 0
  mov bl, [buferis+si]
  and bl, 11111101b
  cmp bl, 10001100b
  jne praleistiapdoroti86
  lea dx, [komandaMOV]
  mov cx, 4
  call detiIBuferi
  mov w, 1
  jmp pabapdoroti8
praleistiapdoroti86:
  ret
pabapdoroti8:
  cmp d, 0
  je pab1apdoroti8
  mov bl, [buferis+si]
  and bl, 11111101b
  cmp bl, 10001100b
  jne pabapdoroti8_
  mov segmentoReg, 1
pabapdoroti8_:
  mov bl, reg
  call spausdintiRegistra2
  call detiKableli
  call adresacijosBaitas
  ret
pab1apdoroti8:
  call adresacijosBaitas
  call detiKableli
  mov bl, [buferis+si]
  and bl, 11111101b
  cmp bl, 10001100b
  jne pabapdoroti8_2
  mov segmentoReg, 1
pabapdoroti8_2:
  mov bl, reg
  call spausdintiRegistra2
  ret
apdoroti8 endp
apdoroti9 proc
  ;1000 00sw mod 000 r/m [poslinkis] bojb [bovb] – ADD registras/atmintis += betarpiškas operandas
  cmp reg, 000b
  jne praleistiapdoroti91
  lea dx, [komandaADD]
  mov cx, 4
  call detiIBuferi
  call apdoroti9_2
  ret
praleistiapdoroti91:
  ;1000 00sw mod 101 r/m [poslinkis] bojb [bovb] – SUB registras/atmintis -= betarpiškas operandas
  cmp reg, 101b
  jne praleistiapdoroti92
  lea dx, [komandaSUB]
  mov cx, 4
  call detiIBuferi
  call apdoroti9_2
  ret
praleistiapdoroti92:
  ;1000 00sw mod 111 r/m [poslinkis] bojb [bovb] – CMP registras/atmintis ~ betarpiškas operandas
  cmp reg, 111b
  jne praleistiapdoroti93
  lea dx, [komandaCMP]
  mov cx, 4
  call detiIBuferi
  call apdoroti9_2
  ret
praleistiapdoroti93:
  ret
apdoroti9 endp
apdoroti9_2 proc
  call adresacijosBaitas
  call detiKableli
  cmp lygus1,1
  je praleistiapdoroti9_21
  cmp w,1
  je praleistiapdoroti9_22
  mov bx, 0
  mov bl, komandosIlgis
  mov dh, [buferis+bx-1+si]
  mov kiekSpausdinti, 2
  call spausdintiRegistra
  ret
praleistiapdoroti9_22:
  mov bx, 0
  mov bl, komandosIlgis
  mov dl, [buferis+bx-2+si]
  mov dh, [buferis+bx-1+si]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  ret
praleistiapdoroti9_21:
  mov bx, 0
  mov bl, komandosIlgis
  mov dl, [buferis+bx-1+si]
  shr dl, 7
  cmp dl, 1
  je praleistiapdoroti9_23
  mov dh, 0
  mov dl, [buferis+bx-1+si]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  mov lygus1, 0
  ret
  praleistiapdoroti9_23:
  mov dh, 11111111b
  mov dl, [buferis+bx-1+si]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  mov lygus1, 0
  ret
apdoroti9_2 endp
apdoroti12 proc
  ;1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV registras/atmintis betarpiškas operandas
  lea dx, [komandaMOV]
  mov cx, 4
  call detiIBuferi
  call adresacijosBaitas
  call detiKableli
  mov bl, komandosIlgis
  cmp w, 1
  je praleistiapdoroti121
  mov dh, [buferis+bx+si-1]
  mov kiekSpausdinti, 2
  call spausdintiRegistra
  ret
praleistiapdoroti121:
  mov dh, [buferis+bx+si-1]
  mov dl, [buferis+bx+si-2]
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  ret
apdoroti12 endp
spausdintiPagalba proc
  lea dx, pagalba
  mov ah, 9
  int 21h
  call pabaiga
spausdintiPagalba endp
nuskaityti proc
  push ax 
  push bx
  push dx
  push cx

  mov bx, 0
ciklasNuskaityti:
  cmp cx, 0
  je pabaigaCiklasNuskaityti
  mov al, [buferis+si]
  mov [buferis+bx], al
  inc bx
  inc si
  dec cx
  jmp ciklasNuskaityti
pabaigaCiklasNuskaityti:
  
  lea dx, [buferis+bx]
  mov cx, buferioDydis
  sub cx, bx
  mov bx, handleIN
  mov ah, 3fh
  int 21h
  
  pop cx
  add cx, ax
  
  cmp ax, 0
  jne praleistiNuskaityti
  mov [darSkaityti], 1
praleistiNuskaityti:

  pop dx
  pop bx
  pop ax
  ret
nuskaityti endp
detiIBuferi proc
  push bx
  mov bx, dx
deti:
  cmp cx, 0
  je baigtiDeti
  mov dl, byte ptr[bx]
  mov [buferisOUT+di], dl
  inc di
  inc bx
  cmp di, buferioDydis
  jne praleistiDeti
  call spausdinti
praleistiDeti:
  dec cx
  jmp deti
baigtiDeti:
  pop bx
  ret  
detiIBuferi endp
spausdinti proc
  push dx
  push bx
  push cx

  mov bx, handleOUT
  mov ah, 40h
  mov cx, di
  lea dx, buferisOUT
  int 21h

  mov di, 0
  pop cx
  pop bx
  pop dx
  ret
spausdinti endp
spausdintiRegistra proc
  push bx
  push cx
  cmp reikiaSkliaustu, 1
  jne nereikia1
  push dx
  mov cx, 1
  lea dx, [skliaustai]
  call detiIBuferi
  pop dx
nereikia1:
  mov cx, 0
spausdintiRegistraCiklas:
  cmp cl, [kiekSpausdinti]
  je pabaigaspausdintiRegistraCiklas
  push dx
  and dh, 11110000b
  mov bh, dh
  pop dx
  shr bh, 4
  add bh, '0'
  cmp bh, '9'
  jle praleistispausdintiRegistraCiklas
  add bh, 7
praleistispausdintiRegistraCiklas:
  mov [buferisOUT+di], bh
  inc di
  cmp di, buferioDydis
  jne praleistispausdintiRegistraCiklas2
  call spausdinti
praleistispausdintiRegistraCiklas2:
  shl dx, 4
  inc cl
  jmp spausdintiRegistraCiklas
pabaigaspausdintiRegistraCiklas:
  cmp reikiaSkliaustu, 1
  jne nereikia2
  mov cx, 1
  lea dx, [skliaustai+1]
  call detiIBuferi
nereikia2:
  mov reikiaSkliaustu, 0
  pop cx
  pop bx
  ret
spausdintiRegistra endp
spausdintiRegistra2 proc
  and bx, 00000111b
  add bx, bx
  cmp segmentoReg, 1
  jne neSegmentas
  lea dx, [segmentoRegistrai+bx]
  jmp praleistispausdintiRegistra22
neSegmentas:
  cmp w, 0
  je praleistispausdintiRegistra2
  lea dx, [registraiZodiniai+bx]
  jmp praleistispausdintiRegistra22
praleistispausdintiRegistra2:
  lea dx, [registraiBaito+bx]
praleistispausdintiRegistra22:
  mov cx, 2
  call detiIBuferi
  mov segmentoReg, 0
  ret
spausdintiRegistra2 endp
spausdintiPoslinki proc
  mov dx, [poslinkis]
  mov bx, 0
  mov bl, [buferis+si+1]
  cmp bl, 127
  jb praleistispausdintiPoslinki
  mov bh, 11111111b
praleistispausdintiPoslinki:
  mov bl, [buferis+si+1]
  add dx, bx
  add dx, 2
  mov kiekSpausdinti, 4
  call spausdintiRegistra
  ret
spausdintiPoslinki endp
spausdintiKomanda proc
  push si
spausdintiKomandaCiklas:
  cmp cx, 0
  je spausdintiKomandaCiklasPab
  mov dh, [buferis+si]
  mov kiekSpausdinti, 2
  call spausdintiRegistra
  inc si
  dec cx
  jmp spausdintiKomandaCiklas
spausdintiKomandaCiklasPab:
  pop si
ret
spausdintiKomanda endp
apdorotiadresacijosBaita proc
  mov bl, [buferis+si]
  and bl, 00000010b
  shr bl, 1
  mov d, bl
  mov bl, [buferis+si]
  and bl, 00000001b
  mov w, bl
  mov bl, [buferis+si+1]
  and bl, 00000111b
  mov rm, bl
  mov bl, [buferis+si+1]
  and bl, 00111000b
  shr bl, 3
  mov reg, bl
  mov bl, [buferis+si+1]
  and bl, 11000000b
  shr bl, 6
  mov m0d, bl
  cmp m0d, 10b
  jne praleistiapdorotiadresacijosBaita1
  mov komandosIlgis, 4
  ret
praleistiapdorotiadresacijosBaita1:
  cmp m0d, 01b
  jne praleistiapdorotiadresacijosBaita2
  mov komandosIlgis, 3
  ret
praleistiapdorotiadresacijosBaita2:
  cmp rm, 110b
  jne praleistiapdorotiadresacijosBaita3
  cmp m0d, 00b
  jne praleistiapdorotiadresacijosBaita3
  mov komandosIlgis, 4
  ret
praleistiapdorotiadresacijosBaita3:
  mov komandosIlgis, 2
  ret
apdorotiadresacijosBaita endp
adresacijosBaitas proc
  cmp m0d, 11b
  jne praleistiAdresacijosBaitas1
  mov bl, rm
  call spausdintiRegistra2
  ret
praleistiAdresacijosBaitas1:
  cmp reikiadWord, 1
  jne praleistiAdresacijosBaitas1_
  mov reikiadWord, 0
  lea dx, dwordptr
  mov cx, 10
  call detiIBuferi
  jmp praleistiAdresacijosBaitas4
praleistiAdresacijosBaitas1_:
  cmp w, 0
  jne praleistiAdresacijosBaitas3
  lea dx, byteptr
  mov cx, 9
  call detiIBuferi
  jmp praleistiAdresacijosBaitas4
praleistiAdresacijosBaitas3:
  lea dx, wordptr
  mov cx, 9
  call detiIBuferi
praleistiAdresacijosBaitas4:
  call spausdintiSegmenta
  mov cx, 1
  lea dx, skliaustai
  call detiIBuferi
  cmp rm, 110b
  je praleistiAdresacijosBaitas5
  mov bx, 0
  mov bl, rm
  mov bl, [bx+adresuiPoslinkiai]
  lea dx, [adresui+bx]
  mov bl, rm
  mov bl, [bx+ilgiai]
  mov cx, bx
  call detiIBuferi
  jmp praleistiAdresacijosBaitas6
praleistiAdresacijosBaitas5:
  mov kiekSpausdinti, 4
  mov dl, [buferis+si+2]
  mov dh, [buferis+si+3]
  call spausdintiRegistra
  jmp praleistiAdresacijosBaitas8
praleistiAdresacijosBaitas6:
  cmp m0d, 01b
  jne praleistiAdresacijosBaitas7
  lea dx, pliusas
  mov cx, 1
  call detiIBuferi
  mov kiekSpausdinti, 2
  mov dh, [buferis+si+2]
  call spausdintiRegistra
  jmp praleistiAdresacijosBaitas8
praleistiAdresacijosBaitas7:
  cmp m0d, 10b
  jne praleistiAdresacijosBaitas8
  lea dx, pliusas
  mov cx, 1
  call detiIBuferi
  mov kiekSpausdinti, 4
  mov dl, [buferis+si+2]
  mov dh, [buferis+si+3]
  call spausdintiRegistra
praleistiAdresacijosBaitas8:
  mov cx, 1
  lea dx, [skliaustai+1]
  call detiIBuferi
  ret
adresacijosBaitas endp
spausdintiSegmenta proc
  cmp reikiaSegmentoRegistro, 1
  jne praleistispausdintiSegmenta
  mov cx, 2
  lea dx, segmentas
  call detiIBuferi
  mov cx, 1
  lea dx, dvitaskis
  call detiIBuferi
praleistispausdintiSegmenta:
  mov reikiaSegmentoRegistro,0
  ret
spausdintiSegmenta endp
gautiS proc
  inc komandosIlgis
  cmp d, 1
  jne nelygus
  cmp w, 1
  jne nelygus
  mov lygus1, 1
nelygus:
  cmp lygus1, 1
  je nelygus1
  cmp w,1
  jne nelygus1
  inc komandosIlgis
nelygus1:
  ret
gautiS endp
nauja proc
  lea dx, naujaEilute
  mov cx, 1
  call detiIBuferi
  ret
nauja endp
detiTarpa proc
  mov cx, 1
  lea dx, [tarpas]
  call detiIBuferi
  ret
detiTarpa endp
detiKableli proc
  mov cx, 1
  lea dx, [kablelis]
  call detiIBuferi
  ret
detiKableli endp
atnaujinti proc
  mov bx, 0
  mov bl, komandosIlgis
  sub cx, bx
  add si, bx
  add poslinkis, bx
  ret
atnaujinti endp
pabaiga proc
  call spausdinti
  mov ah, 3Eh
  mov bx, handleIN
  int 21h
  mov ah, 3Eh
  mov bx, handleOUT
  int 21h
  mov ax, 4C00h
  int 21h
pabaiga endp
end start