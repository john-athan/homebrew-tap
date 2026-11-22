class Sesam < Formula
  desc "One search bar over 1Password, KeePassXC and the Apple Keychain"
  homepage "https://github.com/john-athan/sesam"
  url "https://github.com/john-athan/sesam/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "70fd54de41f8fba5e5790fc777e833dd4d93fbe76a6b7c3d355d363c1cabbdb4"
  license "MIT"

  depends_on :macos

  def install
    # Builds Sesam.app from source with swiftc. No notarization needed: a
    # locally built app carries no quarantine flag, so no Gatekeeper prompt.
    system "./build.sh"
    prefix.install "build/Sesam.app"
    # Put a `sesam` shim on the PATH that runs the bundled binary.
    (bin/"sesam").write <<~SH
      #!/bin/bash
      exec "#{prefix}/Sesam.app/Contents/MacOS/sesam" "$@"
    SH
    (bin/"sesam").chmod 0755
  end

  def caveats
    <<~EOS
      Launch the menu bar app:   sesam
      Open the search panel:     Option-Space, or sesam search
      CLI:                       sesam status | index | lock | help

      Sesam has to live in /Applications for "Launch at login", and without
      that the hotkey is gone after the next restart:
        cp -R #{opt_prefix}/Sesam.app /Applications/

      The vaults are separate programs, installed separately and optional:
        1Password   brew install 1password-cli, then "Integrate with
                    1Password CLI" in the desktop app's Developer settings
        KeePassXC   brew install --cask keepassxc, for keepassxc-cli
      The Apple Keychain works without either.

      Enter pastes into the app you came from, which needs Accessibility.
      macOS grants it per binary, so after every upgrade remove Sesam from
      the Accessibility list with the minus button and allow it again.
      Copying (cmd-C) needs no permission at all.
    EOS
  end

  test do
    assert_match "sesam status", shell_output("#{bin}/sesam help")
  end
end
