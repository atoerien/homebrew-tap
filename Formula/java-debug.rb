class JavaDebug < Formula
  desc "The debug server implementation for Java"
  homepage "https://github.com/microsoft/java-debug"
  url "https://github.com/microsoft/java-debug/archive/refs/tags/0.53.0.tar.gz"
  sha256 "df7a420d7d5efc79ac2e6db5d0cc119db1ae6f4fbe84cc24f6bab4aa6791ef37"
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
