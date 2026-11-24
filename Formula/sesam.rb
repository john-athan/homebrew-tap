class Sesam < Formula
  desc "One search bar over 1Password, KeePassXC and the Apple Keychain"
  homepage "https://github.com/john-athan/sesam"
  url "https://github.com/john-athan/sesam/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "9f6eb2ff7ad4b8e4f9b95add854b5abb22d17453645d72e4e7a84324ce2a133d"
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
      app="/Applications/Sesam.app"
      [ -d "$app" ] || app="#{prefix}/Sesam.app"
      exec "$app/Contents/MacOS/sesam" "$@"
    SH
    (bin/"sesam").chmod 0755
    # Copies the app to /Applications and signs it with a certificate made on
    # this Mac, so macOS permissions survive an upgrade.
    libexec.install "tools/install-app.sh", "tools/sign-app.sh"
    (bin/"sesam-install").write <<~SH
      #!/bin/bash
      exec "#{libexec}/install-app.sh" "#{prefix}/Sesam.app" "$@"
    SH
    (bin/"sesam-install").chmod 0755
  end

  def caveats
    <<~EOS
      Launch the menu bar app:   sesam
      Open the search panel:     Option-Space, or sesam search
      CLI:                       sesam status | index | lock | help

      Sesam has to live in /Applications for "Launch at login", and without
      that the hotkey is gone after the next restart:
        sesam-install
      Run it again after every upgrade.

      The vaults are separate programs, installed separately and optional:
        1Password   brew install 1password-cli, then "Integrate with
                    1Password CLI" in the desktop app's Developer settings
        KeePassXC   brew install --cask keepassxc, for keepassxc-cli
      The Apple Keychain works without either.

      Enter pastes into the app you came from, which needs Accessibility.
      Installed with sesam-install, the permission survives upgrades.
      Copying (cmd-C) needs no permission at all.
    EOS
  end

  test do
    assert_match "sesam status", shell_output("#{bin}/sesam help")
  end
end
