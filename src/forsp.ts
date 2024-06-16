/**
 * Forsp interpreter.
 * The original version was ported from the C version written by xorvoid.
 */

const DEBUG: boolean = false;
const TOKEN_PUSH = "<";
const TOKEN_POP = ">";
const TOKEN_QUOTE = "'";

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
type PrimFunc = (st: State, env: ListHead) => void;
type Value =
  | Nil
  | Atom
  | { tag: 2; num: number }
  | { tag: 6; str: string }
  | Pair
  | { tag: 4; clos: { body: Value; env: ListHead } }
  | { tag: 5; prim: { func: PrimFunc } };

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

function valueEq(v1: Value, v2: Value) {
  return (
    v1 == v2 || (v1.tag === TAG.NUM && v2.tag === TAG.NUM && v1.num === v2.num)
  );
}

function toNumber(v: Value) {
  return v.tag === TAG.NUM ? v.num : NaN;
}

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

const DIRECTIVES = [TOKEN_POP, TOKEN_PUSH, TOKEN_QUOTE];
const PUNCTUATION = ["(", ")", ";"];

function isDirective(s: string) {
  return DIRECTIVES.includes(s);
}

function isPunctuation(s: string) {
  return isWhitespace(s) || isDirective(s) || PUNCTUATION.includes(s);
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

  if (c === TOKEN_QUOTE) {
    advance(st);
    return st.QUOTE;
  }

  if (c === TOKEN_PUSH) {
    advance(st);
    st.readStack.push(st.PUSH, readScalar(st), st.QUOTE);
    return read(st);
  }

  if (c === TOKEN_POP) {
    advance(st);
    st.readStack.push(st.POP, readScalar(st), st.QUOTE);
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
  str = JSON.parse(`["${str}"]`)[0]; // SORRY
  advance(st);
  return makeString(str);
}

/**
 * Print
 */

function print(value: Value) {
  console.log(printRecurse(value));
}

function printRecurse(value: Value): string {
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
      return `(${printRecurse(value.pair.car)}${printListTail(value.pair.cdr)}`;
    case TAG.CLOS:
      return `CLOSURE<${printRecurse(value.clos.body)}>`;
    case TAG.PRIM:
      return `PRIM<${value.prim.func.name || value.prim.func.toString()}>`;
    default:
      return "UNKNOWN_VALUE";
  }
}

function printListTail(value: Value): string {
  switch (value.tag) {
    case TAG.NIL:
      return ")";
    case TAG.PAIR:
      return ` ${printRecurse(value.pair.car)}${printListTail(value.pair.cdr)}`;
    default:
      return ` . ${printRecurse(value)})`;
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

function evaluate(st: State, env: ListHead, expr: Value) {
  if (DEBUG) {
    console.log(`eval: ${printRecurse(expr)}`);
  }

  switch (expr.tag) {
    case TAG.ATOM: {
      const val = envFind(env, expr);
      switch (val.tag) {
        case TAG.CLOS:
          return compute(st, val.clos.env, val.clos.body);
        case TAG.PRIM:
          return val.prim.func(st, env);
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

function compute(st: State, env: ListHead, compSrc: Value) {
  if (DEBUG) {
    console.log(`compute: ${printRecurse(compSrc)}`);
    console.log(`stack: ${printRecurse(st.stack)}`);
  }

  let comp = compSrc;
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

    evaluate(st, env, cmd);
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
  eq: (st, env) => {
    push(st, valueEq(pop(st), pop(st)) ? st.TRUE : st.NIL);
  },
  cons: (st, env) => {
    const a = pop(st);
    const b = pop(st);
    push(st, makePair(a, b));
  },
  car: (st, env) => {
    push(st, car(pop(st)));
  },
  cdr: (st, env) => {
    push(st, cdr(pop(st)));
  },
  cswap: (st, env) => {
    if (pop(st) == st.TRUE) {
      const a = pop(st);
      const b = pop(st);
      push(st, a);
      push(st, b);
    }
  },
  tag: (st, env) => {
    push(st, makeNum(pop(st).tag));
  },
  read: (st, env) => {
    push(st, read(st));
  },
  print: (st, env) => {
    print(pop(st));
  },
};

const EXTRA_PRIMITIVES: Record<string, PrimFunc> = {
  "dump-stack": (st, env) => {
    const dump: Value[] = [];
    let pointer = st.stack;
    while (pointer != st.NIL) {
      dump.push(car(pointer));
      pointer = cdr(pointer) as List;
    }
    const dumpStr = dump.reduceRight(
      (cumm, curr) =>
        cumm ? `${cumm} , ${printRecurse(curr)}` : printRecurse(curr),
      ""
    );
    console.log(`[ ${dumpStr} ]`);
  },
  "*": (st, env) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) * toNumber(b)));
  },
  "/": (st, env) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) / toNumber(b)));
  },
  "-": (st, env) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) - toNumber(b)));
  },
  "+": (st, env) => {
    const b = pop(st);
    const a = pop(st);
    push(st, makeNum(toNumber(a) + toNumber(b)));
  },
};

/**
 * Interpreter
 */

export function setup(inputProgram: string): State {
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
  };

  st.TRUE = intern(st, "t");
  st.QUOTE = intern(st, "quote");
  st.PUSH = intern(st, "push");
  st.POP = intern(st, "pop");

  for (let [k, v] of Object.entries(PRIMITIVES)) {
    envDefinePrim(st, st.env, k, v);
  }

  for (let [k, v] of Object.entries(EXTRA_PRIMITIVES)) {
    envDefinePrim(st, st.env, k, v);
  }

  return st;
}

export function run(st: State) {
  const obj = read(st);
  try {
    compute(st, st.env, obj);
  } catch (err) {
    if (err instanceof Error) {
      console.error(err.message);
      // console.error("stack", JSON.stringify(st.stack));
      // console.error("env", JSON.stringify(st.env));
      console.error(err.stack);
    }
  }
}
