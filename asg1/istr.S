#define i1  r0
#define i2  r1
#define i3  r2
#define pi4 r3
#define i4  r12    // Scratch Register (used for many things)
#define c1  r4     // Stores constants
#define alp r2    
/*
  * r0           r0     r1     r2      r3       SP   
  * int istr(int i1,int i2,int i3,int *i4, char *alp);
  * *i4 = 5*(*i4)+i3;
  * char *alph = "abcdefghijklmnopqrstuvwxyz"
  * return i1 + i2;
  *
  *
*/
.text
.arm
.global istr
istr:

   sub SP, SP, #4       // Make space for *alp
   ldr i4, [pi4]        // Get value from *i4
   mov c1, #5           // Use c1 to multiply by 5 later
   mla i4, i4, c1, i3   // Perform 5*(*i4)+i3 but not saved in *i4
   str i4, [pi4]        // Save above operation in *i4 (r12 is free)

   mov c1, #'a'         // Save start of alphabet to c1  
   mov pi4, #'z'        // Save end of alphabet, reuse r3
   ldr alp, [SP,#4]     // Get the pointer to alp, reuse r2 
      
loop:
   strb c1, [alp], #1   // Store current letter in alp[] and inc
   cmp c1, pi4          // Check if we've reached z
   add c1, #1           // Go up a letter a->b->c->...z
   bne loop		// loop until z is seen	

   mov c1, #0           // Store string terminator!!!! 
   strb c1, [alp]       // Finally, store string terminator

   add SP, SP, #4       // Give space back to stack
   add i1, i1, i2       // return i1 + i2
   bx lr                // return back to caller @ tester.c


