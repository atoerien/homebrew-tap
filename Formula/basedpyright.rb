require "language/node"

class Basedpyright < Formula
  desc "Static type checking for Python (but based)"
  homepage "https://github.com/DetachHead/basedpyright"
  url "https://github.com/DetachHead/basedpyright/releases/download/v1.37.1/basedpyright-1.37.1.tar.gz"
  sha256 "1f47bc6f45cbcc5d6f8619d60aa42128e4b38942f5118dcd4bc20c3466c5e02f"
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
    else
      cd "basedpyright" do
        (libexec/"basedpyright").install "dist"

        # replace typeshed-fallback
        resource("docstubs").stage do
          typeshed_fallback = libexec/"basedpyright/dist/typeshed-fallback"
          rm_r typeshed_fallback
          mkdir typeshed_fallback
          typeshed_fallback.install "stdlib", "stubs", "LICENSE", "README.md"
          commit = Pathname.new(".git/refs/heads/main").read
          (typeshed_fallback/"commit.txt").write commit
        end

        (libexec/"basedpyright").install "index.js"
        chmod 0755, "#{libexec}/basedpyright/index.js"
        (libexec/"basedpyright").install "langserver.index.js"
        chmod 0755, "#{libexec}/basedpyright/langserver.index.js"
      end
    end

    bin.install_symlink libexec/"basedpyright/index.js" => "basedpyright"
    bin.install_symlink libexec/"basedpyright/langserver.index.js" => "basedpyright-langserver"
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
