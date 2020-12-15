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
 * C code was modified to look more like assembly 
 ***************************************************
 *  r0          r0      r1
 * int irsum(int N, int *X)
 *
 *    int nL = N>>1;       // # of elements in left side of list
 *    int *last_R=X+N-1;   // Last element in right list to add
 *    int nR = N-nL;       // # of elements in right side of list
 *
 *    // Don't return anything if no elements
 *    if (nR<=0)
 *       return 0;    
 *    
 *    // Elements remain if we made it this far
 *    int sum = irsum(nR-1,X+nL) + *(last_R);
 *
 *    last_L=X+nL-1;       // Last element in left list to add
 *    if (nL>=1)           
 *       sum = sum + irsum(nL-1,X) + *(last_L);
 *
 *    return sum;
 * *************************************************
 *
 */   
   
.text
.arm
.globl irsum
irsum:
   // # of elements in left list  
   mov nL,N,LSR #1  // int nL=N/2

   // int lastR=X+N-1: Last element in right list
   add LastR,X,N,LSL #2  // X+N
   sub LastR,#4          // (X+N)-1

   // # of elements in right list
   subs nR,N,nL     // int nR=N-nL

   // If no more elements, return 0
   bLE ZERO         // if nR<=0 {return 0};
   
   // Save current frame to stack to begin recursion
   // X:SP, nL:+4, lastR:+8, sum:+12, LR:+16 <- register indices on stack 
   stmDB SP!,{r1-r3,r12,LR} // Save for return   
   
   // Setup arguments for right recursion
   sub N,nR,#1       // nR-1
   add X,nL,LSL #2   // X+nL  

   // int sum=irsum(nR-1,X+nL) + *(lastR)
   bl irsum          // Call right recursion

   // Restore variables we need for current frame   
   ldr LastR,[SP,#8] // Restore pointer to last element in right list
   ldr nL,[SP,#4]    // Restore nL
   ldr X,[SP]        // Restore X

   // Update sum since we've returned 
   // sum = return value + last element
   ldr LastE,[LastR] // Get last element of right list
   add sum,r0,LastE  // sum = Return value + last element

   // int *lastL=X+nL-1: Last element in left list
   add LastL,X,nL,LSL #2  // X+nL
   sub LastL,#4           // (X+nL)-1 

   // Save sum and lastL to stack frame to return from left recursion
   str sum,[SP,#12]  // r12 (sum) may be overwritten, so need to save it
   str LastL,[SP,#8] // r3 (lastL) will be overwritten, so need to save it
   
   // if(nL>=1) Setup arguments and call left recursion
   // else return sum
   cmp nL,#1         // Check if there are any left elements
   bLT SUM           // Return sum if no elements in left list      
   sub N,nL,#1       // nL-1 for irsum(nL-1)

   // sum = sum + irsum(nL-1,X) + *(lastL);
   bl irsum          // Call left recursion

   // Restore some variables to calculate left recursion sum   
   ldr sum,[SP,#12]  // Restore sum from right recursion
   ldr LastL,[SP,#8] // Restore pointer to last element of left list   
   
   // sum = sum + return value + last element
   ldr LastE,[LastL] // Get last element of left list   
   add r0,r0,LastE   // return value + last element
   add sum,sum,r0    // sum = sum + (return value + last element)

// Return sum to caller and restoring stack frame
SUM:
   // Return the sum
   mov r0,sum        // return sum;

   // Restore the stack frame to return to caller
   ldmIA SP!,{r1-r3,r12,LR}  // Restore X,nL,last(R/L),&LR 

   bx LR             // Return to caller
   
// Return 0, since we've finished recursion by this point 
ZERO:
   mov r0,#0         // Return 0
   bx LR             // Return to caller




