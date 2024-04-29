class MipselElfGcc < Formula
  desc "GNU compiler collection for mipsel"
  homepage "https://gcc.gnu.org"
  url "https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
  sha256 "e275e76442a6067341a27f04c5c6b83d8613144004c0413528863dc6b5c743da"
  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  depends_on "mipsel-elf-binutils"
  depends_on "gnu-sed"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "libmpc"
  depends_on "isl"
  depends_on "zstd"

  uses_from_macos "zlib"

  def install
    target = "mipsel-elf"

    mkdir "mipsel-elf-gcc-build" do
      args = [
        "--target=#{target}",
        "--prefix=#{prefix}",
        "--infodir=#{info}/#{target}",
        "--without-headers",
        "--disable-debug",
        "--disable-nls",
        "--disable-shared",
        "--disable-decimal-float",
        "--disable-threads",
        "--disable-libatomic",
        "--disable-libgomp",
        "--disable-libquadmath",
        "--disable-libssp",
        "--disable-libvtv",
        "--disable-libstdcxx",
        "--disable-multilib",
        "--disable-werror",
        "--enable-lto",
        "--enable-languages=c,c++",
        "--with-as=#{Formula["mipsel-elf-binutils"].bin}/mipsel-elf-as",
        "--with-ld=#{Formula["mipsel-elf-binutils"].bin}/mipsel-elf-ld",
        "--with-system-zlib",
      ]

      ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"

      system "../configure", *args
      system "make"
      system "make", "install"

      # FSF-related man pages may conflict with native gcc
      (share/"man/man7").rmtree
    end
  end

  test do
    (testpath/"test-c.c").write <<~EOS
      int main(void)
      {
        int i=0;
        while(i<10) i++;
        return i;
      }
    EOS
    system "#{bin}/mipsel-elf-gcc", "-c", "-o", "test-c.o", "test-c.c"
    assert_match "file format elf32-littlemips",
                 shell_output("#{Formula["mipsel-elf-binutils"].bin}/mipsel-elf-objdump -a test-c.o")
  end
end
