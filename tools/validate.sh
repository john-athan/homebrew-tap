#!/bin/sh
# Every check this tap has. CI calls this file and nothing else, and so does
# `oss check homebrew-tap` before a formula change is pushed.
set -eu
cd "$(dirname "$0")/.."
brew style --except-cops FormulaAudit/Text Formula/*.rb
# The audit reads the formulas through the tapped copy, so it only sees what
# is in this checkout when the tap is this checkout. CI taps it that way; here
# it runs only if the local tap points at this directory.
tap="$(brew --repository)/Library/Taps/john-athan/homebrew-tap"
if [ "$(cd "$tap" 2>/dev/null && pwd -P)" = "$(pwd -P)" ] || [ -n "${CI:-}" ]; then
  brew audit --strict --tap john-athan/homebrew-tap --formula
else
  echo "brew audit skipped: the installed tap is not this checkout"
fi
