# frozen_string_literal: true

module BrValidators
  # Contas de dígito verificador usadas por mais de um documento. É interno da gem
  # (private_constant no fim): quem usa a gem não precisa dele.
  #
  # O valor de cada caractere é o código ASCII dele menos 48: "0" vale 0, "9" vale
  # 9 e "A" vale 17, como manda a regra do CNPJ alfanumérico. Para dígitos, dá o
  # mesmo que to_i, sem criar uma string por caractere (getbyte devolve o código).
  module Digitos
    # Soma do "módulo 11 com pesos de 2 a 9": da direita para a esquerda, cada
    # caractere é multiplicado por 2, 3, ..., 9, e o peso volta ao 2 depois do 9.
    # Usada no CNPJ, no RENAVAM, na chave de acesso e no boleto.
    def self.soma_modulo11(texto)
      ultimo = texto.size - 1
      (0..ultimo).sum { |posicao| (texto.getbyte(ultimo - posicao) - 48) * ((posicao % 8) + 2) }
    end

    # O dígito mais comum do módulo 11: resto 0 ou 1 vira 0; senão, 11 menos o resto.
    def self.modulo11(texto)
      resto = soma_modulo11(texto) % 11
      resto < 2 ? 0 : 11 - resto
    end
  end

  private_constant :Digitos
end
