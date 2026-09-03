/-
Copyright (c) 2026 Lean FRO, LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/

import VersoManual
import NautyFFI

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

set_option pp.rawOnError true

#doc (Manual) "nauty-ffi" =>
%%%
authors := ["Kim Morrison"]
%%%

`nauty-ffi` is a small, unverified Lean interface to the dense canonical-
labelling surface of nauty 2.9.3. It supports vertex-coloured undirected simple
graphs, canonical forms, and the derived coloured-graph isomorphism test.

{docstring NautyFFI.Graph}

{docstring NautyFFI.CanonicalForm}

{docstring NautyFFI.CanonResult}

# Canonical labelling and isomorphism

The following three-vertex paths differ only by a vertex relabelling. Calling
`canonicalize` produces the canonical form; `findIso` returns a forward vertex
transporter; and `isIso` performs the corresponding Boolean test.

```lean
open NautyFFI

def path : Graph where
  colorCount := 1
  colors := #[0, 0, 0]
  adjacency := #[
    #[false, true, false],
    #[true, false, true],
    #[false, true, false]
  ]

def relabelledPath : Graph where
  colorCount := 1
  colors := #[0, 0, 0]
  adjacency := #[
    #[false, false, true],
    #[false, false, true],
    #[true, true, false]
  ]

#eval canonicalize path
#eval findIso path relabelledPath
#eval isIso path relabelledPath
```

The repository also builds this as a runnable example:

```
lake exe nautyffi_example
```

{docstring NautyFFI.canonicalize}

{docstring NautyFFI.findIso}

{docstring NautyFFI.isIso}

# Trust and scope

The results come from native C code and carry no proof. Use
[`hex-graph-iso`](https://github.com/leanprover/hex-graph-iso) when the verified
Lean surface is required. Sparse nauty, Traces, digraphs, and automorphism-group
output are intentionally outside this package's scope.
