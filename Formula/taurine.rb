class Taurine < Formula
  desc "Keep your Mac awake, with a reason (menu bar caffeine tool)"
  homepage "https://github.com/john-athan/taurine"
  url "https://github.com/john-athan/taurine/archive/refs/tags/v1.7.5.tar.gz"
  sha256 "244aef96d570d809b8b837c849f726e7b379b1e6fdd23e00de5ec7bb9d65f235"
  license "MIT"

  depends_on :macos

  def install
    # Builds Taurine.app from source with swiftc. No notarization needed: a
    # locally built app carries no quarantine flag, so no Gatekeeper prompt.
    system "./build.sh"
    # New tags build into build/, old ones at the repo root.
    prefix.install Dir["{build/,}Taurine.app"].first
    # Put a `taurine` shim on the PATH that runs the bundled binary.
    (bin/"taurine").write <<~SH
      #!/bin/bash
      app="/Applications/Taurine.app"
      [ -d "$app" ] || app="#{prefix}/Taurine.app"
      exec "$app/Contents/MacOS/taurine" "$@"
    SH
    (bin/"taurine").chmod 0755
    # Copies the app to /Applications and signs it with a certificate made on
    # this Mac, so macOS permissions survive an upgrade.
    libexec.install "tools/install-app.sh", "tools/sign-app.sh"
    (bin/"taurine-install").write <<~SH
      #!/bin/bash
      exec "#{libexec}/install-app.sh" "#{prefix}/Taurine.app" "$@"
    SH
    (bin/"taurine-install").chmod 0755
  end

  def caveats
    <<~EOS
      Launch the menu bar app:   taurine
      CLI:                       taurine why | on | off | toggle | -- <command>
      Lock the screen:           taurine lock | lockable on | lockable off

      Charge limiting moved into macOS 27 (System Settings > Battery). If an
      older Taurine installed its charge daemon, remove it from the menu.

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

      New in 1.6.0: "Let the screen lock (Mac keeps working)", off by default.
      Awake meant a lit screen only because Taurine held the display awake, and
      a display that never goes dark never reaches the idle lock. With the
      option on, Taurine holds the machine and not the screen, so your Mac
      locks on its usual schedule while builds, uploads and agents carry on
      behind the login window. "Lock the screen now" locks immediately without
      asking anything to sleep. Note that no assertion can refuse a sleep you
      asked for: the Apple menu, a closed lid and a power button set to sleep
      still sleep the Mac, so lock with ctrl-cmd-Q or with Taurine instead.

      The keyboard fixes need Accessibility. For that permission to survive
      upgrades, and for the "Start at login" toggle, install the app into
      /Applications, again after every upgrade:
        taurine-install
    EOS
  end

  test do
    assert_match "taurine", shell_output("#{bin}/taurine help")
  end
end
