#define N   r0      // number of elements
#define sl  r0      // Sum(low). Used at end of program
#define V   r1      // address stored in r1
#define sh  r1      // Sum(high). Used at end of program
#define f1  r2      // Free Register for the loop
#define f2  r3      // Free Register for the loop
#define s0  r4
#define s1  r5
#define s2  r6
#define s3  r7
#define s4  r8
#define s5  r9       
#define s6  r10       
#define s7  r11   
#define R   r12      // Stores remainder elements

/*
 * Author: Austin Parkes
 * Assignment: p2_lsum (asg2)
 *
 *          r1----r0          <------r0----->  <-----r1------>
 * unsigned long long lvecsum(unsigned int N, unsigned int *V)
 * {
 *    unsigned long long sum=0
 *    unsigned int s0=s1=s2=s3=s4=s5=s6=s7=0;
 *    for (i=0; i+8 < N; i+=8)
 *    {
 *       s0 += V[i];
 *       s1 += V[i+1];
 *       s2 += V[i+2];
 *       s3 += V[i+3];
 *       s4 += V[i+4];
 *       s5 += V[i+5];
 *       s6 += V[i+6];
 *       s7 += V[i+7];
 *    }
 *    sum = s0+s1+s2+s3+s4+s5+s6+s7
 * }  
 *   
 */
.text
.arm
.global lvecsum
lvecsum: 
   stmDB SP!,{s0-s7, lr} // Make room for r4-11,r14 AND save them
   cmp V,#0              // Make sure V isn't NULL
   bEQ NULL              // Return 0 if V is NULL
   
   mov s0,#0             // 
   mov s1,#0             //
   mov s2,#0
  // mov s3,#0
  // mov s4,#0
  // mov s5,#0
   mov s6,#0
   mov s7,#0

   ands R,N,#7           // R=N%8 - Remainder elements
   cmp R,#1              // Check if atleast 1 remainder
   ldrGE s0,[V],#4       // s0 = 0 V[0],i++
   cmp R,#2              // Check if atleast 2 remainders
   ldrGE s1,[V],#4       // s1 = V[1], i++ 
   cmp R,#3              // Check if atleast 3 remainders
   ldrGE s2,[V],#4       // s2 = V[2], i++  
   cmp R,#4              // Check if atleast 4 remainders
   ldrGE s3,[V],#4       // s3 = V[3], i++
   cmp R,#5              // Check if atleast 5 remainders
   ldrGE s4,[V],#4       // s4 = V[4], i++
   cmp R,#6              // Check if atleast 6 remainders
   ldrGE s5,[V],#4       // s5 = V[5], i++ 
   cmp R,#7              // Check if atleast 7 remainders
   ldrGE s6,[V],#4       // s6 = V[6], i++
   
   subs N,N,R            // N=N-R -> Give remaining elements to loop. R Free 
   bEQ  done             // No more elements to compute so quit
   
   SUM_LOOP:             // s(0-7) = s(0-7) + v[i - (i+8)]   
      ldmia V!,{f1,f2,R,lr}  
      add s0,s0,f1       // s0 += V[i]     
      add s1,s1,f2       // s1 += V[i+1]
      add s2,s2,R        // s2 += V[i+2]
      add s3,s3,lr       // s3 += V[i+3]
      ldmia V!,{f1,f2,R,lr}
      add s4,s4,f1       // s4 += V[i+4]   
      add s5,s5,f2       // s5 += V[i+5]
      add s6,s6,R        // s6 += V[i+6]
      add s7,s7,lr       // s7 += V[i+7]
      subs N,N,#8        // Remaining elements
   bNE SUM_LOOP          // Loop until R0=N=sl=0
   
done:
   mov sh, #0            // Clear sum(high)
   adds s1,s1,s0
   adc sh,sh,#0
   adds s3,s3,s2
   adc sh,sh,#0 
   adds s5,s5,s4
   adc sh,sh,#0 
   adds s7,s7,s6
   adc sh,sh,#0 
   adds s3,s3,s1
   adc sh,sh,#0 
   adds s7,s7,s5 
   adc sh,sh,#0 
   adds sl,s7,s3
   adc sh,sh,#0 

   bAL exit              // Exit function     
       
NULL:
   mov r0, #0            // Return 0 in sum(low)
   mov r1, #0            // Return 0 in sum(high)

exit:
   ldmIA SP!, {s0-s7,lr} // Restore r4-r11,r14 AND Restore stack
   bx lr                 // Return to caller

