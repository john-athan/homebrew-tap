class Sucher < Formula
  desc "Fast terminal viewer and browser for markdown, sheets, PDF, images, video"
  homepage "https://github.com/john-athan/sucher"
  url "https://github.com/john-athan/sucher/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "99fe4e57fe9d2b4eb072f060e3b86fb8ae5aa91db5d9e4d355fd13fd3515bace"
  license "MIT"

  depends_on "rust" => :build
  # Both are optional to sucher at runtime, and declared here so the formats
  # that shell out just work. PDF pages come from the libpdfium the build
  # embeds; poppler is the fallback for that and still powers pdfinfo/pdftotext.
  depends_on "ffmpeg"  # video playback (ffmpeg / ffprobe)
  depends_on "poppler" # PDF fallback (pdftocairo / pdfinfo / pdftotext)

  def install
    system "cargo", "install", *std_cargo_args
    # The binary links its dependencies statically, so it carries their notice
    # requirements wherever it lands. Install the notices next to it rather than
    # leaving them behind in a build directory Homebrew deletes.
    doc.install "LICENSE", "THIRD_PARTY.md", "THIRD_PARTY_LICENSES.md", "CHANGELOG.md"
  end

  def caveats
    <<~EOS
      For pixel-perfect images, PDF and video, use a terminal with a graphics
      protocol: kitty, ghostty, WezTerm, iTerm2, or anything sixel-capable.
      Elsewhere sucher falls back to Unicode half-blocks.

      Third-party notices for the statically linked dependencies:
        #{opt_prefix}/share/doc/sucher/THIRD_PARTY_LICENSES.md
    EOS
  end

  test do
    assert_match "usage: sucher", shell_output("#{bin}/sucher --help 2>&1")
  end
end
