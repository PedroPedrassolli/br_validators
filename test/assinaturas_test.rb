# frozen_string_literal: true

require "test_helper"
require "br_validators/consulta"

# As assinaturas de sig/br_validators.rbs são escritas à mão. Este teste avisa
# quando um método público entra num módulo e fica sem assinatura (ou o contrário).
# Se os tipos estão certos, quem confere é o "rbs validate" da CI.
describe "sig/br_validators.rbs" do
  # Os módulos da gem (BrValidators e os de dentro dele), sem as classes.
  def modulos(raiz = BrValidators)
    filhos = raiz.constants.map { |nome| raiz.const_get(nome) }.grep(Module).grep_v(Class)
    [raiz] + filhos.flat_map { |filho| modulos(filho) }
  end

  # Lê o arquivo linha a linha e devolve { "BrValidators::CPF" => ["format", ...] }.
  subject do
    pilha = []
    linhas = File.readlines(File.expand_path("../sig/br_validators.rbs", __dir__), encoding: "UTF-8")
    linhas.each_with_object(Hash.new { [] }) do |linha, metodos|
      case linha
      when /^\s*(?:module|class|interface) (\w+)/ then pilha.push(Regexp.last_match(1))
      when /^\s*end$/ then pilha.pop
      when /^\s*def self\.([^:\s]+):/ then metodos[pilha.join("::")] += [Regexp.last_match(1)]
      when /^\s*attr_writer self\.(\w+):/ then metodos[pilha.join("::")] += ["#{Regexp.last_match(1)}="]
      end
    end
  end

  it "tem a assinatura de cada método público de cada módulo" do
    modulos.each do |modulo|
      publicos = modulo.singleton_methods(false).map(&:to_s)
      assert_equal publicos.sort, subject[modulo.name].sort, "métodos de #{modulo.name}"
    end
  end
end
