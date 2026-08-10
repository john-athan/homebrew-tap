# Third-party material in this tap

This repository holds Homebrew formulas and nothing else. The formulas were
written for this tap and are MIT licensed (see [`LICENSE`](LICENSE)).

## What the formulas install

Each formula builds a project from its own source tarball. That project carries
its own license and its own third-party notices, which travel inside the tarball
Homebrew downloads:

| Formula | Project | License | Notices |
| --- | --- | --- | --- |
| `sucher` | [john-athan/sucher](https://github.com/john-athan/sucher) | MIT | `THIRD_PARTY.md`, `THIRD_PARTY_LICENSES.md` |
| `taurine` | [john-athan/taurine](https://github.com/john-athan/taurine) | MIT | `THIRD_PARTY.md` |

Nothing is repackaged or mirrored here, so no notice obligation lands on this
repository. The formulas name build and runtime dependencies (`rust`, `ffmpeg`,
`poppler`) for Homebrew to resolve from its own taps; they are not redistributed
by this one.

## Homebrew itself

The formula DSL (`class ... < Formula`, `depends_on`, `test do`) is Homebrew's
interface, used as intended. Homebrew is BSD-2-Clause and is not included here.
