#!/bin/bash -eux

circom circuit.circom --r1cs --wasm --sym
#    circuit.r1cs -- the constraint system of the circuit in binary format
#    circuit.sym -- the wasm code to generate the witness
#    circuit.wasm -- a symbols file required for debugging and printing the constraint system in an annotated mode
npx snarkjs info -r circuit.r1cs
#    verify the circuit
npx snarkjs r1cs print -r circuit.r1cs -s circuit.sym
#    check constraints
npx snarkjs r1cs export json circuit.r1cs circuit.r1cs.json
head circuit.r1cs.json

#    calculate witness (actually run the program!)
#node gen_input.mjs 10
#head input_10.json
#npx snarkjs calculatewitness --wasm circuit_js/circuit.wasm --input input_10.json
node gen_input.mjs 1000
head input_1000.json
npx snarkjs calculatewitness --wasm circuit_js/circuit.wasm --input input_1000.json

#    set up PLONK proving system (requires powers of tau)
wget -nc https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau -O pot12_final.ptau || true
npx snarkjs plonk setup circuit.r1cs pot12_final.ptau circuit_final.zkey
npx snarkjs zkey export verificationkey circuit_final.zkey verification_key.json
head verification_key.json

#    create the proof
npx snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json
head proof.json
head public.json
#    validate the proof
npx snarkjs plonk verify verification_key.json public.json proof.json
#    generate the verifier
npx snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol
head verifier.sol
#    generate the call data
npx snarkjs zkey export soliditycalldata public.json proof.json

#    modify input
npx snarkjs calculatewitness --wasm circuit_js/circuit.wasm --input input_1000.json
#    validate the proof
time npx snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json
#    generate the call data
npx snarkjs zkey export soliditycalldata public.json proof.json

