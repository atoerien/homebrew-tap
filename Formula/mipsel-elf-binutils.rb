class MipselElfBinutils < Formula
  desc "GNU binary tools for mipsel cross development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.bz2"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.42.tar.bz2"
  sha256 "aa54850ebda5064c72cd4ec2d9b056c294252991486350d9a97ab2a6dfdfaf12"
  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later", "LGPL-2.0-or-later", "LGPL-3.0-only"]

  uses_from_macos "bison" => :build
  uses_from_macos "zlib"

  def install
    target = "mipsel-elf"

    args = [
      "--target=#{target}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--enable-deterministic-archives",
      "--prefix=#{prefix}",
      "--libdir=#{lib}/#{target}",
      "--infodir=#{info}/#{target}",
      "--disable-werror",
      "--disable-nls",
      "--with-system-zlib",
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/mips-elf-strings #{bin}/mips-elf-strings")
  end
end
