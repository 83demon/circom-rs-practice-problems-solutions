pragma circom 2.0.0;

/*Create an arithmetic circuit that takes signals x₁, x₂, …, xₙ and is satsified if all signals are 1.*/

template AllOnesN(N) {
	signal input in[N];

	for (var i=0; i<N; i++) {
		1 === in[i];
	}

}

component main = AllOnesN(1);
