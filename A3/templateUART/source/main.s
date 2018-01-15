.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
  mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
  bl		InitUART               // Initialize the UART

  ldr	r0, =Intro	            // Loads the intro message into r0
	mov	r1, #50		              // Allows enough space for the message
	bl	WriteStringUART	        // Prints the message on screen

  mov r0, #9  //pin #9
  mov r1, #1 //output function code //#001
  bl  initGPIO  //initialize

  mov  r0, #10 //pin #10
  mov  r1, #0 //input function code //#000
  bl  initGPIO  //initialize

  mov r0, #11  //pin #11
  mov r1, #1 //output function code //#001
  bl  initGPIO  //initialize


Print_Ask_Buttons:

//we ask the user to press button
//print message to ask to press a button(s)
ldr	r0, =Input_Prompt	            // Loads the intro message into r0
mov	r1, #25		              // Allows enough space for the message
bl  WriteStringUART


readSness:

  //initalize all buttons to 0
  mov  r9, #0

  //enable clock
  mov r1, #1                  //move 1 into r1 to enable clock
  bl Set_Clr_Clock            //call subroutine to enable the latch

  //enable latch
  mov  r1, #1                 //mov 1 into r1 to enable clock
  bl  Set_Clr_Latch           //call subroutine to enable the latch

  //wait .5 micro seconds
  ldr  r0, =0x3F003004        //load computer counter
  ldr  r1, [r0]               //read the computer counter
  mov  r6, #1
  lsl  r6, #17
  add  r1, r6                //we want to wait 0.5 seconds
  bl   Wait_Loop             //wait half a second

  //disable the latch
  mov r1, #0                //move 0 into r1 to disable the latch
  bl  Set_Clr_Latch         //cal subroutine to disable the latch

//loop 16 times
//counter i = r8
  mov r8, #0
readSnessLoop:
  //wait 6 micro seconds
  ldr  r0, =0x3F003004        //load computer counter
  ldr  r1, [r0]               //read the computer counter
  add  r1, #6                //we want to wait 6 micro seconds
  bl   Wait_Loop

  mov r1, #0                  //move 0 into r1 to disable clock
  bl Set_Clr_Clock            //call subroutine to disable the latch

  //wait 6 micro seconds
  ldr  r0, =0x3F003004        //load computer counter
  ldr  r1, [r0]               //read the computer counter
  add  r1, #6               //we want to wait 6 micro seconds
  bl  Wait_Loop

  bl Read_Data

  //r0 is the return bit of wether or not it was pressed or no
  //if r0 = 0 it was pressed
  //else when r = 1 it was not pressed

  lsl r0, r8        //left shift by the counter to get it's place
  add r9, r0        //now add our r0(return value) to the total value that we keep track of

  //enable clock
  mov r1, #1                  //move 1 into r1 to enable clock
  bl Set_Clr_Clock            //call subroutine to enable the clock

  add r8, #1        //update the counter

  cmp  r8, #16      //compare if we went through the loop 16 times already
  bne  readSnessLoop   //branch if it's not the 16th time


//break out of the 16 times loop
  //1111 1111111111 == 0xFFFF
  ldr  r5, =0xFFFF
  cmp r9, r5
  beq readSness

  mov  r5, #0           //loop counter
Find_Button_Loop:
  mov  r8, #1           //this is 0000 000000000001
  and  r7,  r8, r9      //and r9 with r8, put in r7

  add  r5, #1           //update loop counter
  lsr  r9, #1           //shift the total number by 1 to do the next and
  cmp  r7, #1           //compare (r8 and r9) with 1(button not pressed)
  beq  Find_Button_Loop //if r7 is 1 then button was not pressed, hence do loop again to find a button that was pressed

  //B pressed
  cmp  r5, #1           //now we compare if the loop counter is 1, if it is then B was pressed
  bne  next2
  ldr	r0, =B_Pressed	            // Loads the B_Pressed message
  mov	r1, #20		              // Allows enough space for the message
  bl  WriteStringUART

  next2:
  //Y pressed
  cmp  r5, #2           //now we compare if the loop counter is 2
  bne  next3
  ldr	r0, =Y_Pressed	         // Loads the  Y_Pressed message
  mov	r1, #20		              // Allows enough space for the message
  bl  WriteStringUART

  next3:
  //Select_Pressed
  cmp  r5, #3           //now we compare if the loop counter is 3
  bne  next4
  ldr	r0, =Select_Pressed	         // Loads the  Select_Pressed message
  mov	r1, #25	              // Allows enough space for the message
  bl  WriteStringUART

  next4:
  //Start_Pressed
  cmp  r5, #4           //now we compare if the loop counter is 4
  bne  next5
  ldr	r0, =Start_Pressed         // Loads the Start_Pressed message
  mov	r1, #24	              // Allows enough space for the message
  bl  WriteStringUART
  //when start button is pressed then we exit the program
  b   haltLoop$

  next5:
  //JoyPad_UP_Pressed
  cmp  r5, #5           //now we compare if the loop counter is 5
  bne  next6
  ldr	r0, =JoyPad_UP_Pressed        // Loads the JoyPad_UP_Pressed message
  mov	r1, #29	              // Allows enough space for the message
  bl  WriteStringUART

  next6:
  //JoyPad_DOWN_Pressed
  cmp  r5, #6          //now we compare if the loop counter is 6
  bne  next7
  ldr	r0, =JoyPad_DOWN_Pressed       // Loads the JoyPad_DOWN_Pressed message
  mov	r1, #31	              // Allows enough space for the message
  bl  WriteStringUART

  next7:
  //JoyPad_LEFT_Pressed
  cmp  r5, #7          //now we compare if the loop counter is 7
  bne  next8
  ldr	r0, =JoyPad_LEFT_Pressed      // Loads the JoyPad_LEFT_Pressed message
  mov	r1, #31	              // Allows enough space for the message
  bl  WriteStringUART

  next8:
  //JoyPad_RIGHT_Pressed
  cmp  r5, #8          //now we compare if the loop counter is 8
  bne  next9
  ldr	r0, =JoyPad_RIGHT_Pressed     // Loads the JoyPad_RIGHT_Pressed message
  mov	r1, #32	              // Allows enough space for the message
  bl  WriteStringUART

  next9:
  //A_Pressed
  cmp  r5, #9          //now we compare if the loop counter is 9
  bne  next10
  ldr	r0, =A_Pressed     // Loads the A_Pressed message
  mov	r1, #20	              // Allows enough space for the message
  bl  WriteStringUART

  next10:
  //X_Pressed
  cmp  r5, #10          //now we compare if the loop counter is 10
  bne  next11
  ldr	r0, =X_Pressed     // Loads the A_Pressed message
  mov	r1, #20	              // Allows enough space for the message
  bl  WriteStringUART

  next11:
  //LEFT_Pressed
  cmp  r5, #11          //now we compare if the loop counter is 11
  bne  next12
  ldr	r0, =LEFT_Pressed     // Loads the LEFT_Pressed message
  mov	r1, #23	              // Allows enough space for the message
  bl  WriteStringUART

  next12:
  //RIGHT_Pressed             //loop counter should be 12
  cmp  r5, #12               //now we compare if the loop counter is 11
  bne  done
  ldr	r0, =RIGHT_Pressed     // Loads the LEFT_Pressed message
  mov	r1, #24	              // Allows enough space for the message
  bl  WriteStringUART

done:
//call the message for user to press a button, then we start the loop over again
  b Print_Ask_Buttons


haltLoop$:
  //Exit_Program message
  ldr	r0, =Exit_Program   // Loads the Exit_Program message
  mov	r1, #15	              // Allows enough space for the message
  bl  WriteStringUART
quit:
	b	quit

Wait_Loop:
  push {lr}
Wait_Loop1:
  ldr  r2, [r0]         //load in the clock or latch adress
  cmp  r1, r2           //stop when the clock or latch == to the amount of time to Wait_Loop
  bhi Wait_Loop1
  pop {pc}           //return to caller



Set_Clr_Clock:
  push {lr}
  mov  r0, #11              // pin 11
  ldr  r2, =0x3F200000      //put adress of pin 11 into r2
  mov  r3,  #1
  lsl  r3, r0               //align bit for pin 11
  teq  r1, #0               //test if we write or clear depending on our n value
  streq r3, [r2, #40]       //GPCLR0 (0x28)
  strne r3, [r2, #28]       //GPSet0 (0x1C)
  pop {pc}

  Set_Clr_Latch:
    push {lr}
    mov  r0, #9              // pin 11
    ldr  r2, =0x3F200000      //put adress of pin 11 into r2
    mov  r3,  #1
    lsl  r3, r0               //align bit for pin 11
    teq  r1, #0               //test if we write or clear depending on our n value
    streq r3, [r2, #40]       //GPCLR0 (0x28)
    strne r3, [r2, #28]       //GPSet0 (0x1C)
    pop {pc}


Read_Data:
  push {lr}
  mov  r0, #10    // we want the 10th pin
  ldr  r2, =0x3F200000  // this is the base GPIO reg
  ldr  r1, [r2, #52]    //GPLEV0
  mov  r3, #1
  lsl  r3, r0         //aligning pin10 bit
  and  r1, r3         //mask everything else
  teq  r1, #0
  moveq r0, #0        // return 0
  movne r0, #1        // return 1
  pop {pc}


initGPIO:
  push {r4-r7, lr}

  mov  r3, r0   //copy of the pin #
  cmp  r3, #10  // compare to 10
  mov  r4, #0   //loop counter
  blt  next     // if it is less than we cannot subtract 10

subtract_loop:
  sub  r3, #10  //subtracts 10
  add  r4, #1   //increments loop counter (this is our quotient)
  cmp  r3, #10  //can we still subtract
  bge  subtract_loop  //if we can, loop back, if not continue
next:
  mov  r7, r3
  add  r7, r3       //multiplies the remainder by 2
  add  r7, r3       //adds another multiple of the remainder
  lsl  r4, #2   //this is our offset
  ldr  r2, =0x3F200000 //load the base address
  add  r2, r4   //now we have the appropriate GPFSEL register
  ldr  r5, [r2] //loads the GPFSEL into r5
  mov  r6, #7   // r6 = 111
  lsl  r6, r7   // gets us to the appropriate set of 3 bits (for the pin we want)
  bic  r5, r6   // clears the bits we are working with
  lsl  r1, r7   // moves the function code to the appropriate spot
  orr  r5, r1   // sets the the bits to the specified function code
  str  r5, [r2] // stores the new value back into the G
  pop  {r4-r7, pc}


.section .data
.align 2

Exit_Program:
  .ascii "Exiting Program" //15

Intro:
	.ascii	"\n\rCreated by: Ivan Ristanen and Stefan Jovanovic\n\r" //50

Input_Prompt:
  .ascii "Please press a button… \n\r"  //25

//1
B_Pressed:
  .ascii "You have pressed B\n\r" //20

//2
Y_Pressed:
  .ascii "You have pressed Y\n\r" //20

//3
Select_Pressed:
  .ascii "You have pressed Select\n\r" //25

//4
Start_Pressed:
  .ascii "You have pressed Start\n\r" //24

//5
JoyPad_UP_Pressed:
  .ascii "You have pressed Joy-Pad UP\n\r" //29

//6
JoyPad_DOWN_Pressed:
  .ascii "You have pressed Joy-Pad DOWN\n\r" //31

//7
JoyPad_LEFT_Pressed:
  .ascii "You have pressed Joy-Pad LEFT\n\r" //31

//8
JoyPad_RIGHT_Pressed:
  .ascii "You have pressed Joy-Pad RIGHT\n\r" //32

//9
A_Pressed:
  .ascii "You have pressed A\n\r" //20

//10
X_Pressed:
  .ascii "You have pressed X\n\r" //20

//11
LEFT_Pressed:
  .ascii "You have pressed LEFT\n\r" //23

//12
RIGHT_Pressed:
  .ascii "You have pressed RIGHT\n\r" //24
