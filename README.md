# br_validators

Gem Ruby para validar e formatar documentos brasileiros, sem dependências.

> Em desenvolvimento. Ainda não está publicada no RubyGems.

## O que vai ter na primeira versão

| Documento | Observação |
| --- | --- |
| CPF | |
| CNPJ | numérico e alfanumérico (o formato novo da Receita Federal, a partir de julho de 2026) |
| CNS | Cartão Nacional de Saúde |
| Chave Pix | CPF, CNPJ, e-mail, celular e chave aleatória |
| Boleto | linha digitável de cobrança e de arrecadação |

Cada documento tem os mesmos três métodos:

```ruby
BrValidators::CPF.valid?("123.456.789-09") # => true
BrValidators::CPF.format("12345678909")    # => "123.456.789-09"
BrValidators::CPF.strip("123.456.789-09")  # => "12345678909"

BrValidators::CNPJ.valid?("12.ABC.345/01DE-35") # => true (CNPJ alfanumérico)
BrValidators::CNPJ.format("12abc34501de35")     # => "12.ABC.345/01DE-35"

BrValidators::CNS.format("898000000000436")      # => "898 0000 0000 0436"
```

A chave Pix é um caso à parte: em vez de `format` e `strip`, ela tem `type`, que diz
o tipo da chave. Ela precisa estar como o Banco Central guarda (sem máscara, e-mail e
chave aleatória em minúsculas):

```ruby
BrValidators::Pix.type("+5511987654321")             # => :phone
BrValidators::Pix.type("maria.souza@exemplo.com.br") # => :email
BrValidators::Pix.valid?("123.456.789-09")           # => false (chave de CPF não tem máscara)
```

O boleto aceita a linha digitável de cobrança (bancos) e de arrecadação (contas de
consumo e tributos) e também tem `type`:

```ruby
BrValidators::Boleto.type("00190.00009 02345.678904 12345.678176 1 10000000012345") # => :cobranca
BrValidators::Boleto.valid?("826700000019000000000000000000000000000000000000")      # => true
```

E, em projetos Rails, a validação no model:

```ruby
validates :cpf, cpf: true
```

Já existem boas gems para CPF e CNPJ. A ideia aqui é juntar num lugar só os documentos
que costumam aparecer em sistemas brasileiros (inclusive CNS, Pix e boleto), com
mensagens de erro em português e inglês.

## Desenvolvimento

Precisa de Ruby 3.3 ou mais novo.

```sh
bundle install
bundle exec rake test   # testes (a cobertura mínima é 100% das linhas)
bundle exec rubocop     # estilo
```

O passo a passo para contribuir está no [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença

[MIT](LICENSE)
