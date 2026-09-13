class Sucher < Formula
  desc "Fast terminal viewer and browser for markdown, sheets, PDF, images, video"
  homepage "https://github.com/john-athan/sucher"
  url "https://github.com/john-athan/sucher/archive/refs/tags/v0.8.2.tar.gz"
  sha256 "36a7ded4570d7dced6eb29ccdff0b544535a7a594f7ace9d9fea27eeda7edffd"
  license "MIT"

  depends_on "rust" => :build
  # Both are optional to sucher at runtime, and declared here so the formats
  # that shell out just work. PDF pages come from the libpdfium installed below;
  # poppler is the fallback for that and still powers pdfinfo/pdftotext.
  depends_on "ffmpeg"  # video playback (ffmpeg / ffprobe)
  depends_on "poppler" # PDF fallback (pdftocairo / pdfinfo / pdftotext)

  def install
    # `cargo build` rather than `cargo install`, because the build stages a
    # sidecar library next to the binary and `cargo install` copies only the
    # binary itself.
    system "cargo", "build", "--release", "--locked"
    bin.install "target/release/sucher"

    # sucher loads libpdfium at runtime and deliberately does not carry a copy
    # inside the executable: macOS charges for the whole image at exec rather
    # than for the pages that run, so an embedded 7.2 MB library costs ~110 ms
    # on every start, `sucher note.md` included. build.rs stages the pinned,
    # checksum-verified library into target/release; install it where
    # `src/pdfium.rs` looks. Absent (offline builder, upstream outage) sucher
    # falls back to poppler, so this stays soft rather than failing the build.
    pdfium = "target/release/libpdfium.dylib"
    lib.install pdfium if File.exist?(pdfium)

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
