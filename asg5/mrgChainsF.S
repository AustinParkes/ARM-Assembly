#define lb    r0   // *lb
#define rb    r1   // *rb
#define gNxt  r2   // gNxt
#define gI    r3   // gI
#define lint  r4   // Left node integer to compare
#define rint  r5   // Right node integer to compare
#define mrg   r6   // Merge nodes into new list    

/*
 * Function written in ARMv7 ARM assembly only
 *
 *              r0       r0        r1         r2       r3
 * void *mrgChains(void *lb, void *rb, uint gNxt, uint gI);
 * Order from least to greatest
 * Returns: base of merged sort-order list, assuming lb&rb sorted
 * Assumes: Input list has atleast 1 node, and are NULL terminated
 * *lb: Start of left list which is NULL  terminated 
 * *rb: Start of right list which is NULL terminated
 * gNxt: Offset to next node
 * gI: Offset to integer
 */

.text
.arm
.globl mrgChains
mrgChains:
      
   stmDB SP!,{r4-r6}      // Save callee saved registers 
        
   // Peel a loop and check for NULL
   ldr lint,[lb,gI]       // Get left node integer
   ldr rint,[rb,gI]       // Get right node integer      
   cmp lint,rint          // Check which integer is less
   bGT right1             // Right node holds the lower value 
   // Left node held lower value  
   mov mrg,lb             // Update list with next lowest value (lint)
   ldr lb,[lb,gNxt]       // Move to next higher node in left list
   str mrg,[SP,#-4]!      // Store first node on stack, to save a register
   cmp lb,#0              // Check if left side reached NULL
   bEQ EXIT               // Exit if we reached end a list
   bAL MERGE              // Loop to continue traversing lists
   // Right node held lower value
right1:
   mov mrg,rb             // Update list with next lowest value (rint)   
   ldr rb,[rb,gNxt]       // Move to next higher node in right list    
   str mrg,[SP,#-4]!      // Store first node on stack, to save a register  
   cmp rb,#0              // Check if right==NULL, if left isn't
   bEQ EXIT               // Wrap up anything extra
 
   // Order nodes from least to greatest integer values and merge
   MERGE:
      // Setup the integers to find which node holds the lowest  
      ldr lint,[lb,gI]    // Get left node integer
      ldr rint,[rb,gI]    // Get right node integer
      // Find node with lowest integer and add it to the new list (mrg)
      cmp lint,rint       // Check which integer is less
      bGT right2          // Right node holds the lower value
      str lb,[mrg,gNxt]   // Update list with the next lowest value (lint)
      ldr lb,[lb,gNxt]    // Move to higher node in left list
      ldr mrg,[mrg,gNxt]  // Advamce to next node to attach next lowest node
      cmp lb,#0           // Check if left list is NULL
      bNE MERGE           // Loop again unless we reached end of a list
      bAL EXIT            // Exit if we reached the end of a list
      // Right node held lower value
right2:
      str rb,[mrg,gNxt] // Update list with the next lowest value (rint)    
      ldr rb,[rb,gNxt]  // Move to higher node in right list
      // Advance the merged lists
      ldr mrg,[mrg,gNxt]  // Advance to next node to attach next lowest node
      
      cmp rb,#0         // Check if right list is NULL
      bNE MERGE           // Loop again unless we reached end of a list

EXIT:   
   // Either lb or rb are 0
   // Whichever isn't 0, we add to the end of list   
   add lb,rb            // Get the non-zero of the two 
   str lb,[mrg,gNxt]    // Store the final node
   ldr r0,[SP],#4       // Get the first node in the list to return it     
   ldmIA SP!,{r4-r6}    // Restore callee saved registers
   
   bx lr                // Return to caller
