# Package

version       = "1.1.0"
author        = "jiro4989"
description   = "nmi display animations aimed to correct users who accidentally enter nmi instead of nim."
license       = "MIT"
srcDir        = "src"
bin           = @["nmi"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.0.6"

import os, strformat

task archive, "Create archived assets":
  let app = "nmi"
  let assets = &"{app}_{buildOS}"
  let dir = "dist"/assets
  mkDir dir
  cpDir "bin", dir/"bin"
  cpFile "LICENSE", dir/"LICENSE"
  cpFile "README.rst", dir/"README.rst"
  withDir "dist":
    when buildOS == "windows":
      exec &"7z a {assets}.zip {assets}"
    else:
      exec &"tar czf {assets}.tar.gz {assets}"
