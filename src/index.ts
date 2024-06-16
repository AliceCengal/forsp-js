import { readFileSync } from "node:fs";
import { IO, run, setup } from "./forsp";
import path from "node:path";

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

  const adapter: IO = {
    std: {
      readLine: function (): string {
        throw new Error("Function not implemented.");
      },
      printLine: function (str?: string): void {
        console.log(str);
      },
      printError: function (str?: string): void {
        console.error(str);
      },
    },
    file: {
      read: function (filePath: string): string {
        const importRoot =
          argv[0] === "--raw" ? process.cwd() : path.join(argv[0], "..");

        let importPath = path.join(importRoot, filePath + ".fp");

        const importedModule = readFileSync(importPath).toString();
        return importedModule;
      },
    },
  };
  const st = setup(adapter, inputProgram);
  run(st);
}

main(globalThis.process.argv.slice(2));

// console.log(NULL_OBJ);
