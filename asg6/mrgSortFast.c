#include <stdlib.h>
#include <stdio.h>
#ifdef DEBUG
   #include <stdio.h>
   #include <assert.h>
#endif
#include "word.h"


word_t *mergeChains
(
   unsigned int nL, /* # of nodes in unsorted list lb (left base) */
   unsigned int nR, /* # of nodes in unsorted list rb (Right base) */
   word_t *lb,      /* address of left base node */
   word_t *rb       /* address of right base node */
)
/*
 * Given two sorted lists started by lb & rb.
 * NOTE: In my implementation, input and output lists NULL terminated.
 * RETURNS: base ptr for merged  and sorted list
 */
{

   int l_count=0;           // Counter for left list
   int r_count=0;           // Counter for right list
   word_t *mrg;             // Form new list out of mrg
   word_t *ub;              // Save the base of the list
    
   // The next node could be NULL, we so we only advance based on length of lists  
   if (lb->len <= rb->len)  // Check if left side is less than or equal to right side
   {
      mrg=lb;               // Update list with lowest of the two nodes
      lb=lb->next;          // Move to the next lowest left node
      l_count++;            // Count until we reach the end of a list
   }
   else                     // Check if right side is less then right side 
   {
      mrg=rb;               // Update list with the lowest of the two nodes		
      rb=rb->next;          // Move to the next lowest right node
      r_count++;            // Count until we reach end of a list
   }
    
   // Base of list
   ub=mrg;                  // Save the base of the list to return it
    
    
   // Check if we reached end of left list and wrap things up
   // There could be 2 nodes in right list left
   if (l_count==nL)
   {
      mrg->next=rb;           				
      return ub;
   }
    
   // Check if we reached end of right list and wrap things up
   if (r_count==nR)
   {
      mrg->next=lb;  	    // Tack on the remainder of the left list		
      return ub;
   }
 

   // Check if we ever reach the end of a list
   while (l_count<nL && r_count<nR)
   {
      // lb holds base of sorted list
      // Reorder nodes from least to greatest values and merge the lists
      if (lb->len <= rb->len)   // Check if left side is less than or equal to right side
      {
         mrg->next=lb;          // Update list with lowest of the two nodes
    	 lb=lb->next;           // Update lb to it's next lowest value
    	 l_count++;             // Count until we reach the end of a list
      }
      else                      // Check if right side is less then right side 
      {
         mrg->next=rb;          // Update list with the lowest of the two nodes	
         rb=rb->next;           // Update rb to it's next lowest value
    	 r_count++;             // Count until we reach end of a list
      }
      mrg=mrg->next;    	
   }

   // Cleanup remaining nodes by checking which list reached it's end
   if (l_count==nL)
   {
      mrg->next=rb;             // Attach remaining right list
      return(ub);               // Return merged list
   }
    
   if (r_count==nR)
   {
      mrg->next=lb;	        // Attach remaining right list
      return(ub);               // Return merged list
   }

   return(ub);                  // Return the merged list
}

word_t *mrgSortR     /* RETURNS: base of least-to-greatest ->len sorted list */
(                    /*          using merge sort, so O( N log2(N) )         */
   	unsigned int N,  /* number of nodes in list ub */
   	word_t *ub,      /* base ptr for N nodes, not necessarily NULL-terminated */
   	unsigned int gNxt,
   	unsigned int gI,
   	word_t **UB      /* OUT: *UB set to address of n+1 node, which is unsorted */
)
/*
 * On entry ub is an unsorted list, which will be destroyed to produce sort.
 * NOTE: Input lists may not be NULL terminated, but output lists will be.
 * RETURNS: base ptr of list sorted by ->len.
 */
{
   if (N==1)
   {
      *UB=ub->next;   // Update rub for right function call. Otherwise redundant
      ub->next=NULL;  // Sort list
      return(ub);     // Return sorted list
   }   
   
   else if (N > 1)
   {
   word_t *rub;       // Base of the right list, updated via the left recursion      
   unsigned int nL=N>>1,nR=N-nL;   // Number of nodes in left and right list	

   // Get left and right list	
   ub=mrgSortR(nL,ub,gNxt,gI,&rub);						
   rub=mrgSortR(nR,rub,gNxt,gI,UB);
   											
   ub=mergeChains(nL,nR,ub,rub);							
   return(ub);  /* replace with your implementation. */
   }
   // If N<=0
   //return(NULL);
}

word_t *mrgSort(word_t *basep,unsigned long gNxt, unsigned long gI)
{
    unsigned int N=0; // Number of nodes in the list
    word_t *UB;       // To find # of nodes in list and pass to recursion  

    // Check if list is immediate NULL
    if (basep==NULL)
       return NULL;
    
    	
    // Find number of nodes in list				
    for(UB=basep; UB; UB=UB->next){       
       N++;					
    }
    UB=basep;   // Reset UB to pass to recursion
        
    // Call recursive mrgSort, which will sort the lists
    // We check for N!=1 because that would mean the list is already finished.
    if (N!=1)
       basep=mrgSortR(N,basep,gNxt,gI,&UB);				  
    	
    return(basep);   // Return the base of the organized list
}


