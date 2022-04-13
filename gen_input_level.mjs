import { writeFile } from 'fs/promises';
import { strict as assert } from 'assert';

const circomlibjs = await import("circomlibjs")
const eddsa = await circomlibjs.buildEddsa();
const babyJub = await circomlibjs.buildBabyjub();
const F = babyJub.F;

const stringifyBigInts = (o) => {
    if ((typeof (o) == "bigint") || o.eq !== undefined) {
        return "0x" + o.toString(16);
    } else if (o instanceof Uint8Array) {
        return Scalar.fromRprLE(o, 0);
    } else if (Array.isArray(o)) {
        return o.map(stringifyBigInts);
    } else if (typeof o == "object") {
        const res = {};
        const keys = Object.keys(o);
        keys.forEach((k) => {
            res[k] = stringifyBigInts(o[k]);
        });
        return res;
    } else {
        return o;
    }
}

for (let level of [0, 40, 60, 90, 92, 100]) {
    const msg = F.e(level);
    const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");
    const pubKey = eddsa.prv2pub(prvKey);
    const signature = eddsa.signPoseidon(prvKey, msg);
    assert(eddsa.verifyPoseidon(msg, signature, pubKey));

    const inputs = {
        pubkey: [F.toObject(pubKey[0]), F.toObject(pubKey[1])],
        signature: [F.toObject(signature.R8[0]), F.toObject(signature.R8[1]), signature.S],
        pct: F.toObject(msg)
    };

    let path = `input_level_${level}.json`;
    await writeFile(path, JSON.stringify(stringifyBigInts(inputs)));
}

