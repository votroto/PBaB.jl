# PBaB

For when you need to branch and bound in parallel.

> For parallel execution, start Julia with the -t flag.

## Usage

Given functions

 - `bound :: Node -> lower_bound, feasible_value, feasible_cut`,
 - `branch :: Node -> Node[]`,

a root `Node`, and a `gap`, PBaB will branch and bound in parallel using a best-first strategy. PBaB stops when it finds a feasible solution with a value within `gap` of the *glabal minimum*.

## Experimental!

This package is in very early stages of development. Feel free to open issues. Any help is appreciated.