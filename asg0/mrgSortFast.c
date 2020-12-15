#include <stdlib.h>
#include <stdio.h>
#ifdef DEBUG
   #include <stdio.h>
   #include <assert.h>
#endif
#include "word.h"


word_t *mergeLists
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

    //nL=1
    //nR=1
    //lb=node1
    //rb=node2
    int l_count=0;            // Counter for left list
    int r_count=0;            // Counter for right list
    word_t *mrg;              // Form new list out of mrg
    word_t *ub;               // Save the base of the list
    
    // The next node could be NULL, we so we only advance based on length of lists  
    if (lb->len <= rb->len)   // Check if left side is less than or equal to right side
    {
    	mrg=lb;               // Update list with lowest of the two nodes
    	lb=lb->next;          // Move to the next lowest left node
    	l_count++;            // Count until we reach the end of a list
    }
    else                      // Check if right side is less then right side 
    {
		mrg=rb;               // Update list with the lowest of the two nodes		
		rb=rb->next;          // Move to the next lowest right node
    	r_count++;            // Count until we reach end of a list
    }
    
    // Base of list
    ub=mrg;                   // Save the base of the list to return it
    
    
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
		mrg->next=lb;  		// Tack on the remainder of the left list		
		return ub;
    }
 

    // Check if we ever reach the end of a list
    while (l_count<nL && r_count<nR)
    {
    	// lb holds base of sorted list
    	// Reorder nodes from least to greatest values and merge the lists
    	if (lb->len <= rb->len)   // Check if left side is less than or equal to right side
    	{
    	    mrg->next=lb;         // Update list with lowest of the two nodes
    	    
			lb=lb->next;          // Update lb to it's next lowest value
    		l_count++;            // Count until we reach the end of a list
    	}
    	else                      // Check if right side is less then right side 
    	{
			mrg->next=rb;         // Update list with the lowest of the two nodes
						
			rb=rb->next;          // Update rb to it's next lowest value
    		r_count++;            // Count until we reach end of a list
    	}
    	mrg=mrg->next;
    	
    }

    // Cleanup remaining nodes
    // Check for the end of either list
    
    // If left side reached end first
    if (l_count==nL)
    {
    	mrg->next=rb;			  // Attach remaining right list
    	return(ub);               // Return merged list
    }
    
    if (r_count==nR)
    {
    	mrg->next=lb;			  // Attach remaining right list
    	return(ub);               // Return merged list
    }

   	return(ub);  				  // Return the merged list
}

word_t *mrgSort     /* RETURNS: base of least-to-greatest ->len sorted list */
(                   /*          using merge sort, so O( N log2(N) )         */
   	unsigned int N,  /* number of nodes in list ub */
   	word_t *ub,      /* base ptr for N nodes, not necessarily NULL-terminated */
   	word_t **UB      /* OUT: *UB set to address of n+1 node, which is unsorted */
)
/*
 * On entry ub is an unsorted list, which will be destroyed to produce sort.
 * NOTE: Input lists may not be NULL terminated, but output lists will be.
 * RETURNS: base ptr of list sorted by ->len.
 */
{

	word_t *rub;				// Base pointer to right half of nodes
	word_t **LB;				// Store left half of addresses to node addresses
	word_t **RB;				// Store right half of addresses to node addresses	
    // Used to insert NULL in middle of list
    word_t *al_lb;              // Node for inserting NULL	
	word_t **al_LB;             // Alias for LB to insert NULL terminator

	// Get number of nodes in left and right list
	unsigned int nL=N>>1,nR=N-nL;	
	// Get left and right list
	LB=UB;						// Left list
	ub=*UB;                     // Base of left list	
	RB=UB+(nL);				    // Right list
	rub=*RB;					// Base of right list	
	
	// Insert NULL in left list to separate the lists
	if (nL!=0)
	{
		al_LB=LB+(nL-1);        // Get end of left list	
		al_lb=*al_LB;           // Get the last node
		al_lb->next=NULL;       // Insert NULL after last node to separate lists
	}
	
	if (nL!=1)	
		ub=mrgSort(nL, ub, LB);
	if (nR!=1)								
		rub=mrgSort(nR, rub, RB);
											
	ub = mergeLists(nL,nR,ub,rub);							
   	return(ub);  /* replace with your implementation. */
}

word_t *mrgSortFast(word_t *ub) /* required ABI, wraps recursive mrgSort */
/* 
 * NOTE: mrgSortFast is not recursive: the optimized mrgSort above handles
 *       the recursion while passing extra information (not of interest to 
 *       top level) in order to avoid redundant memory access.
 * RETURNS: address of base node of list sorted least-to-greatest on ->len.
 *          ub's nodes are used to create list, so unsorted list will be
 *          destroyed by sort.
 */

{
	word_t *pb;				              // Temporary node pointer for traversing the nodes
	unsigned int N=0;				      // Number of nodes in the list
	word_t **UB;					      // Point to base of node address array
	word_t **SB;					      // Save UB 
	// Use these to check for already sorted list	
	word_t *prev;                         // Prev node to check for sorted list
	word_t *curr;                         // Current node to check for sorted list

    // Check if list is immediate NULL
    if (ub==NULL)
    {
    	return NULL;
    }
    

	// Find number of nodes in list				
	for(pb=ub; pb; pb=pb->next){          // Find list size until NULL terminated 
      N++;					
   	}
   	pb=ub;							      // Reset pb
  	
   	UB = malloc(sizeof(word_t**) * N);    // Create array to store node addresses
   	SB = UB;							  // Save start of this array to pass to mrgSort
   				
   	// Gather all node addresses in UB								   	
   	for(int count=0;count<N;count++){
   		*UB=pb;							  // Store node address in *UB array until addresses are exhausted
   		UB++;
   		
   		if (pb != NULL)
   			pb=pb->next;				  // Move to next node to store it	
   		else 
   			break;						  // Leave loop if we reach NULL (end of list)							
   	}
   	pb=ub;								  // Reset pb
    
    prev=ub;
    curr=ub->next;
    
    if (N!=1)
    {
    	// Check for already sorted list by checking if the 
    	// previous node is always less than the current node
    	while(prev->len <= curr->len)
    	{
    		curr = curr->next;
    		prev = prev->next;
    		if (curr == NULL)
    		{
    			return (ub);
    		}  
    	}
    }	    
    
	// Call recursive mrgSort, which will sort the lists
	if (N!=1)
		ub=mrgSort(N,ub,SB);				  

	free(SB);
	
   	return(ub);  /* replace with your implementation */
}


