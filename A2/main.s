.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	    bl		EnableJTAG // Enable JTAG
      bl		InitUART  // Initialize the UART

      //print out our names
	    ldr	r0,	=dNames             //get the string to print out should be our names
      mov r1, #25                 //specify how many characters in the string you want to print out(which is 24 characters)
      bl  WriteStringUART

      //print out "Please enter the size of the number list:"
      ldr	r0,	=sizeNumList
      mov r1, #44
      bl  WriteStringUART

      //get user input
      ldr	r0, =ABuff
      mov	r1, #256
      bl	ReadLineUART


loop:






haltLoop$:
	    b	haltLoop$


.section .data

ABuff:
	.rept	256
	.byte	0
	.endr

//display names
dNames:	.ascii 		"\nMade by Stefan and Iven\r" //25

//ask user for the amount of numbers he wants to input
sizeNumList: .ascii   "\nPlease enter the size of the number list:\n\r" //44


//ask user to enter the xth number
firstNum: .ascii    "\nPlease enter the first number:\n\r" //

secNum: .ascii      "\nPlease enter the second number:\n\r"

thirdNum: .ascii    "\nPlease enter the third number:\n\r"

fourthNum: .ascii    "\nPlease enter the fourth number:\n\r"

fithNum: .ascii    "\nPlease enter the fith number:\n\r"

sixthNum: .ascii    "\nPlease enter the sixth number:\n\r"

seventhNum: .ascii    "\nPlease enter the seventh number:\n\r"

eighthNum: .ascii    "\nPlease enter the eighth number:\n\r"

ninthNum: .ascii    "\nPlease enter the ninth number:\n\r"


//error messeges
error1: .ascii    "\nWrong number format!"

error2: .ascii    "\nInvalid number! The number should be between 0 and 100"

error3: .ascii    "\nInvalid number! The size of number list should be between 1 and 9"

//formatting
form: .ascii      "#############################################################"
