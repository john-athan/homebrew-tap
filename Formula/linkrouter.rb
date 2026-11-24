class Linkrouter < Formula
  desc "Default browser that picks the browser and profile by the folder you clicked in"
  homepage "https://github.com/john-athan/linkrouter"
  url "https://github.com/john-athan/linkrouter/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "4e34cf7dba58eda801fc9347e0f774198e38e6ecec12359ada377a5a76a0d3b4"
  license "MIT"

  depends_on :macos

  def install
    # Builds Linkrouter.app from source with swiftc. A locally built app
    # carries no quarantine flag, so there is no Gatekeeper prompt.
    system "./build.sh"
    prefix.install Dir["{build/,}Linkrouter.app"].first
    pkgshare.install "rules.example"
    (bin/"linkrouter").write <<~SH
      #!/bin/bash
      app="/Applications/Linkrouter.app"
      [ -d "$app" ] || app="#{prefix}/Linkrouter.app"
      exec "$app/Contents/MacOS/linkrouter" "$@"
    SH
    (bin/"linkrouter").chmod 0755
    # Copies the app to /Applications and signs it with a certificate made on
    # this Mac, so macOS permissions survive an upgrade.
    libexec.install "tools/install-app.sh", "tools/sign-app.sh"
    (bin/"linkrouter-install").write <<~SH
      #!/bin/bash
      exec "#{libexec}/install-app.sh" "#{prefix}/Linkrouter.app" "$@"
    SH
    (bin/"linkrouter-install").chmod 0755
  end

  def caveats
    <<~EOS
      Linkrouter has to live in /Applications, because the default browser
      and the Accessibility grant are both tied to where the app is:

        linkrouter-install
        mkdir -p ~/.config/linkrouter && cp -n #{opt_pkgshare}/rules.example ~/.config/linkrouter/rules
        /Applications/Linkrouter.app/Contents/MacOS/linkrouter --set-default

      Then edit ~/.config/linkrouter/rules, open a link once, and allow
      Linkrouter under System Settings > Privacy & Security > Accessibility.
      After every upgrade, run linkrouter-install again. The permission stays.

      Upgrading from 1.0.0: remove ~/Applications/Linkrouter.app. The
      default browser follows the copy in /Applications.

      Which rule a folder gets:  linkrouter --which ~/some/folder
    EOS
  end

  test do
    (testpath/"rules").write "#{testpath}/work  Google Chrome: Work\n*  Safari\n"
    ENV["LINKROUTER_RULES"] = testpath/"rules"
    ENV["LINKROUTER_LOG"] = testpath/"log"
    assert_match "-> Google Chrome: Work", shell_output("#{bin}/linkrouter --which #{testpath}/work/x")
    assert_match "* -> Safari", shell_output("#{bin}/linkrouter --which /tmp")
  end
end
