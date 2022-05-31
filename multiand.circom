pragma circom 2.0.0;


template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

template MultiAND(n) {
    signal input in[n];
    signal output out;

    var sum = 0;
    component num2Bits[n];
    for (var i=0; i<n; i++) {
      num2Bits[i] = Num2Bits(1);
      num2Bits[i].in <== in[i];
      sum = sum + num2Bits[i].out[0];
    }

    component isz = IsZero();
    sum - n --> isz.in;
    isz.in === sum - n;

    isz.out --> out;
    out === isz.out;
}

component main = MultiAND(1000);
