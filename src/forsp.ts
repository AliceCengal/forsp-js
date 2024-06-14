const TAG = {
  NIL: 0,
  ATOM: 1,
  NUM: 2,
  PAIR: 3,
  CLOS: 4,
  PRIM: 5,
} as const;

type Atom = { tag: 1; atom: string };

type Value =
  | { tag: 0 }
  | Atom
  | { tag: 2; num: number }
  | { tag: 3; pair: { car: Value; cdr: Value } }
  | { tag: 4; clos: { body: Value; env: Value } }
  | { tag: 5; prim: { func: (env: Value) => void } };

const FLAG_PUSH = 128;
const FLAG_POP = 129;

type State = {
  input: string;
  inputPos: number;

  readStack: Value[];
  stack: Value[];
  env: Value[];

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

function makePair(car: Value, cdr: Value): Value {
  return { tag: 3, pair: { car, cdr } };
}

function makeClos(body: Value, env: Value): Value {
  return { tag: 4, clos: { body, env } };
}

function makePrim(func: (env: Value) => void): Value {
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

function stackTop<T>(a: T[]) {
  return a[a.length - 1];
}
function stackPop<T>(a: T[]) {
  return a.pop();
}
function stackPush<T>(a: T[], aa: T) {
  a.push(aa);
}

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

const DIRECTIVES = ["'", "<", ">"];
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
  return st.NIL;
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

export function setup(inputProgram: string): State {
  const st: State = {
    input: inputProgram,
    inputPos: 0,

    readStack: [],
    stack: [],
    env: [],

    internedAtoms: [],
    NIL: makeNil(),
    TRUE: null as any,
    QUOTE: null as any,
    PUSH: null as any,
    POP: null as any,
  };

  st.TRUE = intern(st, "t");
  st.QUOTE = intern(st, "quote");
  st.PUSH = intern(st, "push");
  st.POP = intern(st, "pop");

  return st;
}

export function run(st: State) {
  console.log("runinng");
}
