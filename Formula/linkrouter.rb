class Linkrouter < Formula
  desc "Default browser that picks the browser and profile by the folder you clicked in"
  homepage "https://github.com/john-athan/linkrouter"
  url "https://github.com/john-athan/linkrouter/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "9f4e2d6ed50c6668981cab2f52eee07c42d7b45dfb14ef9e86b595780cb6b7c1"
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
      exec "#{prefix}/Linkrouter.app/Contents/MacOS/linkrouter" "$@"
    SH
    (bin/"linkrouter").chmod 0755
  end

  def caveats
    <<~EOS
      Linkrouter has to live in /Applications, because the default browser
      and the Accessibility grant are both tied to where the app is:

        cp -R #{opt_prefix}/Linkrouter.app /Applications/
        mkdir -p ~/.config/linkrouter && cp -n #{opt_pkgshare}/rules.example ~/.config/linkrouter/rules
        /Applications/Linkrouter.app/Contents/MacOS/linkrouter --set-default

      Then edit ~/.config/linkrouter/rules, open a link once, and allow
      Linkrouter under System Settings > Privacy & Security > Accessibility.
      After every upgrade, copy the app again, remove Linkrouter from the
      Accessibility list with the minus button, and allow it again.

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
