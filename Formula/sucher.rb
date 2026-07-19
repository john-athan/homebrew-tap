class Sucher < Formula
  desc "Fast terminal viewer for markdown, spreadsheets, PDF, images, video, docx"
  homepage "https://github.com/john-athan/sucher"
  url "https://github.com/john-athan/sucher/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "343fdc0765e8921eefe33ace54ff13e66a8d07454ca6d7b51add96111b5e2240"
  license "MIT"

  depends_on "rust" => :build
  # Optional-at-runtime, declared here so PDF and video "just work":
  depends_on "ffmpeg"  # video playback (ffmpeg / ffprobe)
  depends_on "poppler" # PDF pages (pdftocairo / pdfinfo / pdftotext)

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "usage: sucher", shell_output("#{bin}/sucher --help 2>&1")
  end
end
