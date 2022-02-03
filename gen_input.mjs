import { writeFileSync } from 'fs';
import { argv } from 'process';

let n = Number(argv[1]);
n = !isNaN(n) ? n : Number(argv[2]);
let inputs = {};
inputs['in'] = Array.from({length: n}, () => 1);

let path = `input_${n}.json`;
writeFileSync(path, JSON.stringify(inputs));
