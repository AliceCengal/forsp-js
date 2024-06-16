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
    try {
      inputProgram = readFileSync(argv[0]).toString();
    } catch (err: any) {
      console.error(`Failed to open file '${argv[0]}'`);
      if (err instanceof Error) {
        console.error(err.message);
      }
      return;
    }

    // console.log(readFileSync(argv[0]).toString());
  }

  if (!inputProgram) return;

  const st = setup(inputProgram);
  run(st);
}

main(globalThis.process.argv.slice(2));

// console.log(NULL_OBJ);
