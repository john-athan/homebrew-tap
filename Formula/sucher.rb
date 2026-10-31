class Sucher < Formula
  desc "Fast terminal viewer and browser for markdown, sheets, PDF, images, video"
  homepage "https://github.com/john-athan/sucher"
  url "https://github.com/john-athan/sucher/archive/refs/tags/v0.9.6.tar.gz"
  sha256 "fdfd46fdb3269d734db069eb100a6bbf65e1640ee971b075f093c23837bad6bc"
  license "MIT"

  depends_on "rust" => :build
  # sucher loads these at runtime rather than linking them, so they are declared
  # here to make every format work out of the box. PDF pages come from the
  # libpdfium installed below; poppler is the fallback for that and still powers
  # pdfinfo/pdftotext. There is deliberately no depends_on "duckdb": Homebrew's
  # duckdb is 2.x, whose deprecated value accessors return empty cells, so the
  # pinned 1.x libduckdb is installed into libexec below instead.
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
    # `src/pdfium.rs` looks. Unlike libduckdb there is no homebrew-core formula
    # to depend on. Absent (offline builder, upstream outage) sucher falls back
    # to poppler, so this stays soft rather than failing the build.
    pdfium = "target/release/libpdfium.dylib"
    lib.install pdfium if File.exist?(pdfium)

    # Not lib: Homebrew's duckdb links its 2.x libduckdb.dylib there. sucher
    # looks in libexec beside its resolved binary before any system copy.
    duckdb = "target/release/libduckdb.dylib"
    libexec.install duckdb if File.exist?(duckdb)

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
