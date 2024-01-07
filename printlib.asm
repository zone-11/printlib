section .data
		INDENT 		db 		0x0a, 0x00
		

;calculates the message length
;without including the 0 at the end 
;edi:	msg address ptr
;esi:	msg length
strln:
		pushf
		push 	ecx	
		push 	eax
		push 	edi
		
		xor 	ecx, ecx 	;init counter
		dec 	ecx 		;decrement counter so as to not to trigger the repnz and clear ZF

		mov 	al, 0		;init zero char
		repnz				;decrement counter while
		scasb				;byte isnt 0x00

		inc 	ecx			;increment it because decrement it early
        inc     ecx         ;increment becoues 0 isnt counted
		neg 	ecx 		;invert length
		mov 	esi, ecx	;copy ecx to the output register

		pop 	edi
		pop 	eax	
		pop 	ecx
		popf
		ret 

;prints message to terminal without indentation
;edi:	message address ptr
print:
		sub 	esp, 20	
		mov 	[esp], esi
		mov 	[esp+4], eax
		mov 	[esp+8], ebx
		mov 	[esp+12], ecx
		mov 	[esp+16], edx

		mov 	eax, 4
		mov 	ebx, 1
		mov 	ecx, edi
		call 	strln
		mov 	edx, esi
		int 	0x80

		pop 	esi
		pop 	eax
		pop 	ebx
		pop 	ecx
		pop 	edx
		ret

;prints message to terminal with indentation
;edi: 	msg address
println:
		push 	edi

		call 	print			;print the message

		mov 	edi, INDENT 	;print an indent
		call 	print			;
		
		pop 	edi
		ret

;prints formatted message
;edi: 	msg address
;load args in the stack in reverse order
;%s -	string
printf:
        sub     esp, 20         ;allocate memory for local variables

		mov 	[esp+16], eax	;
		mov 	[esp+12], edx 	;
		mov 	[esp+8], ecx	;
		mov 	[esp+4], esi	;init local variables
		mov 	[esp], edi		;

		push 	ebp				;
		mov 	ebp, esp		;save stack pointer
		
		add     esp, 28 		;go to arguments
.loop:	
		cmp		byte [edi], 0x00;if byte is 0
		jz 		short .end		;then jump to .end

		cmp	 	byte [edi], "%"	;if byte isnt the insert sign(%)
		jnz 	short .next		;then jump to .next
		
		cmp 	byte [edi+1],"s";if the insert type is string
		jz 		short .string	;then jump to .string

		cmp 	byte [edi+1],"d";if the insert type is decimal
		jz 		short .decimal	;then jump to .decimal
.next:	
		inc 	edi				;next byte
		jmp 	short .loop		

.string:
        xchg    esp, ebp        ;move the SP to call strln
		call 	strln			;calculate length to zero string
        xchg    esp, ebp        ;return the SP back

        dec     esi             ;<%_> isnt counted
        dec     esi             ;
		mov 	eax, esi		;save the length to zero string
        mov     edx, edi        ;save the current string pointer

        mov     edi, [esp]      ;get the arguement
        xchg    esp, ebp        ;mov the SP to call strln
        call    strln           ;calculate the argument length
        xchg    esp, ebp        ;return the SP back
        mov     ecx, esi        ;save the argument length

        ;setting the movsb instruction
        lea     esi, [edx+eax+1]
        lea     edi, [edx+ecx]
        lea     edi, [edi+eax-1]

        ;cmp     byte [esi], 0   ;if there is nothing after the insertion space
        ;jz      short .insert   ;then jump to .insert
        
		;move the part of the message
		;from the place for insertion
        std
		xchg 	ecx, eax		;set the string length to zero in the counter (eax = arg length)
		rep						;while counter isnt 0
		movsb					;move a byte to a new location
        cld
		
		;insert the string
.insert:
		pop 	esi				;get the string
		mov 	edi, edx		;move the insertion place to edi
		mov 	ecx, eax		;set the argument length in the counter 
		rep 					;while counter isnt 0
		movsb					;move a string byte to the insertion place
        
		;TODO: Debug it!
        jmp    short .next

.decimal:


.end:		
		mov 	esp, ebp

		pop 	ebp
		pop 	edi
		pop 	esi
		pop 	ecx
        pop     edx
        pop     eax

		call 	println

		ret
		












