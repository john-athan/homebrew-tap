# Third-party material in this tap

This repository holds Homebrew formulas and nothing else. The formulas were
written for this tap and are MIT licensed (see [`LICENSE`](LICENSE)).

## What the formulas install

Each formula builds a project from its own source tarball. That project carries
its own license and its own third-party notices, which travel inside the tarball
Homebrew downloads:

| Formula | Project | License | Notices in the tarball |
| --- | --- | --- | --- |
| `sucher` | [john-athan/sucher](https://github.com/john-athan/sucher) | MIT | `THIRD_PARTY.md`, `THIRD_PARTY_LICENSES.md`, from v0.6.2 |
| `taurine` | [john-athan/taurine](https://github.com/john-athan/taurine) | MIT | none needed: no dependencies, nothing is linked in |

sucher links its Rust dependencies statically, so the installed binary contains
their code and carries their notice requirements. The formula therefore installs
`THIRD_PARTY_LICENSES.md` into `share/doc/sucher` alongside it. Leaving it in the
build directory, which Homebrew deletes, would have satisfied the requirement on
paper only.

taurine has no dependencies at all: it builds against Apple's SDK frameworks,
which are not redistributed. There is nothing to notice.

Nothing is repackaged or mirrored here, so no notice obligation lands on this
repository itself. The formulas name build and runtime dependencies (`rust`,
`ffmpeg`, `poppler`) for Homebrew to resolve from its own taps; they are not
redistributed by this one.

## Homebrew itself

The formula DSL (`class ... < Formula`, `depends_on`, `test do`) is Homebrew's
interface, used as intended. Homebrew is BSD-2-Clause and is not included here.
