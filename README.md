# forsp-js

Forsp interpreter in Typescript. Initial version is a direct port from
[the original written in C](https://github.com/xorvoid/forsp).

## Immediate goal

To be able to solve [Project Euler](https://projecteuler.net/) problems
comfortably with Forsp. This requires extending the interpreter implementation
and adding a standard library with at least the following features:

- data structures and their associated methods:
  - string
  - list
  - dictionary
- module import
- Complete math operations
- random number generator
- functions for sort, filter, map, group, transpose

In keeping with the minimalist principle of Forsp, these features would mostly
be implemented in Forsp as a standard library, extending the interpreter only
where absolutely necessary.

## Usage

### As an interpreter

Make sure `npm` and `node` is installed on your system. To build

```
npm run build
```

To execute code directly in the commandline

```
node ./dist/index.js --raw "( 3 4 + 7 eq print )"
```

To execute a Forsp script file

```
node ./dist/index.js ./data/tutorial.fp
```

You can also use the web app interpreter at
https://alicecengal.github.io/forsp-web/

### As a library

The core library is in `src/forsp`. The module exposes the following members:

`function setup(adapter: IO, inputProgram: string): State`. `adapter` is an
object that contains the IO functions for the interpreter to use.
`inputProgram` must be a valid Forsp program. It returns an object that holds
the state of the Forsp program execution. The `State` object is not part of the
public interface, so I can't guarantee that its structure will stay the same
as this project evolves.

`function run(st: State)`. Takes the object returned by `setup` and begins
execution of the program

`type IO`. An adapter object that holds the IO functions used by the interpreter.
