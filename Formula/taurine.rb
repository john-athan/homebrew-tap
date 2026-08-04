class Taurine < Formula
  desc "Keep your Mac awake, with a reason (menu bar caffeine tool)"
  homepage "https://github.com/john-athan/taurine"
  url "https://github.com/john-athan/taurine/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "eb024415aa643fd0eaca05629f21fc1e8c684a16047e568f560035f7c2ee237c"
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

      For the "Start at login" toggle, also copy the app to /Applications:
        cp -R #{opt_prefix}/Taurine.app /Applications/
    EOS
  end

  test do
    assert_match "taurine", shell_output("#{bin}/taurine help")
  end
end
