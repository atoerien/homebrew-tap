class Basedpyright < Formula
  desc "Pyright fork with various improvements and built-in pylance features"
  homepage "https://github.com/DetachHead/basedpyright"
  url "https://registry.npmjs.org/basedpyright/-/basedpyright-1.38.2.tgz"
  sha256 "ba0f0cd33f2be7c62785201acc11f29e8e7adc2bcded669de8f7d123e7780827"
  license "MIT"

  head do
    url "https://github.com/DetachHead/basedpyright.git", branch: "main"
    depends_on "python" => :build
  end

  depends_on "node"

  resource "docstubs" do
    url "https://github.com/atoerien/typeshed.git", branch: "main"
  end

  def install
    if build.head?
      resource("docstubs").stage do
        mkdir buildpath/"docstubs"
        (buildpath/"docstubs").install "stdlib", "stubs", "LICENSE", "README.md"
        commit = Pathname.new(".git/refs/heads/main").read
        (buildpath/"docstubs/commit.txt").write commit
      end

      system "npm", "install", *std_npm_args(prefix: false)
      cd "packages/pyright" do
        system "npm", "run", "build"
        (libexec/"basedpyright").install "dist"
        (libexec/"basedpyright").install "index.js"
        (libexec/"basedpyright").install "langserver.index.js"
      end
      (libexec/"basedpyright").install "LICENSE.txt"
      bin.install_symlink libexec/"basedpyright/index.js" => "basedpyright"
      bin.install_symlink libexec/"basedpyright/langserver.index.js" => "basedpyright-langserver"
    else
      system "npm", "install", *std_npm_args
      bin.install_symlink libexec/"bin/pyright" => "basedpyright"
      bin.install_symlink libexec/"bin/pyright-langserver" => "basedpyright-langserver"

      # Remove empty folder to make :all bottle
      rm_r libexec/"lib/node_modules/basedpyright/node_modules" if OS.mac?

      # replace typeshed-fallback
      resource("docstubs").stage do
        typeshed_fallback = libexec/"lib/node_modules/basedpyright/dist/typeshed-fallback"
        rm_r typeshed_fallback
        mkdir typeshed_fallback
        typeshed_fallback.install "stdlib", "stubs", "LICENSE", "README.md"
        commit = Pathname.new(".git/refs/heads/main").read
        (typeshed_fallback/"commit.txt").write commit
      end
    end
  end

  test do
    (testpath/"broken.py").write <<~EOS
      def wrong_types(a: int, b: int) -> str:
          return a + b
    EOS
    output = pipe_output("#{bin}/basedpyright broken.py 2>&1")
    assert_match 'error: Expression of type "int" cannot be assigned to return type "str"', output
  end
end
