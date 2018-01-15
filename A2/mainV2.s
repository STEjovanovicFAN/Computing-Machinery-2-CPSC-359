.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART

	ldr	r0, =Intro	// Loads the intro message into r0
	mov	r1, #25		// Allows enough space for the message
	bl	WriteStringUART	// Prints the message on screen

// This is a prompt for user input
List_Size_Input:
	ldr	r0, =List_Size		//Loads the address of the prompt into r0
	mov	r1, #45			// Allows enough space for the prompt
	bl	WriteStringUART		// Prompts the user

// This will read the user input and save into ABuff.

	ldr	r0, =ABuff		// Loads the address of the buffer into r0
	mov	r1, #256		// Allows 256 bits of space
	bl	ReadLineUART		// Reads the user input

	cmp	r0, #1			// Checks to see if the user input a single digit
	bne	List_Size_Error		// If they entered more than one digit, branch to error message
	ldr	r2, =ABuff		// sets r2 to the pointer of ABuff
	ldrb	r3, [r2]		// loads the contents of the first bit of ABuff into r3

  mov  r9, r3       //move user input into register 9
  bl  qCheck        //check if user input is "q" or "Q"

  cmp  r3, #57      //compare if the value is greater then 9
  bgt List_Size_Error //throw error is value is greater then 9

  cmp  r3, #48        // comapre if input is less than 0
  ble List_Size_Error //throw error if value is less than 0

	sub	r3, #48        //get actual value and store in r3

  mov r4, #0          //loop counter, initalize to 0
  mov r5, #0          //register 5 is our List_Prompt counter

doWhile:              //do while loop
  ldr r0, =List_Prompt//ask user what xth number to put in
  add  r0, r5         //add with the List_Prompt counter, this is our pointer
  mov  r1, #32        //this is how many characters we will read after pointer
  bl	WriteStringUART //display message

  ldr  r0, =input     //get user input
  mov  r1, #5         //read  first 4 characters
  bl	ReadLineUART    //store the values

four:
  cmp  r0, #4         //check if lenght 4
  blt  three          //if not length 4 check next case

  b errorB            //show error message

  b   doWhile         //do over the loop without updated gaurds

three:
  cmp  r0, #3
  blt  two

  ldr r6, =input
  ldr r7, [r6]
  add  r6, #1
  ldr r8, [r6]
  add  r6, #1
  ldr  r9, [r6]

  //check first plaement
  cmp  r7, #48      //compare if r7 is lower then ascii 0
  blt  errorB
  cmp  r7, #57       //compare if r7 is higher then ascii 9
  bgt  errorB

  //check second plaement
  cmp  r8, #48      //compare if r8 is lower then ascii 0
  blt  errorB
  cmp  r8, #57       //compare if r8 is higher then ascii 9
  bgt  errorB

  //check third plaement
  cmp  r9, #48      //compare if r9 is lower then ascii 0
  blt  errorB
  cmp  r9, #57       //compare if r9 is higher then ascii 9
  bgt  errorB

  sub   r7, #48      //convert ascii to int
  sub   r8, #48      //convert ascii to int
  sub   r9, #48      //convert ascii to int

  add   r7, r7, r7, r7, r7, r7, r7, r7, r7, r7, r7, //multiply r7 by 10 
  mul   r8, #10
  mul   r9, #1

  add  r10, r7, r8, r9  //r10= r7+r8+r9
  cmp  r10, #100

  bgt  errorB

two:


//6789

one:














  add  r4, #1         //loop counter++;
  cmp  r4, r3         //compare loopcounter with size of array
  beq  endLoop        //end if the loopcounter == size of array

  add  r5, #32        //update List_Prompt counter by 30, to get the next 30 char message

  b   doWhile         //do loop over again

errorB:
  ldr  r0, =errorA    //load error message
  mov  r1, #69        //read 69 chars of the error message
  bl  WriteStringUART //write to screen

    b doWhile

endLoop:


  b   haltLoop$



qCheck:
  cmp  r9, #81      //check if it's "Q"
  beq  haltLoop$    //if it is branch to halt loop to end program

  cmp  r9, #113     //check if it's "q"
  beq  haltLoop$    //if it is branch to halt loop to end program

  mov  pc,  lr      //move to previous code that called this branch



// This loop halts the program
haltLoop$:
	b	haltLoop$


// This is the label to print the list size error message
List_Size_Error:
	ldr	r0, =List_Size_Error_Message	// Loads the address of the error message into r0
	mov	r1, #59				// Allows enough space for the error message
	bl	WriteStringUART			// Prints the error message
	b	List_Size_Input			// Branches back to prompt to the user


.section .data

.align	2
	.int 42
AStructure:
	.byte 	12
	.hword	0xA3


ABuff:
	.rept	256
	.byte	0
	.endr

input:
  .rept 5
  .byte 0
  .endr


An_Array:

	.int	0,0,0,0,0,0,0,0,0,0


Intro:
	.ascii	"Created by: Ivan Ristanen" //25

List_Size:
	.ascii	"\n\rPlease enter the size of the number list"
	.ascii	"\n\r>"

List_Size_Error_Message:
	.ascii	"\n\rPlease enter a single digit value between 1-9 (inclusive)"

errorA:
  .ascii  "\n\rError. Input is invalid. Input should be an integer between 0-100."//69

List_Prompt:

	.ascii "\n\rPlease enter first number:  \n\r"
  .ascii "\n\rPlease enter second number: \n\r"
  .ascii "\n\rPlease enter third number:  \n\r"
  .ascii "\n\rPlease enter fourth number: \n\r"
  .ascii "\n\rPlease enter fith number:   \n\r"
  .ascii "\n\rPlease enter sixth number:  \n\r"
  .ascii "\n\rPlease enter seventh number:\n\r"
  .ascii "\n\rPlease enter eighth number: \n\r"
  .ascii "\n\rPlease enter ninth number:  \n\r"

SomeNumbers:
	.int	2*3
	.int	4,5,6
	.int	ABuff

NumNumbers:
	.int	(.-SomeNumbers)/4
