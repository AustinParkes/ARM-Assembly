#define lb    r0   // *lb
#define rb    r1   // *rb
#define gNxt  r2   // gNxt
#define gI    r3   // gI
#define lint  r4   // Left node integer to compare
#define rint  r5   // Right node integer to compare
#define mrg   r6   // Merge nodes into new list    

// Define the frame size
#define FSZ 4*3    // 4 bytes x 3 reg 

/*
 * Function written in ARMv7 Thumb assembly only
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
.thumb
.globl mrgChains
.syntax unified
mrgChains:
   // Thumb doesn't support stmDB, so decrement manually and save registers
   sub SP,#FSZ            // Make room to save callee saved registers     
   str r4, [SP]           // Save r4 
   str r5, [SP,#4]        // Save r5
   str r6, [SP,#8]        // Save r6
            
   // Peel a loop and check for NULL
   ldr lint,[lb,gI]       // Get left node integer
   ldr rint,[rb,gI]       // Get right node integer   
   
   // Adapt the if then to ARMv7 Thumb   
   cmp lint,rint          // Check which integer is less 
      ITTEE LE            // If lint<=rint then 2LEs else 2GTs  
      movLE mrg,lb        // Update list with next lowest value (lint)
      ldrLE lb,[lb,gNxt]  // Move to next higher node in left list
      movGT mrg,rb        // Update list with next lowest value (rint)   
      ldrGT rb,[rb,gNxt]  // Move to next higher node in right list
    
   // mrg holds the first node in list
   sub SP,#4              // Make room to save first node to stack
   str mrg,[SP]           // Store first node on stack, to save a register

      // Check if either list reached NULL
      // Use the same compare from before with next IT block
      ITE LE              // If lint<=rint then 1LE else 1GT 
      cmpLE lb,#0         // Check if left==NULL first
      cmpGT rb,#0         // Check if right==NULL, if left isn't
   bEQ EXIT               // Wrap up anything extra
 
   // Order nodes from least to greatest integer values and merge
   MERGE:
      // Setup the integers to find which node holds the lowest  
      ldr lint,[lb,gI]    // Get left node integer
      ldr rint,[rb,gI]    // Get right node integer

      // Find node with lowest integer and add it to the new list (mrg)
      cmp lint,rint          // Check which integer is less
         ITTEE LE            // If lint<=rint do 2LE else 2GT
         strLE lb,[mrg,gNxt] // Update list with the next lowest value (lint)
         ldrLE lb,[lb,gNxt]  // Move to higher node in left list
         strGT rb,[mrg,gNxt] // Update list with the next lowest value (rint)    
         ldrGT rb,[rb,gNxt]  // Move to higher node in right list

      // Advance the merged lists
      ldr mrg,[mrg,gNxt]     // Advance to next node to attach next lowest node
         
         // Use last compare to make a new IT block          
         ITE LE              // If lint<=rint do 1LE else 1GT
         cmpLE lb,#0         // Check if left list is NULL
         cmpGT rb,#0         // Check if right list is NULL

      bNE MERGE           // Loop again unless we reached end of a list

EXIT:   
   // Either lb or rb are 0
   // Whichever isn't 0, we add to the end of list   
   add lb,rb            // Get the non-zero of the two 
   str lb,[mrg,gNxt]    // Store the final node
   ldr r0,[SP]          // Get the first node in the list to return it   
   add SP,#4            // Restore stack  
   // thumb is limited to increment after addressing 
   ldmIA SP!,{r4-r6}    // Restore callee saved registers  
   bx lr                // Return to caller

