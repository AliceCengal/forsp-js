/**
 * Forsp interpreter.
 * The original version was ported from the C version written by xorvoid.
 */

const DEBUG: boolean = false;
const TOKEN_PUSH = "<";
const TOKEN_POP = ">";
const TOKEN_QUOTE = "'";
const TOKEN_QUOTE_2 = ":";
const TOKEN_DICT = "@";

const TAG = {
  NIL: 0,
  ATOM: 1,
  NUM: 2,
  PAIR: 3,
  CLOS: 4,
  PRIM: 5,
  STRING: 6,
} as const;

type Nil = { tag: 0 };
type Atom = { tag: 1; atom: string };
type Pair = { tag: 3; pair: { car: Value; cdr: Value } };
type List = Pair | Nil;
type ListHead = { head: List };
type PrimFunc = (st: State, env: ListHead) => Promise<void> | void;
type Value =
  | Nil
  | Atom
  | { tag: 2; num: number }
  | { tag: 6; str: string }
  | Pair
  | { tag: 4; clos: { body: Value; env: ListHead } }
  | { tag: 5; prim: { func: PrimFunc } };

export type IO = {
  std: {
    readLine: () => Promise<string>;
    printLine: (str?: string) => void;
    printError: (str?: string) => void;
  };
  file: {
    read: (filePath: string, referencePath?: string) => Promise<string>;
  };
};

type State = {
  input: string;
  inputPos: number;

  readStack: Value[];
  stack: List;
  env: ListHead;

  internedAtoms: Atom[];
  NIL: Value;
  TRUE: Value;
  QUOTE: Value;
  PUSH: Value;
  POP: Value;
  io: IO;
};

function makeNil(): Value {
  return { tag: 0 };
}

function makeAtom(atom: string): Value {
  return { tag: 1, atom };
}

function makeNum(num: number): Value {
  return { tag: 2, num };
}

function makeString(str: string): Value {
  return { tag: 6, str };
}

function makePair(car: Value, cdr: Value): Value {
  return { tag: 3, pair: { car, cdr } };
}

function makeClos(body: Value, env: List): Value {
  return { tag: 4, clos: { body, env: { head: env } } };
}

function makePrim(func: PrimFunc): Value {
  return { tag: 5, prim: { func } };
}

function intern(st: State, atom_buf: string): Value {
  const interned = st.internedAtoms.find((a) => a.atom === atom_buf);
  if (interned) {
    return interned;
  }
  const atom = makeAtom(atom_buf) as Atom;
  st.internedAtoms.push(atom);
  return atom;
}

function car(value: Value): Value {
  if (value.tag !== TAG.PAIR) throw new Error("Cannot car a not-Pair");
  return value.pair.car;
}

function cdr(value: Value): Value {
  if (value.tag !== TAG.PAIR) throw new Error("Cannot cdr a not-Pair");
  return value.pair.cdr;
}

function caar(value: Value): Value {
  if (value.tag !== TAG.PAIR || value.pair.car.tag !== TAG.PAIR)
    throw new Error("Cannot caar a not Pair Pair");
  return value.pair.car.pair.car;
}

// function cadr(value: Value): Value {
//   if (value.tag !== TAG.PAIR || value.pair.car.tag !== TAG.PAIR)
//     throw new Error("Cannot cadr a not Pair Pair");
//   return value.pair.car.pair.cdr;
// }

function valueEq(v1: Value, v2: Value) {
  return (
    v1 == v2 || (v1.tag === TAG.NUM && v2.tag === TAG.NUM && v1.num === v2.num)
  );
}

function toNumber(v: Value) {
  return v.tag === TAG.NUM ? v.num : NaN;
}

// function listToArray(v: Value): any[] {
//   const res: any[] = [];
//   let pointer = v;
//   while (pointer.tag == TAG.PAIR) {
//     res.push(car(pointer));
//     pointer = cdr(pointer);
//   }
//   return res;
// }

/**
 * READ
 */

function peek(st: State) {
  if (st.input.length === st.inputPos) {
    return "";
  }
  return st.input.charAt(st.inputPos);
}

function advance(st: State) {
  if (st.input.length > st.inputPos) {
    st.inputPos++;
  }
}

function isWhitespace(s: string) {
  return s.trim().length === 0;
}

// const DIRECTIVES = [TOKEN_POP, TOKEN_PUSH, TOKEN_QUOTE, TOKEN_QUOTE_2];
const PUNCTUATION = ["(", ")", ";"];

// function isDirective(s: string) {
//   return DIRECTIVES.includes(s);
// }

function isPunctuation(s: string) {
  return isWhitespace(s) || PUNCTUATION.includes(s);
}

function skipWhitespaceAndComments(st: State): void {
  const c = peek(st);
  if (c === "") return;

  if (isWhitespace(c)) {
    advance(st);
    return skipWhitespaceAndComments(st);
  }

  if (c === ";") {
    advance(st);
    while (1) {
      const c = peek(st);
      if (c === "") return;
      advance(st);
      if (c === "\n") break;
    }
    skipWhitespaceAndComments(st);
  }
}

function read(st: State): Value {
  if (st.readStack.length) {
    return st.readStack.pop()!;
  }

  skipWhitespaceAndComments(st);

  const c = peek(st);
  if (c === "") return null as any;

  if (c === TOKEN_QUOTE || c === TOKEN_QUOTE_2) {
    advance(st);
    return st.QUOTE;
  }

  if (c === TOKEN_PUSH) {
    advance(st);
    if (peek(st) === TOKEN_PUSH) {
      st.inputPos--;
    } else {
      st.readStack.push(st.PUSH, readScalar(st), st.QUOTE);
      return read(st);
    }
  }

  if (c === TOKEN_POP) {
    advance(st);
    if (peek(st) === TOKEN_POP) {
      st.inputPos--;
    } else {
      st.readStack.push(st.POP, readScalar(st), st.QUOTE);
      return read(st);
    }
  }

  if (c === TOKEN_DICT) {
    advance(st);
    if (peek(st) === "!") {
      advance(st);
      st.readStack.push(intern(st, "force"));
    }

    st.readStack.push(intern(st, "dict-get"), readScalar(st), st.QUOTE);
    return read(st);
  }

  if (c === '"') {
    advance(st);
    return readString(st);
  }

  if (c === "(") {
    advance(st);
    return readList(st);
  } else {
    return readScalar(st);
  }
}

function readScalar(st: State): Value {
  const start = st.inputPos;
  while (!isPunctuation(peek(st))) {
    advance(st);
  }

  const str = st.input.slice(start, st.inputPos);

  const num = Number(str);
  if (Number.isNaN(num)) {
    return intern(st, str);
  } else {
    return makeNum(num);
  }
}

function readList(st: State): Value {
  if (!st.readStack.length) {
    skipWhitespaceAndComments(st);
    const c = peek(st);
    if (c === ")") {
      advance(st);
      return st.NIL;
    }
  }

  const first = read(st);
  const second = readList(st);
  return makePair(first, second);
}

function readString(st: State): Value {
  const start = st.inputPos;
  let c = peek(st);
  let isEscaped = false;
  while (isEscaped || c !== '"') {
    isEscaped = c == "\\";
    advance(st);
    c = peek(st);
  }
  let str = st.input.slice(start, st.inputPos);
  str = JSON.parse(`"${str}"`); // SORRY
  advance(st);
  return makeString(str);
}

/**
 * Print
 */

function print(st: State, value: Value) {
  st.io.std.printLine(toString(value));
}

function toString(value: Value): string {
  switch (value.tag) {
    case TAG.NIL:
      return "()";
    case TAG.ATOM:
      return value.atom;
    case TAG.NUM:
      return value.num.toString();
    case TAG.STRING:
      return value.str;
    case TAG.PAIR:
      return `(${toString(value.pair.car)}${listTailToString(value.pair.cdr)}`;
    case TAG.CLOS:
      return `CLOSURE<${toString(value.clos.body)}>`;
    case TAG.PRIM:
      return `PRIM<${value.prim.func.name || value.prim.func.toString()}>`;
    default:
      return "UNKNOWN_VALUE";
  }
}

function listTailToString(value: Value): string {
  switch (value.tag) {
    case TAG.NIL:
      return ")";
    case TAG.PAIR:
      return ` ${toString(value.pair.car)}${listTailToString(value.pair.cdr)}`;
    default:
      return ` . ${toString(value)})`;
  }
}

/**
 * Environment
 */

function envFind(env2: ListHead, key: Atom): Value {
  if (key.tag !== TAG.ATOM) {
    throw new Error("Expected 'key' to be an atom in envFind");
  }

  let env = env2.head;

  while (env.tag != TAG.NIL) {
    const row = car(env);
    if (key == car(row)) {
      return cdr(row);
    }
    env = cdr(env) as List;
  }

  throw new Error(
    `Failed to find '${key.atom || JSON.stringify(key)}' in environment`
  );
}

function envDefine(env: ListHead, key: Atom, value: Value) {
  env.head = makePair(makePair(key, value), env.head) as Pair;
}

function envDefinePrim(st: State, env: ListHead, name: string, f: PrimFunc) {
  return envDefine(env, intern(st, name) as Atom, makePrim(f));
}

/**
 * Value stack operations
 */

function push(st: State, value: Value) {
  st.stack = makePair(value, st.stack) as Pair;
}

function pop(st: State) {
  if (st.stack === st.NIL) {
    throw new Error("Value Stack underflow");
  }
  const top = car(st.stack);
  st.stack = cdr(st.stack) as Pair;
  return top;
}

/**
 * Eval
 */

function evaluate(st: State, env: ListHead, expr: Value): Value | void {
  if (DEBUG) {
    st.io.std.printLine(`eval: ${toString(expr)}`);
  }

  switch (expr.tag) {
    case TAG.ATOM: {
      const val = envFind(env, expr);
      switch (val.tag) {
        case TAG.CLOS:
        case TAG.PRIM:
          return val;
        default:
          return push(st, val);
      }
    }
    case TAG.NIL:
    case TAG.PAIR:
      return push(st, makeClos(expr, env.head));
    default:
      return push(st, expr);
  }
}

type Frame = [Value, ListHead];

async function compute(st: State, envSrc: ListHead, compSrc: Value) {
  if (DEBUG) {
    st.io.std.printLine(`compute: ${toString(compSrc)}`);
    st.io.std.printLine(`stack: ${toString(st.stack)}`);
  }

  const stack: Frame[] = [[compSrc, envSrc]];
  while (stack.length) {
    let [comp, env] = stack.pop()!;
    while (comp != st.NIL) {
      const cmd = car(comp);
      comp = cdr(comp);

      if (cmd == st.QUOTE) {
        if (comp == st.NIL) {
          throw new Error("Expected data following quote form");
        }

        push(st, car(comp));
        comp = cdr(comp);
        continue;
      }

      const conti = evaluate(st, env, cmd);
      if (conti && conti.tag == TAG.CLOS) {
        // tail call elimination
        if (comp != st.NIL) {
          stack.push([comp, env]);
        }

        stack.push([conti.clos.body, conti.clos.env]);
        break;
      } else if (conti && conti.tag == TAG.PRIM) {
        await conti.prim.func(st, env);
      }
    }
  }
}

/**
 * Primitives
 */

const PRIMITIVES: Record<string, PrimFunc> = {
  push: (st, env) => {
    push(st, envFind(env, pop(st) as Atom));
  },
  pop: (st, env) => {
    const k = pop(st) as Atom;
    const v = pop(st);
    envDefine(env, k, v);
  },
  "eq?": (st, _) => {
    push(st, valueEq(pop(st), pop(st)) ? st.TRUE : st.NIL);
  },
  cons: (st, _) => {
    const a = pop(st);
    const b = pop(st);
    push(st, makePair(a, b));
  },
  car: (st, _) => {
    push(st, car(pop(st)));
  },
  cdr: (st, _) => {
    push(st, cdr(pop(st)));
  },
  cswap: (st, _) => {
    if (pop(st) != st.NIL) {
      const a = pop(st);
      const b = pop(st);
      push(st, a);
      push(st, b);
    }
  },
  tag: (st, _) => {
    push(st, makeNum(pop(st).tag));
  },
  read: (st, _) => {
    push(st, read(st));
  },
  print: (st, _) => {
    print(st, pop(st));
  },
};

const EXTRA_PRIMITIVES: Record<string, PrimFunc> = {
  stack: (st, _) => {
    push(st, st.stack);
  },
  env: (st, env) => {
    push(st, env.head);
  },
  "#t": (st, _) => {
    push(st, st.TRUE);
  },
  "set!": async (st, env) => {
    const clos = pop(st);
    if (clos.tag !== TAG.CLOS) throw new Error("Operand must be a closure");
    await compute(st, clos.clos.env, clos.clos.body);
    const val = pop(st);
    const key = pop(st);
    if (key.tag !== TAG.ATOM) throw new Error("Operand must contain an atom");

    let pointer = env.head;
    while (pointer != st.NIL) {
      if (caar(pointer) == key) {
        let pair = car(pointer) as Pair;
        pair.pair.cdr = val;
        return;
      }
      pointer = cdr(pointer) as List;
    }
    throw new Error(`Cannot set unbound symbol "${key.atom}"`);
  },
  import: async (st, env) => {
    const oriEnv = env.head;
    const [importPath, refPath] = extractImportPath(st, env);
    try {
      const module = await st.io.file.read(importPath, refPath);

      st.input = module;
      st.inputPos = 0;
      const moduleObj = read(st);

      await compute(st, env, moduleObj);

      push(st, env.head);
    } catch (err) {
      st.io.std.printError(`Failed to import module "${importPath}"`);
      if (err instanceof Error) {
        st.io.std.printError(err.message);
      }
    } finally {
      env.head = oriEnv;
    }
  },
  "import*": async (st, env) => {
    const oriEnv = env.head;
    const [importPath, refPath] = extractImportPath(st, env);
    try {
      const module = await st.io.file.read(importPath, refPath);

      st.input = module;
      st.inputPos = 0;
      const moduleObj = read(st);
      await compute(st, env, moduleObj);
    } catch (err) {
      env.head = oriEnv;
      st.io.std.printError(`Failed to import module "${importPath}"`);
      if (err instanceof Error) {
        st.io.std.printError(err.message);
      }
    }
  },
  // "string-apply": (st, env) => {
  //   const args = pop(st);
  //   const method = pop(st);
  //   const s = pop(st);

  //   if (s.tag != TAG.STRING || method.tag != TAG.ATOM)
  //     throw new Error("Bad argument for string-apply");

  //   const s2 =
  //     args.tag == TAG.ATOM
  //       ? s.str[method.atom as any]
  //       : (s.str[method.atom as any] as any)(...listToArray(args));

  //   if (typeof s2 == "string") {
  //     push(st, makeString(s2));
  //   } else if (typeof s2 == "number") {
  //     push(st, makeNum(s2));
  //   }
  // },
};

const MATH_PRIMITIVES: Record<string, PrimFunc> = {
  "*": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) * toNumber(b)));
  },
  "/": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) / toNumber(b)));
  },
  "-": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) - toNumber(b)));
  },
  "+": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) + toNumber(b)));
  },
  "%": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) % toNumber(b)));
  },
  exp: (st, _) => {
    const a = pop(st);
    push(st, makeNum(Math.exp(toNumber(a))));
  },
  log: (st, _) => {
    const a = pop(st);
    push(st, makeNum(Math.log(toNumber(a))));
  },
  cos: (st, _) => {
    const a = pop(st);
    push(st, makeNum(Math.cos(toNumber(a))));
  },
  nand: (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(~(toNumber(a) & toNumber(b))));
  },
  ">>": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) >> toNumber(b)));
  },
  "<<": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) << toNumber(b)));
  },
  "gt?": (st, _) => {
    const b = pop(st);
    const a = pop(st);
    if (a.tag === TAG.STRING && b.tag === TAG.STRING) {
      push(st, a.str > b.str ? st.TRUE : st.NIL);
    } else {
      push(st, toNumber(a) > toNumber(b) ? st.TRUE : st.NIL);
    }
  },
  rand: (st, _) => {
    push(st, makeNum(Math.random()));
  },
  TAU: (st, _) => {
    push(st, makeNum(Math.PI * 2));
  },
};

function extractImportPath(st: State, env: ListHead) {
  const filePath = pop(st);
  if (filePath.tag !== TAG.STRING) {
    throw new Error("import expects a string operand");
  }

  const scriptPath = intern(st, "__script_path") as Atom;
  let importPath = filePath.str;
  let refPath = "";

  if (!importPath.endsWith(".fp")) {
    importPath = `${importPath}.fp`;
  }
  try {
    refPath = (envFind(env, scriptPath) as Atom).atom;
  } catch (err) {}

  envDefine(env, scriptPath, makeAtom(importPath));
  return [importPath, refPath];
}

/**
 * Interpreter
 */

export function setup(adapter: IO, inputProgram: string): State {
  const nil = makeNil() as List;
  const st: State = {
    input: inputProgram,
    inputPos: 0,

    readStack: [],
    stack: nil,
    env: { head: nil },

    internedAtoms: [],
    NIL: nil,
    TRUE: null as any,
    QUOTE: null as any,
    PUSH: null as any,
    POP: null as any,
    io: adapter,
  };

  st.TRUE = intern(st, "#t");
  st.QUOTE = intern(st, "quote");
  st.PUSH = intern(st, "push");
  st.POP = intern(st, "pop");

  for (let [k, v] of Object.entries(PRIMITIVES)) {
    envDefinePrim(st, st.env, k, v);
  }

  for (let [k, v] of Object.entries(EXTRA_PRIMITIVES)) {
    envDefinePrim(st, st.env, k, v);
  }

  for (let [k, v] of Object.entries(MATH_PRIMITIVES)) {
    envDefinePrim(st, st.env, k, v);
  }

  return st;
}

export async function run(st: State) {
  const obj = read(st);
  try {
    await compute(st, st.env, obj);
  } catch (err) {
    if (err instanceof Error) {
      st.io.std.printError(err.message);
      // console.error("stack", JSON.stringify(st.stack));
      // console.error("env", JSON.stringify(st.env));
      st.io.std.printError(err.stack ?? "");
    }
  }
}
