pragma circom 2.0.0;

/* Create an arithmetic circuit to determine if a signal v is a power of two (1, 2, 4, 8, etc). Hint: create an arithmetic circuit that constrains another set of signals to encode the binary representation of v, then place additional restrictions on those signals.*/

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


template PowerOfTwo (N) {

	signal input v;
	component n2b = Num2Bits(N);
	n2b.in <== v;

	var sum_of_bits = 0;
	for (var i=0; i<N; i++) {
		sum_of_bits += n2b.out[i];		
	}

	sum_of_bits === 1;
}

component main = PowerOfTwo(5);
