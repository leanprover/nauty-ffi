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

/-- A three-vertex path with a single colour cell. -/
def path : Graph where
  colorCount := 1
  colors := #[0, 0, 0]
  adjacency := #[
    #[false, true, false],
    #[true, false, true],
    #[false, true, false]
  ]

/-- The same path after exchanging its centre and final vertices. -/
def relabelledPath : Graph where
  colorCount := 1
  colors := #[0, 0, 0]
  adjacency := #[
    #[false, false, true],
    #[false, false, true],
    #[true, true, false]
  ]

private def orThrow : Except String α → IO α
  | .ok value => pure value
  | .error message => throw <| IO.userError message

/-- Run a canonical-labelling and isomorphism example using all three public
operations. -/
def run : IO Unit := do
  let canonical ← orThrow (canonicalize path)
  let transporter ← orThrow (findIso path relabelledPath)
  let isomorphic ← orThrow (isIso path relabelledPath)
  IO.println s!"canonical form: {repr canonical.form}"
  IO.println s!"transporter: {repr transporter}"
  IO.println s!"isomorphic: {isomorphic}"
  if !isomorphic || transporter.isNone then
    throw <| IO.userError "expected the two paths to be isomorphic"

end NautyFFI.Example

/-- Command-line entry point for the basic `nauty-ffi` example. -/
def main : IO Unit := NautyFFI.Example.run
