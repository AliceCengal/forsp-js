# forsp-js

Forsp interpreter in Typescript. Initial version is a direct port from [the original written in C](https://github.com/xorvoid/forsp).

## Immediate goal

To be able to solve [Project Euler](https://projecteuler.net/) problems comfortably with Forsp.
This requires extending the interpreter implementation and adding a standard library with at least the following features:

 - data structures and their associated methods:
   - string
   - list
   - dictionary
 - module import
 - Complete math operations
 - random number generator
 - functions for sort, filter, map, group, transpose

In keeping with the minimalist principle of Forsp, these features would mostly be implemented in Forsp as a standard library, 
extending the interpreter only where absolutely necessary.
