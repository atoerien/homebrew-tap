require "language/node"

class Basedpyright < Formula
  desc "Static type checking for Python (but based)"
  homepage "https://github.com/DetachHead/basedpyright"
  url "https://github.com/DetachHead/basedpyright/releases/download/v1.28.4/basedpyright-1.28.4.tar.gz"
  sha256 "0d4a67e8d3df0d724ac043d7110fea46478f3f1d970fadcd015be1c39054bdb2"
  license "MIT"

  resource "docstubs" do
    url "https://github.com/atoerien/typeshed.git", branch: "main"
  end

  head do
    url "https://github.com/DetachHead/basedpyright.git", branch: "main"
    depends_on "python" => :build
  end

  depends_on "node"

  def install
    if build.head?
      resource("docstubs").stage do
        mkdir buildpath/"docstubs"
        (buildpath/"docstubs").install "stdlib", "stubs", "LICENSE", "README.md"
        commit = Pathname.new(".git/refs/heads/main").read
        (buildpath/"docstubs/commit.txt").write commit
      end

      system "npm", "install", *Language::Node.local_npm_install_args
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
