#!/bin/bash -eux

# Download circomlib dependencies
[ ! -d "circomlib" ] && git clone --depth 1 https://github.com/iden3/circomlib.git --branch v2.0.3

# compile circuit
circom battery.circom --r1cs --wasm --sym
# print circuit info
npx snarkjs info -r battery.r1cs
# verify the circuit
npx snarkjs r1cs print -r battery.r1cs -s battery.sym
# check constraints
npx snarkjs r1cs export json battery.r1cs battery.r1cs.json
head battery.r1cs.json

# generate input
node gen_input_level.mjs
head input_level_92.json

# calculate witness (actually run the program!)
npx snarkjs calculatewitness --wasm battery_js/battery.wasm --input input_level_92.json

# set up PLONK proving system (requires powers of tau)
wget -nc https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau -O pot12_final.ptau || true
npx snarkjs plonk setup battery.r1cs pot12_final.ptau battery_final.zkey
npx snarkjs zkey export verificationkey battery_final.zkey verification_key.json
head verification_key.json

# create the proof
npx snarkjs plonk prove battery_final.zkey witness.wtns proof.json public.json
head proof.json
head public.json
# validate the proof (in javascript)
npx snarkjs plonk verify verification_key.json public.json proof.json
