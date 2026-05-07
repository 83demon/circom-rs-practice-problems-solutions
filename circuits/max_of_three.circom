pragma circom 2.0.0;


/* Create an arithmetic circuit that constrains k to be the maximum of x, y, or z. That is, k should be equal to x if x is the maximum value, and same for y and z. */

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        // Квадратичне обмеження: біт може бути лише 0 або 1
        out[i] * (out[i] - 1) === 0;
        lc1 += out[i] * 2**i;
    }
    // Головне обмеження: сума бітів має дорівнювати входу
    // Чому це важливо: без цього доводжувач може підставити будь-які біти
    lc1 === in;
}

template RangeCheck (n) {
	signal input in;

	// This is because 253rd bit it the last fully supported bit in bn254 curve.
	// And for comparison we need numbers n-1 bits in size.
	assert(n <= 252);

	component n2b = Num2Bits(n);
	n2b.in <== in;
}

template GreaterThanOrEqual (n) { 
	signal input x;
	signal input y;
	signal output out;

	component n2b = Num2Bits(n+1);

	n2b.in <== (1 << n ) + x - y;
	out <== n2b.out[n];
}


template MaxOfThree (n) {
    signal input x;
	signal input y;
	signal input z;
	signal input k;

    component rcX = RangeCheck(n);
    component rcY = RangeCheck(n);
    component rcZ = RangeCheck(n);
    rcX.in <== x;
    rcY.in <== y;
    rcZ.in <== z;

    component geq1 = GreaterThanOrEqual(n);
    geq1.x <== x;
    geq1.y <== y;

    signal max_xy;
    max_xy <== geq1.out * (x - y) + y;

    component geq2 = GreaterThanOrEqual(n);
    geq2.x <== max_xy;
    geq2.y <== z;

    k === geq2.out * (max_xy - z) + z;
}

component main = MaxOfThree(4);
