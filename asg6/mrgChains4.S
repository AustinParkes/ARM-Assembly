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
.thumb
.globl mrgChains
.syntax unified
mrgChains:

   sub SP,SP,#12          // Make room on stack   
   str r4,[SP,#8]         // Save r4
   str r5,[SP,#4]         // Save r5
   str r6,[SP]            // Save r6

   // Peel a loop and check for NULL
   ldr lint,[lb,gI]       // Get left node integer
   ldr rint,[rb,gI]       // Get right node integer      
   cmp lint,rint          // Check which integer is less
   bGT right1             // Right node holds the lower value 
   // Left node held lower value  
   movs mrg,lb            // Update list with next lowest value (lint)
   ldr lb,[lb,gNxt]       // Move to next higher node in left list
   sub SP,SP,#4           // Make room on stack for base pointer
   str mrg,[SP]           // Store first node on stack, to save a register
   cmp lb,#0              // Check if left side reached NULL
   bEQ EXIT               // Exit if we reached end a list
   bAL MERGE              // Loop to continue traversing lists
   // Right node held lower value
right1:
   movs mrg,rb            // Update list with next lowest value (rint)   
   ldr rb,[rb,gNxt]       // Move to next higher node in right list    
   sub SP,SP,#4           // Make room on stack
   str mrg,[SP]           // Store first node on stack, to save a register  
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
   adds lb,rb           // Get the non-zero of the two 
   str lb,[mrg,gNxt]    // Store the final node
   ldr r0,[SP]          // Get the first node in the list to return it
   add SP,SP,#4         // Restore stack for where base pointer was located    
   ldr r6,[SP]          // Restore r6
   ldr r5,[SP,#4]       // Restore r5
   ldr r4,[SP,#8]       // Restore r4
   add SP,SP,#12        // Restore stack
   bx lr                // Return to caller
   
   
Rough MI/ME definition as a refresher:
   Model Instantiation/Model Extraction:  Aims to find processor peripheral registers that are 
   'unmodeled' by identifying their memory map addresses and types. Multiple rounds of model
   instantiation may be invoked to completely extract the model. 
   
What I've learned:
1. Model Instantiation/Extraction:
      Two weeks ago I was confused as to why there was only 1 round of model instantiation invoked  (round 0). In short, it turns out that the model is completely extracted for this firmware in the first
      round! When P2IM is ran, it starts by trying to extract the model without fuzzing (with no aflFile seed input). Instead of using seed input to fill data registers, P2IM just uses the value '0' to see 
      how far it can get. Apparantly this is good enough to fully extract the model. I know this because after attempting to exctract the model with no input, P2IM ALWAYS tries to extract more of the model 
      by fuzzing. This is where the new rounds of model instantation would be created, but they are not because the first seed input for this firmware fails to find ANY NEW accesses to unmodeled
      peripherals. This means all the peripherals accessed when fuzzing, were already modeled in the first attempt at model exctraction. In short, the fuzzing session of model extraction compares all
      peripheral accesses to a file 'peripheral_model.json' which stores all previously modeled registers. If there are no new peripheral accesses for a while, model extraction stops.
      
      Here is an image of the terminal output for what i just explained:
   
   
   
   
   

