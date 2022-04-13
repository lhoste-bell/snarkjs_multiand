pragma circom 2.0.0;


template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in!=0 ? 1/in : 0;

    out <== -in*inv +1;
    in*out === 0;
}

template MultiAND(n) {
    signal input in[n];
    signal output out;

    var sum = 0;
    for (var i=0; i<n; i++) {
      sum = sum + in[i];
    }

    component isz = IsZero();
    sum - n --> isz.in;
    isz.in === sum - n;

    isz.out --> out;
    out === isz.out;
}

component main = MultiAND(1000);
