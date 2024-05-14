class JavaDebug < Formula
  desc "The debug server implementation for Java"
  homepage "https://github.com/microsoft/java-debug"
  url "https://github.com/microsoft/java-debug/archive/refs/tags/0.52.0.tar.gz"
  sha256 "1e9f8e82b2d6d41eb1ee66d34ad1e90e678e1bd34660074784fcefdc2e13e2db"
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
