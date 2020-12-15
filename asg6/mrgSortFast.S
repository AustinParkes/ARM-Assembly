#define basep r0   // Base node. Pointers to first node in list
#define lub   r0   // Left base pointer in recursion
#define nL    r0   // # of nodes in left list, to get # of nodes in right list
#define gNxt  r1   // Number of bytes from start of struct to next node ptr
#define gI    r2   // Number of bytes from start of struct to integer
#define LR_a  r3   // Alias for link register, to use as lo register
#define pb    r4   // Used to find number of nodes
#define rub   r4   // Right base pointer in recursion
#define rb    r5   // Used in place of rub, to preserve rub's contents
#define zero  r6   // Register which always stores 0
#define N     r7   // # of nodes in the list

/*              r0            r0                  r1                r2
 * word_t *mrgSort(word_t *basep, unsigned long gNxt, unsigned long gI)
*/
.text
.thumb
.local mrgSortR, EXIT, NULL
.globl mrgSort, mrgChains
.syntax unified
mrgSort:
   // Check for early NULL
   cmp basep,#0          // If basep==NULL
   bEQ NULL              // Return NULL
   
   // Save return to main and callee saved registers
   mov LR_a,LR           // Use alias to store LR
   sub SP,SP,#24         // Make room for r3-r7
   str LR_a,[SP,#16]     // Save return to main
   str r4,[SP,#12]       // Save r4
   str r5,[SP,#8]        // Save r5   
   str r6,[SP,#4]        // Save r6
   str r7,[SP]           // Save r7

   // Find number of nodes in the list
   movs N,#0             // Initialize N to count from 0
   movs pb,basep         // Start counting at the base node
   CNT_NODES:            // Loop: Count the number of nodes in the list
      adds N,N,#1        // N++ since we made it to the next node
      ldr pb,[pb,gNxt]   // Move to next node and count it if not NULL
      cmp pb,#0          // Check if we reached end of list
      bNE CNT_NODES      // Count nodes unless we reach NULL
   // r0 is now being used by lub (left base pointer)
   // r4 is now being used by rub (right base pointer)
  
   // If N=1, list is already organized.
   cmp N,#1              // Check if N=1
   bEQ EXIT              // Return(basep)
   
   movs zero,#0          // Zero register for recursion 
   // Call recursive 'mrgSortR'
   bL mrgSortR           // Call mrgSortR. Save return

// Exit here if list is organized
EXIT:
   ldr r7,[SP]           // Restore r7
   ldr r6,[SP,#4]        // Restore r6
   ldr r5,[SP,#8]        // Restore r5
   ldr r4,[SP,#12]       // Restore r4
   ldr LR_a,[SP,#16]     // Restore return to main
   add SP,SP,#24         // Restore Stack

   mov LR,LR_a           // Restore link register
   bx lr                 // Return to main
   
// Exit here if list has no nodes
NULL:   
   bx lr   // Return to caller

/*****************************************************************************
 *Begin mrgSortR
*****************************************************************************/
 
/* 
 * word_t *mrgSortR
 * (
 *    unsigned int N,     r7
 *    void *ub,           r0 
 *    unsigned int gNxt,  r1
 *    unsigned int gI,    r2
 *    void *UB            
 * )
*/

mrgSortR:
    
   // If N==1, Sort list
   cmp N,#1              // If N==1
   bNE BODY              // If N>1
   ldr rub,[lub,gNxt]    // Update right base pointer for right list
   str  zero,[lub,gNxt]  // Sort list lub->next = NULL
// Need to Save our function returns so we return to the correct spot
   bx lr
    
BODY:   
   mov LR_a,LR           // Use alias to store LR           
   // Save current stack frame before recursion
   sub SP,SP,#16         // Make room on stack
   str LR_a,[SP,#8]      // Save return of last call
   str lub,[SP,#4]       // Save lub as base pointer argument
   str N,[SP]            // Save N before we modify it
   
   lsrs N,N,#1           // Get # of left nodes
   
   // lub = mrgSortR(nL,lub,&rub)
   bL mrgSortR           // Left mrgSortR
   ldr N,[SP]            // Restore N to get # of nodes in right list
   str lub,[SP,#4]       // lub=mrgSortR. Update current frame with new lub
   // Get # of left nodes to get # of right nodes
   lsrs nL,N,#1          // # of left nodes
   subs N,N,nL           // nR = N-nL. # of right nodes      
   // rub = mrgSortR(nR,rub,basep)     
   movs lub,rub          // lub is base pointer for right list
   bL mrgSortR           // Right mrgSortR
   
   // use rb below to pass to mrgChains, to preserve contents of rub
   movs rb,lub           // rub = mrgSortR to pass to mrgChains
   ldr lub,[SP,#4]       // lub = mrgSortR to pass to mrgChains
       
   // Save registers in mrgSort to enter mrgChains
   sub SP,SP,#12         // Make room to save arguments to mrgChains
   str r1,[SP,#8]        // Save gNxt
   str r2,[SP,#4]        // Save gI
   str r3,[SP]           // Save LR_a

   // Setup registers for mrgChains arguments
   // r4-r7 saved by mrgChains. Don't save r0 since mrgChains returns it
   // mrgChains(lb,rb,gNxt,gI)
   // lb (lub) is already set up
   movs r1,rb            // Store rb as argument
   ldr  r2,[SP,#8]       // Store gNxt as argument 
   ldr  r3,[SP,#4]       // Store gI as argument
   
   // lub=mrgChains. 
   bL mrgChains          // Organize sorted nodes
   
   // Restore registers since mrgChains was called  
   // r4-r7 restored by mrgChains
   ldr r3,[SP]           // Restore LR_a
   ldr r2,[SP,#4]        // Restore gI
   ldr r1,[SP,#8]        // Restore gNxt
   add SP,SP,#12         // Restore stack

   // Restore the last mrgSortR stack frame
   // Don't restore lub since it's the return
   ldr N,[SP]            // Restore N from last call
   ldr LR_a,[SP,#8]      // Restore return address    
   add SP,SP,#16         // Restore stack frame
   
   // Again, LR is hi reg and LR_a is lo reg, so we use LR_a for 'ldr'/'str' 
   mov LR,LR_a           // Return to last mrgSort frame
   bx lr // Return(lub) to mrgSort

