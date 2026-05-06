pragma circom 2.0.0;

/*Create an arithmetic circuit that takes signals x₁, x₂, …, xₙ and is satisfied if at least one signal is 0. Requires n >= 2.*/  

template AtLeastOneZeroN (N) {  

   // Declaration of signals.  
   signal input in[N];
   signal intermediates[N-1];

   intermediates[0] <== in[0]*in[1];

   for (var i=1; i<N-1; i++) {
     intermediates[i] <== intermediates[i-1]*in[i+1];
   }

   intermediates[N-2] === 0;
}

component main = AtLeastOneZeroN(5);
