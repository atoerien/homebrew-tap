class Libcst < Formula
  desc "A concrete syntax tree parser and serializer library for Python that preserves many aspects of Python's abstract syntax tree"
  homepage "https://github.com/Instagram/LibCST"
  url "https://files.pythonhosted.org/packages/e4/bd/ff41d7a8efc4f60a61d903c3f9823565006f44f2b8b11c99701f552b0851/libcst-1.4.0.tar.gz"
  sha256 "449e0b16604f054fa7f27c3ffe86ea7ef6c409836fe68fe4e752a1894175db00"
  license "MIT"

  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "rust" => :build
  depends_on "python-typing-extensions"
  depends_on "python-typing-inspect"
  depends_on "mypy-extensions"
  depends_on "pyyaml"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python|
      system python, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
    end
  end

  test do
    pythons.each do |python|
      system python, "-c", "import libcst"
    end
  end
end
