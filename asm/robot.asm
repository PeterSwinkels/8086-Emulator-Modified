;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This 8086Emu example has been modified to be suitable for assembly with NASM.         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this is an example of contoling the robot.

; this code randomly moves the robot,
; and makes it to switch the lamps on and off.

; robot is a mechanical creature and it takes 
; some time for it to complete a task.
; status register is used to see if robot is busy or not.

; c:\emu8086\devices\robot.exe uses ports 9, 10 and 11
; source code of the robot and other devices is in:
; c:\emu8086\devices\developer\sources\
; robot is programmed in visual basic 6.0


; robot base i/o port:
r_port equ 9

;===================================

eternal_loop:
; wait until robot
; is ready:
call wait_robot

; examine the area
; in front of the robot:
mov al, 4
out r_port, al

call wait_exam

; get result from
; data register:
in al, r_port + 1

; nothing found?
cmp al, 0
je cont  ; - yes, so continue.

; wall?
cmp al, 255  
je cont  ; - yes, so continue.

; switched-on lamp?
cmp al, 7
jne lamp_off  ; - no, so skip.
; - yes, so switch it off,
;   and turn:
call switch_off_lamp 
jmp  cont  ; continue

lamp_off: nop

; if gets here, then we have
; switched-off lamp, because
; all other situations checked
; already:
call switch_on_lamp

cont:
call random_turn

call wait_robot

; try to step forward:
mov al, 1
out r_port, al

call wait_robot

; try to step forward again:
mov al, 1
out r_port, al

jmp eternal_loop ; go again!

;===================================

; this procedure does not
; return until robot is ready
; to receive next command:
wait_robot:
; check if robot busy:
busy: in al, r_port+2
      test al, 00000010b
      jnz busy ; busy, so wait.
ret    

;===================================

; this procedure does not
; return until robot completes
; the examination:
wait_exam:
; check if has new data:
busy2: in al, r_port+2
       test al, 00000001b
       jz busy2 ; no new data, so wait.
ret    

;===================================

; switch off the lamp:
switch_off_lamp:
mov al, 6
out r_port, al
ret

;===================================

; switch on the lamp:
switch_on_lamp:
mov al, 5
out r_port, al
ret

;===================================

; generates a random turn using
; system timer:
random_turn:

; get number of clock
; ticks since midnight
; in cx:dx
mov ah, 0
int 1ah

; randomize using xor:
xor dh, dl
xor ch, cl
xor ch, dh

test ch, 2
jz no_turn

test ch, 1
jnz turn_right

; turn left:
mov al, 2
out r_port, al
; exit from procedure:
ret  

turn_right:
mov al, 3
out r_port, al

no_turn:
ret

;===================================
