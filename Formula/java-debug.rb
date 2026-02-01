class JavaDebug < Formula
  desc "Debug server implementation for Java"
  homepage "https://github.com/microsoft/java-debug"
  url "https://github.com/microsoft/java-debug/archive/refs/tags/0.53.1.tar.gz"
  sha256 "8a16e39837b1d21826cc31160c294e6bf87ede050b2a3fb8c985b50819841646"
  license "EPL-1.0"

  head "https://github.com/microsoft/java-debug.git", branch: "main"

  depends_on "openjdk"

  def install
    system "./mvnw", "clean", "install"

    core_jar = Pathname.glob("com.microsoft.java.debug.core/target/com.microsoft.java.debug.core-*.jar").first
    share.install core_jar => "com.microsoft.java.debug.core.jar"
    plugin_jar = Pathname.glob("com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar").first
    share.install plugin_jar => "com.microsoft.java.debug.plugin.jar"
  end
end
