#define lb    r0   // *lb
#define rb    r1   // *rb
#define gNxt  r2   // gNxt
/* gI(r3) is used to temporarily store lb/rb for a calculation
 * Then gI(r3) is restored to use later
 * gI is saved in svgI during this meantime
*/
#define gI    r3   // gI
#define lb_al r3   // Alias for lb 
#define rb_al r3   // Alias for rb
// r4-r7 are reused exstensively when they become free
#define lint  r4   // Left node integer to compare
#define temp  r4   // Use to hold bits for pseudo predication
#define next  r4   // Holds next node to update lb/rb
#define rint  r5   // Right node integer to compare
#define temp2 r5   // Use to hold bits for pseudo predication
#define mrg   r6   // Merge nodes into new list
#define temp4 r6   // Use to hold bits for pseudo predication   
#define ans   r7   // Outcome to ternary operation
#define temp3 r7   // Use to hold bits for pseudo predication
// Saves gI and mrg to use r3 and r6 for calculations
#define svgI  r8   // Save r3 (gI) at a moment we aren't using it
#define svmrg r9   // Save r6 (mrg) at a moment we aren't using it

#define FSZ 4*6    // 4 bytes x 6 reg
#define mrgSZ 4    // 4 bytes for saving mrg

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
   // Didn't feel like using push or pop, hopefully that isn't an issue
   sub SP,SP,#FSZ         // Make room to save callee saved registers   
   str r4,[SP]            // Save r4
   str r5,[SP,#4]         // Save r5
   str r6,[SP,#8]         // Save r6
   str r7,[SP,#12]        // Save r7
   mov r7,r8              // Save r8 through r7
   str r7,[SP,#16]        // Save r8
   mov r7,r9              // Save r9 through r7
   str r7,[SP,#20]        // Save r9
   
     
   //LB/RB NOT BEING UPDATED WHEN THEY NEED TO ADVANCE
   // Peel a loop and check for NULL
   ldr lint,[lb,gI]       // Get left node integer
   ldr rint,[rb,gI]       // Get right node integer  
   // Compare lint and rint below    
   // ans = (lint>rint)?rb:lb
   subs temp,rint,lint    // Negative if lint>rint, else positive
   asrs temp,temp,#31     // All 1s if lint>rint, else all 0s        
   movs ans,rb            // ans = rb, Result if lint>rint
   ands ans,temp          // ans=(lint>rint)?rb:0   
   mvns temp,temp         // temp=(lint<=rint)?all1s:all0s
   ands temp,lb           // temp=(lint<=rint)?lb:0
   orrs ans,temp          // ans=(lint>rint)?rb:lb.
   // Update lowest value to list 
   movs mrg,ans           // Update list(mrg) with node with lowest value  
   // next is the next node that the lower lb/rb will advance to 
   ldr next,[ans,gNxt]    // Move to next node with higher integer
  
   
   // mrg(out of loop) contains the node with lowest integer (rb or lb)   
   // Whichever node equals mrg, will be the one we advance with 'next'

   /* Outputs next or lb, then assign to lb
    * If (lb==mrg)
    *    lb=next
    * else
    *    lb=lb 
    *
    * Outputs next or rb, then assign to rb
    * If (rb==mrg)
    *    rb=next
    * else 
    *    rb=rb
    * 
   */
   
   // Save gI(r3) to give up r3 for lb and rb to perform quick calculations
   mov svgI,gI            // Save gI in hi r8 to give up r3
   movs lb_al,lb          // Use lo r3 to store lb
   // r5 amd r7 are now free   
   // lb_al is an alias for lb
   // lb=(lb==mrg)?next:lb
   subs temp2,lb_al,mrg   // Neg iff lb<mrg   
   subs temp3,mrg,lb_al   // Neg iff mrg<lb
   orrs temp2,temp3       // neg iff (lb<mrg || lb>mrg)
   mvns temp2,temp2       // neg iff lb==mrg  
   asrs temp2,temp2,#31   // temp2=(lb==mrg)?all1s:all0s   
   movs lb,next           // lb=next
   ands lb,temp2          // lb=(lb==mrg)?next:0
   mvns temp2,temp2       // temp2=(lb!=mrg)?all1s:all0s
   ands temp2,lb_al       // temp=(lb!=mrg)?b:0
   orrs lb,temp2          // lb=(lb==mrg)?next:lb
   
   movs rb_al,rb          // Use r3 to store rb

   // r5 and r7 are free again
   // rb_al is an alias for rb
   // rb=(rb==mrg)?next:rb
   subs temp2,rb_al,mrg   // Neg iff lb<mrg   
   subs temp3,mrg,rb_al   // Neg iff mrg<lb
   orrs temp2,temp3       // neg iff (lb<mrg || lb>mrg)
   mvns temp2,temp2       // neg iff lb==mrg  
   asrs temp2,temp2,#31   // temp2=(lb==mrg)?all1s:all0s   
   movs rb,next           // lb=next
   ands rb,temp2          // lb=(lb==mrg)?next:0
   mvns temp2,temp2       // temp2=(lb!=mrg)?all1s:all0s
   ands temp2,rb_al       // temp=(lb!=mrg)?b:0
   orrs rb,temp2          // lb=(lb==mrg)?next:rb

   mov gI,svgI            // Restore gI(r3) to it's original state
  
   // mrg holds the first node in list
   sub SP,SP,#mrgSZ       // Make room on stack for first node
   str mrg,[SP]           // Store first node on stack, to save a register  
   
   // Check if either list reached NULL
   // temp holds rb/lb, whichever held the lowest integer
   cmp next,#0            // Check if left or right list reached NULL
   bEQ EXIT               // Wrap up anything extra
 
   // Order nodes from least to greatest integer values and merge
   MERGE:
      // Setup the integers to find which node holds the lowest  
      ldr lint,[lb,gI]    // Get left node integer
      ldr rint,[rb,gI]    // Get right node integer
      // Find node with lowest integer and add it to the new list (mrg)
      //ans=(lint>rint)?rb:lb
      subs temp,rint,lint    // Negative if lint>rint, else positive
      asrs temp,temp,#31     // All 1s if lint>rint, else all 0s        
      movs ans,rb            // ans = rb, Result if lint>rint
      ands ans,temp          // ans=(lint>rint)?rb:0   
      mvns temp,temp         // temp=(lint<=rint)?all 1s:all 0s
      ands temp,lb           // temp=(lint<=rint)?lb:0
      orrs ans,temp          // ans=(lint>rint)?rb:lb      
      // Update lowest value to list
      str ans,[mrg,gNxt]     // Update list with the next lowest value (lint)
      ldr next,[ans,gNxt]    // Move to node with higher integer
     
      // Save register values for quick calculations
      mov svmrg,mrg          // Save mrg(r6) to use r6 temporarily      
      mov svgI,gI            // Save gI in hi r8 to give up r3
      movs lb_al,lb          // Use lo r3 to store lb

      // lb_al is an alias for lb
      // lb=(lb==ans)?next:lb
      subs temp2,lb_al,ans   // Neg iff lb<ans   
      subs temp4,ans,lb_al   // Neg iff mrg<lb
      orrs temp2,temp4       // neg iff (lb<ans || lb>ans)
      mvns temp2,temp2       // neg iff lb==ans  
      asrs temp2,temp2,#31   // temp2=(lb==ans)?all1s:all0s   
      movs lb,next           // lb=next
      ands lb,temp2          // lb=(lb==ans)?next:0
      mvns temp2,temp2       // temp2=(lb!=ans)?all1s:all0s
      ands temp2,lb_al       // temp=(lb!=ans)?b:0
      orrs lb,temp2          // lb=(lb==ans)?next:lb
   
      movs rb_al,rb          // Use lo r3 to store rb
 
      // r5 and r7 are free again
      // rb=(rb==ans)?next:rb
      subs temp2,rb_al,ans   // Neg iff lb<ans   
      subs temp4,ans,rb_al   // Neg iff ans<lb
      orrs temp2,temp4       // neg iff (lb<ans || lb>ans)
      mvns temp2,temp2       // neg iff lb==ans  
      asrs temp2,temp2,#31   // temp2=(lb==ans)?all1s:all0s   
      movs rb,next           // lb=next
      ands rb,temp2          // lb=(lb==ans)?next:0
      mvns temp2,temp2       // temp2=(lb!=ans)?all1s:all0s
      ands temp2,rb_al       // temp=(lb!=ans)?b:0
      orrs rb,temp2          // lb=(lb==ans)?next:rb
      
      // Restore the saved registers
      mov gI,svgI            // Restore gI to use again!         
      mov mrg,svmrg          // Restore mrg to use it now!

      // Advance the merged lists
      ldr mrg,[mrg,gNxt]     // Advance to next node to attach next lowest node
      
      // Check if either list reached NULL
      // temp holds rb/lb. whichever held the lowest integer
      cmp next,#0         // Check if left or right list hit NULL
      bNE MERGE           // Loop again unless we reached end of a list

EXIT:   
   // Either lb or rb are 0
   // Whichever isn't 0, we add to the end of list   
   adds lb,rb            // Get the non-zero of the two 
   str lb,[mrg,gNxt]     // Store the final node
   ldr r0,[SP]           // Get the first node in the list to return it     
   add SP,SP,#mrgSZ      // Restore stack for where mrg was
   // Need to restore r4-r9
   // Restore r8 and r9 first since you can't use ldr or str with hi registers
   // Stack will be restored for r8 and r9 at the very end
   ldr r7,[SP,#20]       // Use r7 to load r9
   mov r9,r7             // Restore r9
   ldr r7,[SP,#16]       // Use r7 to load r8
   mov r8,r7             // Restore r8  
   ldmIA SP!,{r4-r7}     // Restore stack for r4-r7
   add SP,SP,#8          // Restore stack for r8 and r9

   bx lr                 // Return to caller
