/-
Copyright (c) 2026 Lean FRO, LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/

module

public import NautyFFI

public section

open NautyFFI

namespace NautyFFI.Example

private def oneColorGraph (vertexCount : Nat)
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

/-- The Petersen graph in its generalized Petersen `G(5, 2)` presentation. -/
def petersen : Graph := oneColorGraph 10
  #[(0, 1), (1, 2), (2, 3), (3, 4), (0, 4),
    (5, 7), (7, 9), (6, 9), (6, 8), (5, 8),
    (0, 5), (1, 6), (2, 7), (3, 8), (4, 9)]

/-- The Petersen graph in its Kneser `K(5, 2)` presentation. -/
def kneser52 : Graph := oneColorGraph 10
  #[(0, 7), (0, 8), (0, 9), (1, 5), (1, 6),
    (1, 9), (2, 4), (2, 6), (2, 8), (3, 4),
    (3, 5), (3, 7), (4, 9), (5, 8), (6, 7)]

/-- The pentagonal prism, a nonisomorphic cubic graph on ten vertices. -/
def prism5 : Graph := oneColorGraph 10
  #[(0, 1), (1, 2), (2, 3), (3, 4), (0, 4),
    (5, 6), (6, 7), (7, 8), (8, 9), (5, 9),
    (0, 5), (1, 6), (2, 7), (3, 8), (4, 9)]

private def orThrow : Except String α → IO α
  | .ok value => pure value
  | .error message => throw <| IO.userError message

/-- Compare the Petersen graph's generalized-Petersen and Kneser presentations
and contrast them with the pentagonal prism. -/
def run : IO Unit := do
  let petersenCanon ← orThrow (canonicalize petersen)
  let kneserCanon ← orThrow (canonicalize kneser52)
  let transporter ← orThrow (findIso petersen kneser52)
  let isomorphic ← orThrow (isIso petersen kneser52)
  let prismIsomorphic ← orThrow (isIso petersen prism5)
  IO.println s!"canonical forms equal: {petersenCanon.form == kneserCanon.form}"
  IO.println s!"transporter: {repr transporter}"
  IO.println s!"Petersen ≅ Kneser: {isomorphic}"
  IO.println s!"Petersen ≅ prism: {prismIsomorphic}"
  if petersenCanon.form != kneserCanon.form || !isomorphic ||
      transporter.isNone || prismIsomorphic then
    throw <| IO.userError "unexpected Petersen comparison result"

end NautyFFI.Example

/-- Command-line entry point for the Petersen-graph `nauty-ffi` example. -/
def main : IO Unit := NautyFFI.Example.run
