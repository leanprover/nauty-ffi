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

# The Petersen graph in two presentations

The Petersen graph is a useful first nontrivial example. The first graph below
is the generalized Petersen presentation `G(5, 2)`: an outer pentagon `0..4`,
an inner five-point star `5..9`, and five spokes. The second is the Kneser
presentation `K(5, 2)`, whose vertices are the two-element subsets
`01 02 03 04 12 13 14 23 24 34` of a five-element set and whose edges join
disjoint subsets.

```lean
open NautyFFI

namespace NautyFFIManualExample

def oneColorGraph (vertexCount : Nat)
    (edges : Array (Nat × Nat)) : Graph where
  colorCount := if vertexCount = 0 then 0 else 1
  colors := Array.replicate vertexCount 0
  adjacency := Id.run do
    let mut matrix := Array.replicate vertexCount
      (Array.replicate vertexCount false)
    for (u, v) in edges do
      matrix := matrix.set! u (matrix[u]!.set! v true)
      matrix := matrix.set! v (matrix[v]!.set! u true)
    return matrix

def petersen : Graph := oneColorGraph 10
  #[(0, 1), (1, 2), (2, 3), (3, 4), (0, 4),
    (5, 7), (7, 9), (6, 9), (6, 8), (5, 8),
    (0, 5), (1, 6), (2, 7), (3, 8), (4, 9)]

def kneser52 : Graph := oneColorGraph 10
  #[(0, 7), (0, 8), (0, 9), (1, 5), (1, 6),
    (1, 9), (2, 4), (2, 6), (2, 8), (3, 4),
    (3, 5), (3, 7), (4, 9), (5, 8), (6, 7)]

def prism5 : Graph := oneColorGraph 10
  #[(0, 1), (1, 2), (2, 3), (3, 4), (0, 4),
    (5, 6), (6, 7), (7, 8), (8, 9), (5, 9),
    (0, 5), (1, 6), (2, 7), (3, 8), (4, 9)]

-- Both presentations have the same canonical form.
-- Their labellings show how each input was placed into it.
#eval do
  let p ← canonicalize petersen
  let k ← canonicalize kneser52
  pure (p.form == k.form, p.labelling, k.labelling)

-- `transporter[i]` is the Kneser vertex corresponding to
-- Petersen vertex `i`.
#eval findIso petersen kneser52

#eval isIso petersen kneser52

-- The pentagonal prism is also cubic on ten vertices,
-- but is not isomorphic to the Petersen graph.
#eval isIso petersen prism5

end NautyFFIManualExample
```

The first result reports equal canonical forms and displays the two canonical
labellings. `findIso` returns their derived forward transporter. The two
Boolean calls distinguish the isomorphic presentations from the superficially
similar prism.

The repository builds the same comparison as a runnable example:

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
