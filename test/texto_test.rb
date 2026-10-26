# frozen_string_literal: true

require "test_helper"

describe "BrValidators.texto" do
  subject { BrValidators }

  it "transforma nil em texto vazio e números em texto" do
    assert_equal "", subject.texto(nil)
    assert_equal "12345678909", subject.texto(12_345_678_909)
  end

  it "converte outros encodings para UTF-8" do
    assert_equal "123–45", subject.texto("123–45".encode("Windows-1252"))
    assert_equal "123.456", subject.texto("123.456".encode("UTF-16LE"))
    assert_equal Encoding::UTF_8, subject.texto("123".b).encoding
  end

  it "troca bytes inválidos por �, sem levantar erro" do
    assert_equal "12\u{FFFD}3", subject.texto("12\xFF3".dup.force_encoding(Encoding::UTF_8))
  end

  it "não altera o texto recebido" do
    original = "123.456.789-09"
    subject.texto(original)
    assert_equal "123.456.789-09", original
  end
end
