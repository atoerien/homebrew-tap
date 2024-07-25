require "language/node"

class Basedpyright < Formula
  desc "Static type checking for Python (but based)"
  homepage "https://github.com/DetachHead/basedpyright"
  url "https://github.com/DetachHead/basedpyright/releases/download/v1.15.0/basedpyright-1.15.0.tar.gz"
  sha256 "3f268d7909a17df5a01f380693c91ef389f8471b720641b9a829f1aa45798aca"
  license "MIT"

  head do
    url "https://github.com/DetachHead/basedpyright.git", branch: "main"
    depends_on "python" => :build
  end

  depends_on "node"

  def install
    if build.head?
      system "./pw", "pdm", "install", "--group=docstubs", "--no-self", "--no-default"
      system "./pw", "pdm", "run", "generate_docstubs"

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
        (libexec/"basedpyright").install "index.js"
        chmod 0755, "#{libexec}/basedpyright/index.js"
        (libexec/"basedpyright").install "langserver.index.js"
        chmod 0755, "#{libexec}/basedpyright/langserver.index.js"
      end
    end

    bin.install_symlink libexec/"basedpyright/index.js" => "basedpyright"
    bin.install_symlink libexec/"basedpyright/langserver.index.js" => "basedpyright-langserver"

    # Replace universal binaries with native slices
    deuniversalize_machos
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
