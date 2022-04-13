/*

Transform battery level into a high or low bucket

*/

pragma circom 2.0.0;

include "circomlib/circuits/eddsaposeidon.circom";

template IsHigh() {
    signal input pct;
    signal input pubkey[2];
    signal input signature[3];
    signal output high;

    component pctSigVerifier = EdDSAPoseidonVerifier();
    pctSigVerifier.enabled <== 1;
    pctSigVerifier.Ax <== pubkey[0];
    pctSigVerifier.Ay <== pubkey[1];
    pctSigVerifier.R8x <== signature[0];
    pctSigVerifier.R8y <== signature[1];
    pctSigVerifier.S <== signature[2];
    pctSigVerifier.M <== pct;

    component isHigher = GreaterEqThan(8); // 2^8 bits
    isHigher.in[0] <== pct;
    isHigher.in[1] <== 80;
    isHigher.out ==> high;

}

component main {public [pubkey,signature]} = IsHigh();
