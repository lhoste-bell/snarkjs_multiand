#!/bin/bash -eux

circom multiand.circom --r1cs --wasm --sym
#    multiand.r1cs -- the constraint system of the circuit in binary format
#    multiand.sym -- the wasm code to generate the witness
#    multiand.wasm -- a symbols file required for debugging and printing the constraint system in an annotated mode
npx snarkjs info -r multiand.r1cs
#    verify the circuit
npx snarkjs r1cs print -r multiand.r1cs -s multiand.sym
#    check constraints
npx snarkjs r1cs export json multiand.r1cs multiand.r1cs.json
head multiand.r1cs.json

#    calculate witness (actually run the program!)
#node gen_input.mjs 10
#head input_10.json
#npx snarkjs calculatewitness --wasm multiand_js/multiand.wasm --input input_10.json
node gen_input.mjs 1000
head input_1000.json
npx snarkjs calculatewitness --wasm multiand_js/multiand.wasm --input input_1000.json

#    set up PLONK proving system (requires powers of tau)
wget -nc https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau -O pot12_final.ptau || true
npx snarkjs plonk setup multiand.r1cs pot12_final.ptau multiand_final.zkey
npx snarkjs zkey export verificationkey multiand_final.zkey verification_key.json
head verification_key.json

#    create the proof
npx snarkjs plonk prove multiand_final.zkey witness.wtns proof.json public.json
head proof.json
head public.json
#    validate the proof (in javascript)
npx snarkjs plonk verify verification_key.json public.json proof.json
#    generate the verifier (in solidity)
npx snarkjs zkey export solidityverifier multiand_final.zkey verifier.sol
head verifier.sol
#    generate the call data
npx snarkjs zkey export soliditycalldata public.json proof.json

#    modify input
npx snarkjs calculatewitness --wasm multiand_js/multiand.wasm --input input_1000.json
#    validate the proof (in javascript)
time npx snarkjs plonk prove multiand_final.zkey witness.wtns proof.json public.json
#    generate the call data
npx snarkjs zkey export soliditycalldata public.json proof.json

