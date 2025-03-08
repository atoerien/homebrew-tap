class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/mobile-shell/mosh/releases/download/mosh-1.4.0/mosh-1.4.0.tar.gz"
  sha256 "872e4b134e5df29c8933dff12350785054d2fd2839b5ae6b5587b14db1465ddd"
  license "GPL-3.0-or-later"
  revision 26

  head do
    url "https://github.com/mobile-shell/mosh.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "protobuf"

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  on_macos do
    depends_on "tmux" => :build # for `make check`
  end

  on_linux do
    depends_on "openssl@3" # Uses CommonCrypto on macOS
  end

  patch :DATA

  def install
    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"
    # Avoid over-linkage to `abseil`.
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac?

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "'#{bin}/mosh-client"

    if build.head?
      # Prevent mosh from reporting `-dirty` in the version string.
      inreplace "Makefile.am", "--dirty", "--dirty=-Homebrew"
      system "./autogen.sh"
    elsif version <= "1.4.0" # remove `elsif` block and `else` at version bump.
      # Keep C++ standard in sync with abseil.rb.
      # Use `gnu++17` since Mosh allows use of GNU extensions (-std=gnu++11).
      ENV.append "CXXFLAGS", "-std=gnu++17"
    else # Remove `else` block at version bump.
      odie "Install method needs updating!"
    end

    # `configure` does not recognise `--disable-debug` in `std_configure_args`.
    system "./configure", "--prefix=#{prefix}", "--enable-completion", "--disable-silent-rules"
    # Mosh provides remote shell access, so let's run the tests to avoid shipping an insecure build.
    system "make", "check" if OS.mac? # Fails on Linux.
    system "make", "install"
  end

  test do
    system bin/"mosh-client", "-c"
  end
end
__END__
--- a/scripts/mosh.pl
+++ b/scripts/mosh.pl
@@ -193,7 +193,9 @@ if ( defined $predict ) {
 }

 if ( not grep { $_ eq $use_remote_ip } qw { local remote proxy } ) {
-  die "Unknown parameter $use_remote_ip";
+  if ($use_remote_ip !~ /^gateway:/) {
+    die "Unknown parameter $use_remote_ip";
+  }
 }

 $family = lc( $family );
@@ -442,6 +444,23 @@ if ( $pid == 0 ) { # child
   close $pipe;
   waitpid $pid, 0;

+  if ( $use_remote_ip =~ '^gateway:(.*)$' ) {
+    # "parse" the host from what the user gave us
+    my $shost = $1;
+    # get list of addresses
+    my @res = resolvename( $shost, 22, $family );
+    # Use only the first address as the Mosh IP
+    my $hostaddr = $res[0];
+    if ( !defined $hostaddr ) {
+      die "could not find address for gateway host $shost";
+    }
+    my ( $err, $addr_string, $service ) = getnameinfo( $hostaddr->{addr}, NI_NUMERICHOST );
+    if ( $err ) {
+      die "could not use address for gateway host $shost";
+    }
+    $ip = $addr_string;
+  }
+
   if ( not defined $ip ) {
     if ( defined $sship ) {
       warn "$0: Using remote IP address ${sship} from \$SSH_CONNECTION for hostname ${userhost}\n";
