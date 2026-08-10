class Taurine < Formula
  desc "Keep your Mac awake, with a reason (menu bar caffeine tool)"
  homepage "https://github.com/john-athan/taurine"
  url "https://github.com/john-athan/taurine/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "76585d73d5ff8117f3f27365db89e6a40eed85d8892652d1a1eb71652e13e826"
  license "MIT"

  depends_on :macos

  def install
    # Builds Taurine.app from source with swiftc (no notarization needed —
    # a locally built app carries no quarantine flag, so no Gatekeeper prompt).
    system "./build.sh"
    prefix.install "Taurine.app"
    # Put a `taurine` shim on the PATH that runs the bundled binary.
    (bin/"taurine").write <<~SH
      #!/bin/bash
      exec "#{prefix}/Taurine.app/Contents/MacOS/taurine" "$@"
    SH
    (bin/"taurine").chmod 0755
  end

  def caveats
    <<~EOS
      Launch the menu bar app:   taurine
      CLI:                       taurine why | on | off | toggle | -- <command>
      Charge limit:              taurine batt 80 | batt off | batt

      Charge limiting stops charging at a level you pick, to spare the battery.
      Enable it once from "Charge limit" in the menu; it installs a small root
      daemon and asks for admin once. `taurine batt unlock` is the escape hatch.

      New in 1.2.0: "What is this Mac doing?" opens an activity panel with
      per-cluster load and frequency, GPU, CPU/GPU/Neural Engine watts, memory
      and traffic. No password: the watts come from the chip's own energy
      counters, not from powermetrics. Nothing samples until you open it.

      Also new: "Things Apple got wrong", where scroll direction can follow the
      device (trackpads naturally, wheel mice the traditional way). Off by
      default; it needs Accessibility permission, and macOS grants that per
      binary, so it has to be granted again after every upgrade.

      For the "Start at login" toggle, also copy the app to /Applications:
        cp -R #{opt_prefix}/Taurine.app /Applications/
    EOS
  end

  test do
    assert_match "taurine", shell_output("#{bin}/taurine help")
  end
end
