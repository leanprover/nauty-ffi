/-
Copyright (c) 2026 Lean FRO, LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/

import VersoManual
import NautyFFIManual

open Verso.Genre Manual

/-- Render the `nauty-ffi` manual as multi-page HTML. -/
def config : RenderConfig where
  emitTeX := false
  emitHtmlSingle := .no
  emitHtmlMulti := .immediately
  htmlDepth := 2

/-- Entry point for the `nautyffi_manual` documentation executable. -/
def main := manualMain (%doc NautyFFIManual) (config := config)
