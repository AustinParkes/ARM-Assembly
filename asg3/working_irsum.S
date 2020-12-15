#define  N     r0   // Number of elements
#define  nR    r0   // Number of elements in right list 
#define  X     r1   // Points to elements in the array
#define  nL    r2   // # of elements on left side of array

// Pointers to last element of list
#define  LastR r3   // Point to last element in right list
#define  LastL r3   // Point to last element in left list

// Store the last element of either list
#define  LastE r3   // Last element in list

#define  sum   r12  // Accumulator to sum up elements in the array

/* 
 ***************************************************
 *  r0          r0      r1
 * int irsum(int N, int *X)
 *
 *    int nL = N>>1;       // # of elements in left side of list
 *    int *last_E=X+N-1;   // Last element in right list to add
 *    N = N-nL;            // # of elements in right side of list
 *
 *    // Don't return anything if no elements
 *    if (N<=0)
 *       return 0;    
 *    
 *    // Elements remain if we made it this far
 *    int sum = irsum(N-1,X+nL) + *(last_E);
 *
 *    last_E=X+nL-1;       // Last element in left list to add
 *    if (nL>=1)           
 *       sum = sum + irsum(nL-1,X) + *(last_E);
 *
 *    return sum;
 * *************************************************
 * nR: nR replaces N for # of right elements in assembly code
 * last_E: Replaced interchangeably by lastR and lastL
 *
 */   
   
.text
.arm
.globl irsum
irsum:
   // # of elements in left list  
   mov nL,N,LSR #1   // int nL=N/2

   // int lastR=X+N-1: Last element in right list
   add LastR,X,N     // First half of operation
   sub LastR,#1      // Second half of operation

   // # of elements in right list
   subs nR,N,nL      // int nR=N-nL

   // if nR<=0 {return 0};
   bLE ZERO          // Return to caller if no more elements
   
   // Save current frame to stack to begin recursion
   // We only save r12 (sum) to make a storage place for it later
   // +16,+12,+8,+4,SP <- register indices on stack 
   stmDB SP!,{r1-r3,r12,LR} // Save X,nL,last(R/L),&LR for return   
   
   // Setup arguments for right recursion
   sub N,nR,#1       // nR-1
   add X,nL          // X+nL  

   // int sum=irsum(nR-1,X+nL) + *(lastR)
   bl irsum          // Call right recursion

   // Restore some variables for current frame   
   ldr LastR,[SP]    // Restore pointer to last element in right list
   ldr nL,[SP,#12]   // Restore nL
   ldr X,[SP,#16]    // Restore X

   // Update sum since we've returned
   // sum = return value + last element
   ldr LastE,[LastR] // Get last element of right list
   add sum,r0,LastE  // sum = Return value + last element

   // int *lastL=X+nL-1: Last element in left list
   add LastL,X,nL    // First half of operation 
   sub LastL,#1      // Second half of operation

   // Save sum and lastL to stack frame to return from left recursion
   str sum,[SP,#4]   // r12 (sum) may be overwritten, so need to save it
   str LastL,[SP,#8] // r3 (lastL) will be overwritten, so need to save it
   
   // if(nL>=1) Setup arguments and call left recursion
   cmp nL,#1         // Check if there are any left elements     
   subGE N,nL,#1     // nL-1 for irsum(nL-1)
   // sum = sum + irsum(nL-1,X) + *(lastL);
   blGE irsum        // Call left recursion

   // Restore some variables to calculate left recursion sum   
   ldr sum,[SP,#4]   // Restore sum from right recursion
   ldr LastL,[SP,#8] // Restore pointer to last element of left list   
   
   // sum = sum + return value + last element
   ldr LastE,[LastL] // Get last element of left list   
   add r0,r0,LastE   // return value + last element
   add sum,sum,r0    // sum = sum + (return value + last element)

   // Restore the stack frame to return to caller
   ldmIA SP!,{r1-r3,r12,LR}  // Restore X,nL,last(R/L),&LR 

   // Return the sum
   mov r0,sum        // return sum;
   bx LR             // Return to caller
   
// Return 0, since we've finished recursion by this point 
ZERO:
   mov r0,#0         // Return 0
   bx LR             // Return to caller

