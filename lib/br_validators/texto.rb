# frozen_string_literal: true

# Entrada comum a todos os validadores: ver BrValidators.texto abaixo.
module BrValidators
  # Converte o valor recebido em texto UTF-8 antes de tirar a máscara. Todos os
  # validadores passam por aqui, para tratar a entrada do mesmo jeito:
  #   - nil vira "" e números viram texto;
  #   - texto em outro encoding (Latin-1, Windows-1252, UTF-16) é convertido;
  #   - bytes inválidos (texto corrompido) viram "�", que nunca passa na validação.
  # Assim os validadores devolvem false em vez de levantar erro, e as máscaras
  # podem usar classes Unicode, como [:space:] (espaços) e \p{Pd} (traços).
  def self.texto(valor)
    valor.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
  end
end
