class MacosPasteboard < Formula
  desc "Like macOS's built-in pbpaste but more flexible and raw"
  homepage "https://github.com/chbrown/macos-pasteboard"
  head "https://github.com/chbrown/macos-pasteboard.git", branch: "master"

  depends_on xcode: ["13.0", :build]
  depends_on :macos
  uses_from_macos "swift"

  def install
    system "make"
    bin.install "bin/pbv"
  end

  test do
    assert_match "Read contents of pasteboard as 'dataType'.", shell_output("#{bin}/pbv --help")
  end
end
