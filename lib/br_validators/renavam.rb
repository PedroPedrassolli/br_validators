# frozen_string_literal: true

module BrValidators
  # RENAVAM (Registro Nacional de Veículos Automotores): 11 dígitos, sendo 10 de
  # número e 1 dígito verificador.
  #
  # O dígito verificador usa módulo 11 com pesos de 2 a 9 ("peso 9"), da direita
  # para a esquerda, voltando ao 2 depois do 9. Se o resto da divisão por 11 for
  # 0 ou 1, o dígito é 0; senão, é 11 menos o resto.
  #
  # Os códigos antigos tinham 9 dígitos. Para validar um deles, complete com
  # zeros à esquerda até ficar com 11 ("123456789" vira "00123456789"): os zeros
  # não mudam a conta.
  #
  # Fonte: Portaria DENATRAN nº 27/2013 (11 dígitos, "dígito verificador,
  # calculado através do módulo 11, peso 9"), válida desde abril de 2013.
  module RENAVAM
    # O RENAVAM não tem máscara oficial; aceitamos pontos, hífens e espaços.
    MASK = /[.\p{Pd}[:space:]]/

    def self.strip(value)
      BrValidators.texto(value).gsub(MASK, "")
    end

    def self.valid?(value)
      valid_stripped?(strip(value))
    end

    # O RENAVAM não tem máscara: devolve os 11 dígitos, ou nil se for inválido.
    def self.format(value)
      renavam = strip(value)
      valid_stripped?(renavam) ? renavam : nil
    end

    # A regra, com o RENAVAM já sem máscara. O dígito é o módulo 11 com pesos de
    # 2 a 9 (Digitos, em digitos.rb).
    def self.valid_stripped?(renavam)
      return false unless renavam.match?(/\A\d{11}\z/)

      # 00000000000, 11111111111... não são códigos reais.
      return false if renavam.squeeze.size == 1

      renavam[10] == Digitos.modulo11(renavam[0, 10]).to_s
    end

    private_class_method :valid_stripped?
  end
end
