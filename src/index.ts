import { readFileSync } from "node:fs";
import { run, setup } from "./forsp";

function main(argv: string[]) {
  // console.log(argv);
  if (!argv.length) {
    return;
  }

  let inputProgram = "";
  if (argv[0] === "--raw") {
    inputProgram = argv[1];
    // console.log(argv[1]);
  } else {
    inputProgram = readFileSync(argv[0]).toString();
    // console.log(readFileSync(argv[0]).toString());
  }

  if (!inputProgram) return;

  const st = setup(inputProgram);
  run(st);
}

main(globalThis.process.argv.slice(2));

// console.log(NULL_OBJ);
