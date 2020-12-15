#define bp   r0  // Current node pointer
#define mP   r1  // minPrev 
#define nxt  r2  // Offset to pointer of next node
#define igp  r3  // Offset to integer we are minimizing
#define pmin r4  // Node which stores minimum integer 
#define imin r5  // Minimum integer
#define int  r6  // Current integer to compare with min int
#define fn   r7  // First node to check against minimum node
#define nP   r12 // Previous node, keep track of this to update minPrev

/*
 *                   r0       r0             r1
 * void *findIntMinNode(void *bp, void *minPrev,
 *                                         r2                  r3
 *                      unsigned long nextgap, unsigned long igap)
 * 
 * - bp is base pointer
 * - minPrev is node previous to minimum node
 * - nextgap is offset to pointer to following node in list 
 * - igap is offset to integer we are minimizing
*/


.text 
.arm
.globl findIntMinNode
findIntMinNode:
   cmp bp,#0             // Check if bp is NULL
   bEQ NULL              // Return NULL and search for other NULL conditions
   
   stmDB SP!, {r4-r7}    // Save callee saved registers for caller   
   mov fn,bp             // Save the first node to compare against minimum node
   mov nP,bp             // nP is thr previous node always trailing the current
   ldr int,[bp,igp]      // Get integer of current node
   mov imin,int          // The first int is also our first minimum
   mov pmin,bp           // Update minimum node
   ldr bp,[bp,nxt]       // Go to next node
   cmp bp,#0             // Check if new node is NULL
   strEQ bp,[mP]         // Set minPrev to NULL if there is only 1 node
   bEQ exit              // Exit if there is only 1 node
   
   FIND_MIN: // Traverse list, find min integer,min node, and node prev to min
      ldr int,[bp,igp]   // Get integer of current node
      cmp imin,int       // Check if int is lower than current minimum
      movHI imin,int     // If imin is greater, than replace it with int
      movHI pmin,bp      // Update the minimum node if we find new min int
      cmpHI mP,#0        // Check if mP is NULL so we don't store to a NULL
      strHI nP,[mP]      // As long as mP>0 and imin>int, we update prev node
      ldr bp,[bp,nxt]    // Go to next node
      ldr nP,[nP,nxt]    // Keep track of previous node to update minPrev       
      cmp bp,#0          // Check if bp is NULL
      bNE FIND_MIN       // Traverse list if bp is not NULL  
   
exit:
   cmp pmin,fn           // Check if min Node is the first node
   movEQ int,#0          // Reuse int to store NULL
   strEQ int,[mP]        // Store NULL in minPrev if first node is min node
   mov r0,pmin           // Return node with lowest integer 
   ldmIA SP!, {r4-r7}    // Restore callee saved registers for caller 
   bx LR                 // Return to caller
   
NULL:                    // Return NULL and search for other NULL conditions
   cmp mP,#0             // Check if minPrev is already NULL
   strNE bp,[mP]         // If minPrev isn't NULL, then make it's contents NULL    
   bx LR                 // Return to caller
   
   

