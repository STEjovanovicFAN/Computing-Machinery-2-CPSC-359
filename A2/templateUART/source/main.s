.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
  mov     	sp, #0x8000        // Initializing the stack pointer
	bl		EnableJTAG             // Enable JTAG
	bl		InitUART               // Initialize the UART

	ldr	r0, =Intro	            // Loads the intro message into r0
	mov	r1, #48		              // Allows enough space for the message
	bl	WriteStringUART	        // Prints the message on screen

// This is a prompt for user input
List_Size_Input:
	ldr	r0, =List_Size		      //Loads the address of the prompt into r0
	mov	r1, #46			           // Allows enough space for the prompt
	bl	WriteStringUART		      // Prompts the user

// This will read the user input and save into ABuff
	ldr	r0, =ABuff		         // Loads the address of the buffer into r0
	mov	r1, #256		           // Allows 256 bits of space
	bl	ReadLineUART		      // Reads the user input

	cmp	r0, #1			         // Checks to see if the user input a single digit
	bne	List_Size_Error	    	// If they entered more than one digit, branch to error message
	ldr	r2, =ABuff		     // sets r2 to the pointer of ABuff
	ldrb	r3, [r2]	     	// loads the contents of the first bit of ABuff into r3

  mov  r9, r3             //move user input into register 9
  bl  qCheck              //check if user input is "q" or "Q"

  cmp  r3, #57            //compare if the value is greater then 9
  bgt List_Size_Error     //throw error is value is greater then 9

  cmp  r3, #48            // compare if input is less than 0
  ble List_Size_Error     //throw error if value is less than 0

	sub	r3, #48            //get actual value and store in r3

  mov r4, #0            //loop counter, initalize to 0
  mov r5, #0           //register 5 is our List_Prompt counter

doWhile:                //do while loop
  ldr r0, =List_Prompt  //ask user what xth number to put in
  add  r0, r5           //add with the List_Prompt counter, this is our pointer
  mov  r1, #32          //this is how many characters we will read after pointer
  bl	WriteStringUART    //display message

  ldr  r0, =input       //get user input
  mov  r1, #5           //read  first 4 characters
  bl	ReadLineUART      //store the values

four:
  cmp  r0, #4         //check if length 4
  blt  three          //if not length 4 check next case (three)

  b errorB            //show error message because it is definitely over 100

  b   doWhile         //do over the loop without updating the counter

three:
  cmp  r0, #3       //check if it is length 3
  blt  two          //if not, then branch to the next check (two)

  ldr r6, =input     //load the pointer to input buffer to r6
  ldrb r7, [r6]       //load the contents of the first element of input to r7
  add  r6, #1       //add 1 to the address to get the second element
  ldrb r8, [r6]     //load the contents of the second element of input to r8
  add  r6, #1       //add 1 to the address to get the third element
  ldrb  r9, [r6]    //load the contents the third element of input to r9

  bl  check_first   //check the first number
  bl  check_second  //if it is OK then check the second number
  bl  check_third   //if it is OK then check the third number


  sub   r7, #48      //convert ascii to int - first digit
  sub   r8, #48      //convert ascii to int - second digit
  sub   r9, #48      //convert ascii to int - third digit

  mov   r10, #10    // moves the value 10 into the placement holder (r10)
  mul   r8, r10     // multiplies the second digit by 10 (this will be the second digit)
  mul   r10, r10    // increases the placement holder to the 100's
  mul   r7, r10     // multiples the first digit by 100 (this will be the third digit)
  add   r7, r8      // adds the first two digits together
  add   r7, r9      // adds that result to the remaining digit... now you have the integer in r7

  cmp  r7, #100     // compare the number to 100
  bgt  errorB       // if it is greater than 100, throw error
  b    store_element  // the number must be valid, now store it

two:
  cmp   r0, #2          // is the number length 2?
  blt   one             // if it is less than 2 branch to the next check (one)

  ldr r6, =input        // loads the pointer of input buffer into r6
  ldrb r7, [r6]         // loads the first value of the buffer into r7
  add  r6, #1           // adds 1 to the address
  ldrb r8, [r6]         // loads the second value of the buffer into r8

  bl  check_first       // is the first number valid?
  bl  check_second      // is the second number valid?

  sub   r7, #48      //convert ascii to int
  sub   r8, #48      //convert ascii to int

  mov   r10, #10    // moves the value 10 into the placement holder (r10)
  mul   r7, r10     // multiplies the second digit by 10
  add   r7, r8      // now you have the integer in r7
  b     store_element // the number must be valid, now store it

one:
  cmp   r0, #1      // is the number length 1?
  bne   errorB      // if not, then they didn't type anything... throw error

  ldr   r6, =input    // loads the pointer of input buffer into r6
  ldrb  r7, [r6]      // loads the the first element of input into r7
  mov   r9, r7        // move the value of the input into r7 so we can pass it to qCheck
  bl    qCheck        // did they type 'q' or 'Q'
  bl    check_first   // is the number valid
  sub   r7, #48      //convert ascii to int and now you have the integer in r7

store_element:

  ldr  r10, =An_Array   //loads the pointer of An_Array into r10
  strb  r7, [r10, r4]   //stores the value into the correct spot in the array

  add  r4, #1         //loop counter++;
  cmp  r4, r3         //compare loopcounter with size of array
  add  r5, #32        //update List_Prompt counter by 30, to get the next 30 char message
  blt  doWhile        //end if the loopcounter == size of array

//END OF DO - WHILE LOOP

  mov  r6, #1             // i = 1
insertion_sort:
  cmp  r6, r3             // while i < length of array, do loop
  bge  print_sorted       // if i >= length, we are done sort, go to print
  mov  r7, r6             // if i < length, j = i

inner_while_loop:
  sub  r8, r7, #1             // r8 is going to be j-1
  cmp  r7, #0                  // compares j to 0

  ble end_inner_while_loop    // if j <= 0, then end this inner loop
  ldr  r10, =An_Array         // load the pointer to our array into r10
  ldrb r4, [r10, r7]           // load the jth element into r4
  ldrb r5, [r10, r8]          // load the j-1th element into r5
  cmp  r4, r5                 // is An_Array[j] < An_Array[j-1]
  bge  decrement_j            // if so, they need to be swapped
  strb  r4, [r10, r8]         // swapping the elements
  strb  r5, [r10, r7]          // swapping the elements
decrement_j:
  sub   r7, #1                 // j = j-1
  b inner_while_loop          // branch back to the top of the inner loop

end_inner_while_loop:
  add  r6, #1                  // i = i+1
  b   insertion_sort          // branch back to the top of insertion sort

print_sorted:
  ldr  r0, =Sorted_Message    // loads the address of the message into r0
  mov  r1, #22                // we want to read 22 char's of this
  bl   WriteStringUART        // writes the message on screen

  mov  r4, #0           // r4 is the loop counter at 0
  ldr  r5, =An_Array   // loads the pointer of An_Array into r5
split_element:
  ldrb  r0, [r5, r4]     // loads the element into r0 to use as an arg
  cmp  r0, #100          // compares the number to 100
  beq  else             // if it is 100 then branch to the special else case
  cmp  r0, #10          // otherwise, compare to 10
  blt  elseif           // if it is less than 10, branch to the special elseif case
  bl  mod                // otherwise, we have 2 digits and need to split them up

  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  strb  r8, [r0, #1]          // stores the second ascii value into the second place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #2]         // store a space character in ABuff
  mov   r1, #3                // we want to read the first 2 elements of ABuff
  bl    WriteStringUART       // prints the first two elements to the screen
  add   r4, #1                // increments our loop counter
  cmp   r4, r3                 // compares the loop counter to the length of the array
  blt   split_element           // if it is less than the length, branch back to beginning
  b     print_median
else:
  mov r7, #1                  // moves the number 1 into r7
  mov r8, #0                  // moves the number 0 into r8
  mov r9, #0                  // moves the number 0 into r9
  add r7, #48                 // converts the int to ascii
  add r8, #48                // converts the int to ascii
  add r9, #48                // converts the int to ascii
  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  strb  r8, [r0, #1]          // stores the second ascii value into the second place of ABuff
  strb  r9, [r0, #2]          // stores the third ascii value into the third place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #3]         // store a space character in ABuff
  mov   r1, #4               // we want to read the first 3 elements of ABuff
  bl    WriteStringUART       // prints the first three elements to the screen
  add   r4, #1                // increments our loop counter
  cmp   r4, r3                 // compares the loop counter to the length of the array
  blt   split_element           // if it is less than the length, branch back to beginning
  b     print_median                // otherwise we can move on to the median

elseif:
  mov r7, r0                 // moves the value of the single digit ito r7
  add r7, #48                 // converts the int to ascii
  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #1]         // store a space character in ABuff
  mov   r1, #2                // we want to read the first element of ABuff
  bl    WriteStringUART       // prints the first element to the screen
  add   r4, #1                // increments our loop counter
  cmp   r4, r3                 // compares the loop counter to the length of the array
  blt   split_element           // if it is less than the length, branch back to beginning
  b     print_median                 // otherwise we can move on to the median

print_median:
  ldr  r0, =Median_Message    // loads the address of the message into r0
  mov  r1, #17                // we want to read 22 char's of this
  bl   WriteStringUART        // writes the message on screen


  mov r4, #0          //this will be our quotient
  mov r5, r3          //moving a duplicate value of our length into r4
median:
  sub r5, #2        // r4 = r4 -2
  add r4, #1         // increase the counter by 1
  cmp r5, #0         // did we hit 0?
  bgt  median        // if we are greater than 0, subtract again
  blt  odd          // if we went below zero, length is odd (not divisible by 2)
  beq   even         // if we hit 0, the length is even (divisible by 2)

odd:
  ldr r5, =An_Array   // loads the pointer to the array in r5

                      //*****************************************************
  sub r4, #1          // THIS WAS THE FUCKING BUG IVEN, HOLY SHIT KMS
                      //*****************************************************

  ldrb  r0, [r5, r4]     // loads the element into r0 to use as an arg
  cmp  r0, #100          // compares the number to 100
  beq  else_odd             // if it is 100 then branch to the special else case
  cmp  r0, #10          // otherwise, compare to 10
  blt  elseif_odd           // if it is less than 10, branch to the special elseif case
  bl  mod                // otherwise, we have 2 digits and need to split them up

  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  strb  r8, [r0, #1]          // stores the second ascii value into the second place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #2]         // store a space character in ABuff
  mov   r1, #3                // we want to read the first 2 elements of ABuff
  bl    WriteStringUART       // prints the first two elements to the screen
  b     line                  //print a line and restart the program

else_odd:
  mov r7, #1                  // moves the number 1 into r7
  mov r8, #0                  // moves the number 0 into r8
  mov r9, #0                  // moves the number 0 into r9
  add r7, #48                 // converts the int to ascii
  add r8, #48                // converts the int to ascii
  add r9, #48                // converts the int to ascii
  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  strb  r8, [r0, #1]          // stores the second ascii value into the second place of ABuff
  strb  r9, [r0, #2]          // stores the third ascii value into the third place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #3]         // store a space character in ABuff
  mov   r1, #4               // we want to read the first 3 elements of ABuff
  bl    WriteStringUART       // prints the first three elements to the screen
  b     line                  //print a line and restart the program

elseif_odd:
  mov r7, r0                 // moves the value of the single digit ito r7
  add r7, #48                 // converts the int to ascii
  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #1]         // store a space character in ABuff
  mov   r1, #2                // we want to read the first element of ABuff
  bl    WriteStringUART       // prints the first element to the screen
  b     line                  //print a line and restart the program

even:
  ldr r5, =An_Array   // loads the pointer to the array in r5

  //sub  r4, #1

  ldrb r6, [r5, r4]   // loads one of the middle elements into r6

  add  r4, #1         // increases the offset by 1

  ldrb r7, [r5, r4]   //  loads the second middle element into r7

  add r8, r6, r7      // r8 = r6+r7
  mov r10, r8         // r10 = r8
  mov r9, #0          // r9 is our loop counter/quotient
loopA:
  sub r10, #2        // r10 = r10 -2
  add r9, #1         // increase the counter by 1
  cmp r10, #0         // did we hit 0?
  bgt  loopA        // if we are greater than 0, subtract again
  blt  oddA          // if we went below zero, length is odd (not divisible by 2)
  beq   evenA         // if we hit 0, the length is even (divisible by 2)


oddA:

  mov r7, r9                  // moves the number 1 into r7
  add r7, #48
  mov r8, #46                  // moves the ascii value for '.' into r8
  mov r9, #53                  // moves the number 5
  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  strb  r8, [r0, #1]          // stores the second ascii value into the second place of ABuff
  strb  r9, [r0, #2]          // stores the third ascii value into the third place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #3]         // store a space character in ABuff
  mov   r1, #4               // we want to read the first 3 elements of ABuff
  bl    WriteStringUART       // prints the first three elements to the screen
  b     line                  //print a line and restart the program


evenA:
  mov r7, r9                  // moves the number 1 into r7
  add r7, #48
  ldr r0, =ABuff            // loads the pointer of ABuff into r0
  strb  r7, [r0]        // stores the first ascii value into the first place of ABuff
  mov   r10, #32              // this is the ascii value for space
  strb  r10, [r0, #3]         // store a space character in ABuff
  mov   r1, #4               // we want to read the first 3 elements of ABuff
  bl    WriteStringUART       // prints the first three elements to the screen
  b     line                  //print a line and restart the program

line:
  ldr  r0, =Done_Line         //make line to seperate the different calls
  mov  r1, #45                //lenght 45
  bl   WriteStringUART        //write to screen

  b  List_Size_Input          //restart the program

errorB:
  ldr  r0, =errorA    //load error message
  mov  r1, #69        //read 69 chars of the error message
  bl  WriteStringUART //write to screen

  b doWhile

endLoop:
  b   haltLoop$

mod:
  mov r10, #0       //counter = 0
mod_loop:
  sub r0, r0, #10   //r0 = element - 10
  add r10, #1       //counter ++
  cmp r0, #10        //compare result to 10
  bge mod_loop           //if so, we can subtract 10 again
  mov r7, r10         //the number of times we subtracted 10 becomes one number
  mov r8, r0          //the remainder of the function becomes the other number
  add r7, #48           // converts the int to ascii
  add r8, #48           // converts the int to ascii
  mov  pc,  lr        // go back to the calling code

qCheck:
  cmp  r9, #81      //check if it's "Q"
  beq  haltLoop$    //if it is branch to halt loop to end program

  cmp  r9, #113     //check if it's "q"
  beq  haltLoop$    //if it is branch to halt loop to end program

  mov  pc,  lr      //move to previous code that called this branch

check_first:
  cmp  r7, #48      //compare if r7 is lower then ascii 0
  blt  errorB       // if it is, throw error
  cmp  r7, #57       //compare if r7 is higher then ascii 9
  bgt  errorB       // if it is, throw error
  mov  pc, lr       // branch back to the calling code


check_second:
  cmp  r8, #48      //compare if r8 is lower then ascii 0
  blt  errorB       // if it is, throw error
  cmp  r8, #57       //compare if r8 is higher then ascii 9
  bgt  errorB       // if it is, throw error
  mov  pc, lr      // branch back to the calling code

  //check third plaement
check_third:
  cmp  r9, #48      //compare if r9 is lower then ascii 0
  blt  errorB      // if it is, throw error
  cmp  r9, #57       //compare if r9 is higher then ascii 9
  bgt  errorB      // if it is, throw error
  mov  pc, lr      // branch back to the calling code

// This loop halts the program
haltLoop$:
  ldr  r0, =Exit_Message      //print exit message
  mov  r1, #18                //message is 18 chars, so read the next 18 chars
  bl   WriteStringUART        //call Uart write to display the message to screen
End_Program_Loop:             //go in an infinte
	b	End_Program_Loop


// This is the label to print the list size error message
List_Size_Error:
	ldr	r0, =List_Size_Error_Message	// Loads the address of the error message into r0
	mov	r1, #70				// Allows enough space for the error message
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

// this buffer takes in the element input
input:
  .rept 5
  .byte 0
  .endr
.align 4
An_Array:
	.byte	0,0,0,0,0,0,0,0,0,0

Intro:
	.ascii	"\n\rCreated by: Ivan Ristanen and Stefan Jovanovic" //48

List_Size:
	.ascii	"\n\rPlease enter the size of the number list:"      //43
	.ascii	"\n\r>"                                             //3

List_Size_Error_Message:
	.ascii	"\n\rError. Your input is invalid. Input should be a int value from 1-9.\n"   //70

errorA:
  .ascii  "\n\rError. Input is invalid. Input should be an integer between 0-100."//69

List_Prompt:
	.ascii "\n\rPlease enter first number:  \n\r"
  .ascii "\n\rPlease enter second number: \n\r"
  .ascii "\n\rPlease enter third number:  \n\r"
  .ascii "\n\rPlease enter fourth number: \n\r"
  .ascii "\n\rPlease enter fifth number:  \n\r"
  .ascii "\n\rPlease enter sixth number:  \n\r"
  .ascii "\n\rPlease enter seventh number:\n\r"
  .ascii "\n\rPlease enter eighth number: \n\r"
  .ascii "\n\rPlease enter ninth number:  \n\r"

Sorted_Message:
  .ascii "\n\rThe sorted list is: "   // length of this string is 22

Median_Message:
  .ascii "\n\rThe median is: "        // length of this string is 17

Exit_Message:
  .ascii "\n\rExiting program."       //length is 18

Done_Line:
  .ascii  "\n\r###########################################"   //45
