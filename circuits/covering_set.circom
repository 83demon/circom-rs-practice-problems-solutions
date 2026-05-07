pragma circom 2.0.0;

/* The covering set problem starts with a set S={1,2,…,10} and several well-defined subsets of S, for example: {1,2,3}, {3,5,7,9}, {8,10}, {5,6,7,8}, {2,4,6,8}, and asks if we can take at most k subsets of S such that their union is S. In the example problem above, the answer for k=4 is true because we can use {1,2,3}, {3,5,7,9}, {8,10}, {2,4,6,8}. Note that for each problems, the subsets we can work with are determined at the beginning. We cannot construct the subsets ourselves. If we had been given the subsets {1,2,3}, {4,5} {7,8,9,10} then there would be no solution because the number 6 is not in the subsets.

On the other hand, if we had been given S={1,2,3,4,5} and the subsets {1},{1,2},{3,4},{1,4,5} and asked can it be covered with k=2 subsets, then there would be no solution. However, if k=3 then a valid solution would be {1,2},{3,4},{1,4,5}.

Our goal is to prove for a given set S and a defined list of subsets of S, if we can pick a set of subsets such that their union is S. Specifically, the question is if we can do it with k or fewer subsets. We wish to prove we know which k (or fewer) subsets to use by encoding the problem as an arithmetic circuit. */


template IsZero() {
    signal input in;
    signal output out;

    signal inv;
    inv <-- (in != 0) ? 1/in : 0;
	out <-- (in == 0) ? 1 : 0;

    in * inv === 1 - out;

    in * out === 0;
}


template CoveringSet(n_elements, n_subsets, subsets) {

	signal input k;
    signal input selected[n_subsets]; // A witness.
	
	var k_compare = 0;
	for (var i=0; i<n_subsets; i++) {
		0 === selected[i] * (1 - selected[i]);
		k_compare += selected[i];
	}

	k_compare === k;

	component is_zero[n_elements];
    for (var j = 0; j < n_elements; j++) {
        var coverage = 0;
        for (var i = 0; i < n_subsets; i++) {
            coverage += selected[i] * subsets[i][j];
        }
        
        is_zero[j] = IsZero();
        is_zero[j].in <== coverage;
        is_zero[j].out === 0;
    }
}

component main = CoveringSet(4, 4, [[0,1,1,0],[1,0,0,0],[0,0,0,0],[0,1,1,1]]);
