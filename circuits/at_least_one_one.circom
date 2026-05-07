pragma circom 2.0.0;

/* Create an arithmetic circuit that takes signals x₁, x₂, …, xₙ, constrains them to be binary, and outputs 1 if at least one of the signals is 1. Hint: this is tricker than it looks. Consider combining what you learned in the first two problems and using the NOT gate. */

template AtLeastOneOne (N) {
	signal input in[N];
	signal intermediate[N-1];
	signal output out;

	for (var i=0; i<N; i++) {
		0 === in[i] * (in[i] - 1);
	}

	intermediate[0] <== (1-in[0]) * (1-in[1]);

	for (var i=1; i<N-1; i++) {
		intermediate[i] <== intermediate[i-1] * (1 - in[i+1]);	
	}

	intermediate[N-2] === 0;
}

component main = AtLeastOneOne(5);
