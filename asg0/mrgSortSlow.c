#include <stdlib.h>
#include <stdio.h>	
#include <assert.h>
#include "word.h"

/*
  Author: Austin Parkes
  Course: ENGR-E 599
  Assignment: asg0
*/

word_t *mergeLists(word_t *lb, word_t *rb)
/*
 * Given two (left & right) sorted lists started by lb & rb
 * RETURNS: base ptr for merged  and sorted list
 * NOTE: both lb & rb are lost, since their nodes are merged into return list
 */
{
   word_t * ub_sort; 		// base pointer for sorted list      
   word_t * low;            // pointer for node of lower value
   word_t * pb = lb;			
      
   if(lb->len < rb->len){	// find the lower of the two compared values
      low = lb;
      lb = lb->next;		// move to next element/node in the list
   }
   else{
      low = rb;
      rb = rb->next;		// move to next element/node in the list
   }
   
   
   ub_sort = low;

   if(rb == NULL){			 	 // Check if reached end of list
       low->next = lb;			 // connect to next lowest value			 
       return(ub_sort);
   }
   else if(lb == NULL){		     // Check if reached end of list
       low->next = rb;           // connect to next lowest value	
       return(ub_sort);
   }
   
   while(lb != NULL && rb != NULL){		// Start sorting low values! (until a list empties)
      if(lb->len < rb->len){     
         low->next = lb;				// connect to next lowest value		  
         low = low->next;				// step low to the end
         lb = lb->next;
      }
      else{
         low->next = rb;				// connect to next lowest value		
         low = low->next;				// step low to the end	
         rb = rb->next;

      }
      
   }
   
   if(rb == NULL){
       low->next = lb;					// step low to the end	
       return(ub_sort);
   }
               
   if(lb == NULL){
       low->next = rb;					// step low to the end	
       return(ub_sort);
   }	
   return(ub_sort);
}

word_t *mrgSortSlow /*RET: base ptr of list sorted least-to-greatest by ->len.*/
(
   word_t *ub /* base of unsorted list, destroyed by sort */
)
/*
 * On entry lb is an unsorted list, which will be destroyed to produce sort.
 * RETURNS: base ptr of list sorted least-to-greatest by ->len.
 * NOTE: for this API must be used for all recursion, and no external variables
 *       can be used (mrgSortFast will allow extending recursive params).
 */
{
   
   word_t *pb=ub;			// Retain ub   
   word_t *save_malcom=ub;	// Save the middle element
   word_t *hold=ub;	  
   int rb=0;				// Right Index of unsorted list
   if(ub == NULL){
   	  return NULL;
   }

   for(pb=ub; pb; pb=pb->next){	// Find list size until NULL terminated 
      rb++;					
   }
   //printf("   rb (right boundary):%d\n", rb);
   
   pb=ub;					// Redundant, but do it to be safe
   int middle = rb/2;		// Find the middle	
   
   /* Not working out	
   int counter=0;
  	
   for(pb=ub; pb; pb=pb->next){	// insert NULL in the middle of list->next
      if (counter == (middle-1)){	    
      	pb = pb->next;						// Hold the middle
      	break;	
      }
      counter++;
   }
   save_malcom = pb;						   // Save the middle
   pb = pb->next;						   
   save_malcom->next = NULL;
   */
   
   
   // Insert NULL in middle and save middle
   for(int counter = 0; counter < middle - 1; counter++){  
      pb = pb->next; 						// Hold the middle
   }
   save_malcom = pb;					    // Save the middle
   pb = pb->next; 
   save_malcom->next = NULL;   
   
   
   if(ub->next != NULL){
   	  ub = mrgSortSlow(ub);
   }
  // for(pb=ub;pb;pb=ub->next){ test the values
  //    printf("%d",pb->len);
  // } 
  
   if(pb->next != NULL){
   	  pb = mrgSortSlow(pb);
   }   
   	

   ub = mergeLists(ub, pb);
		
   return(ub);  /* Returns base ptr of list sorted least-to-greatest by -> len */
}

