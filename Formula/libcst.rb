class Libcst < Formula
  desc "A concrete syntax tree parser and serializer library for Python that preserves many aspects of Python's abstract syntax tree"
  homepage "https://github.com/Instagram/LibCST"
  url "https://files.pythonhosted.org/packages/48/af/b243be2e6aaddd2b9e8f78817fc8f2ef5874753b01c2e07e75c109b102e8/libcst-1.2.0.tar.gz"
  sha256 "71dd69fff76e7edaf8fae0f63ffcdbf5016e8cd83165b1d0688d6856aa48186a"
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
