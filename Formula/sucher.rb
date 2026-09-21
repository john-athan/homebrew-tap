class Sucher < Formula
  desc "Fast terminal viewer and browser for markdown, sheets, PDF, images, video"
  homepage "https://github.com/john-athan/sucher"
  url "https://github.com/john-athan/sucher/archive/refs/tags/v0.9.1.tar.gz"
  sha256 "87394af4fb25c01f54afb3d9a9bcf466d2c47c7bfc9d8a1e5bc337cbb8ddfa75"
  license "MIT"

  depends_on "rust" => :build
  # sucher loads these at runtime rather than linking them, so they are declared
  # here to make every format work out of the box. PDF pages come from the
  # libpdfium installed below; poppler is the fallback for that and still powers
  # pdfinfo/pdftotext. duckdb provides the libduckdb that Parquet, JSONL and
  # DuckDB files are read through (sucher ADR 0022): depending on it beats
  # shipping a second copy into the same lib prefix this formula owns.
  depends_on "duckdb"  # data files (libduckdb, loaded at runtime)
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
