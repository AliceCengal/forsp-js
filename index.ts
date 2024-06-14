import { readFileSync } from "node:fs";

function main(argv: string[]) {
  // console.log(argv);
  if (!argv.length) {
    return;
  }

  if (argv[0] === "--raw") {
    console.log(argv[1]);
  } else {
    console.log(readFileSync(argv[0]).toString());
  }
}

main(globalThis.process.argv.slice(2));

// console.log(NULL_OBJ);
