module

public import Lake

public section

open System Lake DSL

package NautyFFI where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

private def nautyVendorOTarget (pkg : Package) (src : String) :
    FetchM (Job FilePath) := do
  let stem := (src.dropEnd 2).toString
  let object := pkg.dir / defaultBuildDir / "vendor" / "nauty-2.9.3" /
    s!"{stem}.o"
  let source ← inputTextFile <| pkg.dir / "vendor" / "nauty-2.9.3" / src
  buildFileAfterDep object source fun sourceFile => do
    compileO object sourceFile #[
      "-I", (pkg.dir / "vendor" / "nauty-2.9.3").toString,
      "-fPIC", "-O2", "-std=c11", "-DUSE_TLS"]

private def nautyBridgeOTarget (pkg : Package) : FetchM (Job FilePath) := do
  let object := pkg.dir / defaultBuildDir / "NautyFFI" / "ffi" /
    "lean_nauty.o"
  let source ← inputTextFile <| pkg.dir / "NautyFFI" / "ffi" /
    "lean_nauty.c"
  buildFileAfterDep object source fun sourceFile => do
    compileO object sourceFile #[
      "-I", (← getLeanIncludeDir).toString,
      "-I", (pkg.dir / "vendor" / "nauty-2.9.3").toString,
      "-fPIC", "-O2", "-std=c11", "-DUSE_TLS"]

extern_lib nautyffi (pkg) := do
  let name := nameToStaticLib "nautyffi"
  let vendorObjects ← #["nauty.c", "nautil.c", "naugraph.c", "schreier.c",
    "naurng.c"].mapM (nautyVendorOTarget pkg)
  let bridgeObject ← nautyBridgeOTarget pkg
  buildStaticLib (pkg.staticLibDir / name) (vendorObjects.push bridgeObject)

@[default_target]
lean_lib NautyFFI where
  precompileModules := true

lean_exe nautyffi_tests where
  root := `NautyFFI.Tests

