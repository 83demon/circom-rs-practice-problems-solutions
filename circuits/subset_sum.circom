pragma circom 2.0.0;

/* Create an arithmetic circuit that models the Subset sum problem. Given a set of integers (assume they are all non-negative), determine if there is a subset that sums to a given value k. For example, given the set { 3,5,17,21 } and k=22, there is a subset { 5,17 } that sums to 22. Of course, a subset sum problem does not necessarily have a solution.*/

template SubsetSum (N, k, set) {

	signal input in[N]; 
	
	var sum=0;
	for (var i=0; i<N; i++) {
		0 === in[i] * (1 - in[i]);
		sum += in[i]*set[i];
	}

	sum === k;
}

component main = SubsetSum(4,22,[3,5,17,21]);
