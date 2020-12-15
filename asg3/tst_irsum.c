#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int isum(int N, int *X)
{
   if (N > 0)
   {
      int i, isum = *X;
      for (i=1; i < N; i++)
         isum += X[i];
      return(isum);
   }
   return(0);
}
/* Old with nested recursion
int irsum(int N, int *X)
{
	if (N>0)
	{
	   
	    int suml=0;
	    int sumr=0;
 	    int Nleft = N/2; 			// # elements on Left side of array
 	    int Nright = N - Nleft;     // # elements on Right side of array
 	    
 	    //int L_ele = 
 	    
		if (Nleft >= 1)
			suml = (irsum(Nleft-1,X) + *(X+Nleft-1));
			
		if (Nright >= 1)
			sumr = (irsum(Nright-1,X+Nleft) + *(X+N-1));
		
		return suml+sumr;

	}
	
	return 0;	
}
*/

// New with no nested recursion
int irsum(int N, int *X)
{

	int nL = N>>1; 			    // # elements on Left side of array
	int *last_R=X+N-1;          // Get last element in right list to
 	int nR = N - nL;            // # elements on Right side of array

	// Don't return anything if no elements
	if (nR<=0)
		return 0;	
		   
	int sum = (irsum(nR-1,X+nL) + *(last_R));	
 		
 	int *last_L=X+nL-1;	   // Last element in left list to add	
	if (nL >= 1)
		sum = sum + (irsum(nL-1,X) + *(last_L));
		
	return sum;	
}


/*
 * This tester takes three optional arguments, [<maxN> [<ntest> [<nseed>]]]
 *   maxN : largest size that can be randomly chosen
 *   ntest: the number of tests to randomly do
 *   seed : seed for random number generator
 *
 * For each of the ntest tests, a random vector length between [0,maxN-1] is
 * generated, then that length vector alloced & initialized with random values.
 * the recursive irsum's answer is compared to a known-good answer from isum.
 */
int main(int nargs, char **args)
{
   int maxN=211, seed=0xF187Ac3, ntest=22, t, nfail=0;
   int X[6]={1, -2, 5, 7, 8, 9};
   int irsum(int N, int *X);
/*
 * Override default values if commandline options given
 */
   if (nargs > 1)
   {
      maxN = atoi(args[1]);
      if (nargs > 2)
      {
         ntest = atoi(args[2]);
         if (nargs > 3)
            seed = atoi(args[3]);
      }
   }
/*
 * Test some small problems with known results, die on first error
 */
   assert(irsum(0, NULL) == 0);
   assert(irsum(-10, NULL) == 0);
   assert(irsum(1, X) == 1);
   assert(irsum(2, X) == -1);
   assert(irsum(3, X) == 4);
   assert(irsum(4, X) == 11);
   assert(irsum(5, X) == 19);
   assert(irsum(6, X) == 28);
/*
 * Test ntest random-length summations using known-good isum()
 */
   srand(seed);
   for (t=0; t < ntest; t++)
   {
      int N, i, *Y, good, test;

      N = rand() % maxN;          /* find random length between [0,maxN-1] */
      Y = malloc(sizeof(int)*N);  /* allocate it */
      assert(Y);                  /* did I get it? */
      for (i=0; i < N; i++)       /* Loop over all elements */
         Y[i] = rand();           /* init to random value */
      good = isum(N, X);          /* find correct answer */
      test = irsum(N, X);         /* find irsum's answer */
      if (good == test)
         fprintf(stderr, "   N=%d, ans=%d: PASS\n", N, good);
      else
      {
         nfail++;
         fprintf(stderr, "   N=%d, ans=%d, got=%d: FAIL\n", N, good, test);
      }
      free(Y);
   }
   if (nfail)
      fprintf(stderr, "\n   FAILED %u out of %u tests!\n\n", nfail, ntest+8);
   else
      fprintf(stderr, "\n   PASSED all %u tests!\n\n", ntest+8);
   return(nfail);
}
