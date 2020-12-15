#define  N    r0      // number of elements
#define  V    r1      // address stored in r1
#define  i    r12     // Since optimization isn't my goal
#define  sl   r2      // low word of sum
#define  sh   r3      // high word pf sum
#define  temp r4      // temporary storage for v[i]

/*
 * Author: Austin Parkes
 * Assignment: p2_lsum (asg2)
 *
 *          r1----r0          <------r0----->  <-----r1------>
 * unsigned long long lvecsum(unsigned int N, unsigned int *V)
 * {
 *    unsigned int i;
 *    unsigned long long sum=0;
 *    for (i=0; i < N; i+=)
 *       sum += V[i];
 *    return(sum);
 * }
 * long long - 64 bit
 * int       - 32 bit
 */
.text
.arm
.global lvecsum
lvecsum: 
_start:   
   sub  SP,SP,#4       // Save r4 (callee saved)
   str  temp, [SP]     // Save r4 to stack
   eor  i,i,i          // i=0
   eor  sl,sl,sl       // sum[31-0]  = 0
   eor  sh,sh,sh       // sum[64-32] = 0
   
sum:
   cmp  V, i           // Check if V is NULL
   beq  NULL           // Return 0 if V is NULL
   ldr  temp, [V],#4   // save v[i] and move up an address
   add  i,i,#1         // i++ (kind of, this is really achieved above)
   adds sl, sl, temp   // sum(low) += v[i], set carry incase
   adc  sh, sh, #0     // Add 1 if carry set, add 0 if carry not set
   cmp  i, N           // Check if at end of for loop
   bne  sum            // Keep Summing till we reach end of for loop
   bal  done64         // End of for loop, wrap things up      

NULL:
   mov  r0, #0         // Return 0 in sum(low)
   mov  r1, #0         // Return 0 in sum(high)
   bal  exit           // Exit our fucntion

done64:
   mov r0, sl          // Return sum(low) 
   mov r1, sh          // Return sum(high)

exit:
   ldr  temp,[SP]      // Restore r4 for caller
   add  SP,SP,#4       // Restore Stack
   bx lr               // Return to caller





