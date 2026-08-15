class Taurine < Formula
  desc "Keep your Mac awake, with a reason (menu bar caffeine tool)"
  homepage "https://github.com/john-athan/taurine"
  url "https://github.com/john-athan/taurine/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "75262cb507e538ec8801cc9f28cb8e1dcd54571ec6ca79f4be56784ce75bc019"
  license "MIT"

  depends_on :macos

  def install
    # Builds Taurine.app from source with swiftc. No notarization needed: a
    # locally built app carries no quarantine flag, so no Gatekeeper prompt.
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

      "What is this Mac doing?" opens an activity panel with per-cluster load
      and frequency, GPU, CPU/GPU/Neural Engine watts, battery, memory and
      traffic. No password: the watts come from the chip's own energy counters,
      not from powermetrics. Nothing samples until you open it.

      "Things Apple got wrong" is a shelf of small fixes, all off by default:
        scroll direction follows the device, not the whole Mac
        cmd-X / cmd-V cut and paste files in Finder
        Delete moves files to the Trash
        Return opens files, cmd-Return renames them
        shift-cmd-V pastes as plain text in every application

      New in 1.5.0: the battery tile in that panel. How full the cell is,
      which way the energy is moving and how fast, how long the gauge thinks
      that leaves, and what the adapter is delivering against what it is rated
      for. Read from the battery gauge in the IO registry, never from an
      undocumented SMC key. A Mac with no battery simply has no battery tile.

      The keyboard fixes need Accessibility, which macOS grants per binary, so
      after every upgrade remove Taurine from the Accessibility list with the
      minus button and add it back. shift-cmd-V is the exception: it writes a
      system preference rather than watching the keyboard, so it survives an
      upgrade untouched.

      For the "Start at login" toggle, also copy the app to /Applications:
        cp -R #{opt_prefix}/Taurine.app /Applications/
    EOS
  end

  test do
    assert_match "taurine", shell_output("#{bin}/taurine help")
  end
end
