.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
    mov     sp, #0x8000

	bl		EnableJTAG

	bl		InitFrameBuffer

  //make the screen all blue
  bl    Init_Screen





haltLoop$:
	b		haltLoop$


//initalize the screen to be 1 colour
Init_Screen:
  push {lr}
  //initalize the values of x and y
  mov		r0, #0                 //x
  mov		r1, #0                 //y
  ldr   r3, =Title_Screen      //get txt file

  Outer_Loop:
    cmp r1, #768               //comapre y with max amount for y axis
    beq END

    Inner_Loop:
        ldrh  r2, [r3]

        bl  DrawPixel         //draw pixel at x y coodinates

        add r0, #1            //x++
        add  r3, #2           //shift r3 by 2

        cmp r0,  #1024         //see if our x value is equal to the max amount for x values
        blt Inner_Loop         //branch if less than 1024

        mov  r0, #0            //reset x
        add  r1, #1            //y++
        b Outer_Loop


  END:
      pop {pc}



/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
DrawPixel:
	push	{r0, r1, r2, r3, r4}

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r0, r1, r2, r3, r4}
	bx		lr


.section .data

Title_Screen:
  .include "Title_Screen"
