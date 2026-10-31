# br_validators

[![Gem](https://img.shields.io/gem/v/br_validators)](https://rubygems.org/gems/br_validators)
[![CI](https://github.com/PedroPedrassolli/br_validators/actions/workflows/ci.yml/badge.svg)](https://github.com/PedroPedrassolli/br_validators/actions/workflows/ci.yml)

Gem Ruby para validar e formatar documentos brasileiros, sem dependências. Dá para
testar cada documento no navegador em https://br-validators.vercel.app.

```ruby
require "br_validators"

BrValidators::CPF.valid?("123.456.789-09")     # => true
BrValidators::CNPJ.format("12abc34501de35")     # => "12.ABC.345/01DE-35"
BrValidators::Telefone.type("(11) 98765-4321")  # => :celular
```

## Instalação

No `Gemfile`:

```ruby
gem "br_validators"
```

Ou direto: `gem install br_validators`. A gem está publicada no
[RubyGems](https://rubygems.org/gems/br_validators).

## O que tem

| Documento | Módulo | Observação |
| --- | --- | --- |
| CPF | `CPF` | |
| CNPJ | `CNPJ` | numérico e alfanumérico (o formato novo da Receita Federal, a partir de julho de 2026) |
| CNS | `CNS` | Cartão Nacional de Saúde |
| Título de eleitor | `TituloEleitor` | 12 dígitos, com a UF de emissão |
| Chave Pix | `Pix` | CPF, CNPJ, e-mail, celular e chave aleatória |
| Boleto | `Boleto` | linha digitável de cobrança e de arrecadação |
| CEP | `CEP` | só o formato (o CEP não tem dígito verificador) |
| Telefone | `Telefone` | fixo e celular, com os 67 DDDs da Anatel |
| Placa | `Placa` | antiga e Mercosul, com conversão entre as duas |
| RENAVAM | `RENAVAM` | 11 dígitos |
| Chave de acesso | `ChaveAcesso` | NF-e, NFC-e, CT-e e MDF-e, inclusive com CNPJ alfanumérico; confere UF e mês |
| Processo judicial | `ProcessoCNJ` | numeração única do CNJ |

A regra de cada um está no comentário do módulo, com o link da fonte oficial (Receita
Federal, Ministério da Saúde, Banco Central, FEBRABAN, Anatel, CONTRAN, CNJ...). O
título de eleitor é a exceção: o TSE não publica o cálculo, e a regra usada é a que a
OBMEP documenta.

Cada documento tem os mesmos três métodos:

```ruby
BrValidators::CPF.valid?("123.456.789-09") # => true
BrValidators::CPF.format("12345678909")    # => "123.456.789-09"
BrValidators::CPF.strip("123.456.789-09")  # => "12345678909"

BrValidators::CNPJ.valid?("12.ABC.345/01DE-35") # => true (CNPJ alfanumérico)
BrValidators::CNPJ.format("12abc34501de35")     # => "12.ABC.345/01DE-35"

BrValidators::CNS.format("898000000000436")      # => "898 0000 0000 0436"
```

Pontos, traços e espaços são ignorados em qualquer posição, inclusive a meia-risca (–)
e o espaço não separável que vêm junto ao copiar do Word, de um PDF ou de um site. O texto
pode vir em qualquer encoding (UTF-8, Latin-1, UTF-16); texto corrompido só dá `false`,
sem erro. Passe sempre o documento como texto: um
número inteiro perde os zeros à esquerda (`01234567890` vira `1234567890`).

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

Os documentos novos seguem o mesmo jeito, com alguns métodos a mais:

```ruby
BrValidators::Telefone.type("+55 11 98765-4321")   # => :celular
BrValidators::Telefone.format("1134567890")        # => "(11) 3456-7890"

BrValidators::Placa.type("ABC1C34")                 # => :mercosul
BrValidators::Placa.mercosul("ABC-1234")            # => "ABC1C34"
BrValidators::Placa.antiga("ABC1C34")               # => "ABC1234"

BrValidators::TituloEleitor.uf("1023 8501 0671")    # => "PR"
BrValidators::ProcessoCNJ.segmento("0000456-41.2023.5.02.9999") # => "Justiça do Trabalho"
BrValidators::ChaveAcesso.modelo("3526 1011 2223 3300 0181 5500 1000 0001 2311 2345 6783") # => "55" (NF-e)

BrValidators::CEP.format("01001000")                # => "01001-000"
BrValidators::RENAVAM.valid?("00123456789")         # => true
```

## Consultas online

Validar não diz se o documento existe. Para isso há consultas pela
[BrasilAPI](https://brasilapi.com.br), um serviço gratuito, de código aberto e sem chave.
Elas são opcionais (a validação continua funcionando sem internet):

```ruby
require "br_validators/consulta"

BrValidators::Consulta.cep("01001-000")
# => {"cep"=>"01001000", "state"=>"SP", "city"=>"São Paulo", "street"=>..., ...}
BrValidators::Consulta.cnpj("11.222.333/0001-81") # => dados da Receita Federal (razao_social, uf, ...)
BrValidators::Consulta.banco("001")                # => {"code"=>1, "name"=>"BCO DO BRASIL S.A.", ...}
BrValidators::Consulta.ddd("11")                   # => {"state"=>"SP", "cities"=>[...]}
```

- Dado inválido devolve `nil` sem chamar a internet; dado que a BrasilAPI não encontra
  também devolve `nil`.
- Se a BrasilAPI não responder em 5 segundos ou der erro, levanta
  `BrValidators::Consulta::Erro`.
- Para usar cache ou outro cliente HTTP, troque o `BrValidators::Consulta.cliente` por um
  objeto com `get(uri)` que devolva `[status, corpo]`.
- A resposta é o JSON da BrasilAPI como `Hash`. Os campos são os dela e podem mudar.

## Rails e ActiveModel

Em projetos com ActiveModel (todo app Rails tem), os validadores entram sozinhos:

```ruby
class Cliente < ApplicationRecord
  validates :cpf, cpf: true
  validates :cnpj, cnpj: true, allow_blank: true
  validates :cartao_sus, cns: true
  validates :chave_pix, pix: { message: "não parece uma chave Pix" }
  validates :linha_digitavel, boleto: true
  validates :cep, cep: true
  validates :celular, telefone: true
  validates :titulo, titulo_eleitor: true
end

class Veiculo < ApplicationRecord
  validates :placa, placa: true
  validates :renavam, renavam: true
end

class Nota < ApplicationRecord
  validates :chave, chave_acesso: true
  validates :processo, processo_cnj: true
end
```

As mensagens de erro vêm em português (`pt-BR`) e inglês (`en`). Para trocar o texto,
sobrescreva as chaves `errors.messages.<documento>_invalid` (`cpf_invalid`, `cep_invalid`,
`titulo_eleitor_invalid`...) no seu arquivo de tradução.

Os validadores ficam no nível de cima (`CpfValidator`, `TelefoneValidator`,
`TituloEleitorValidator`...), porque é assim que o Rails encontra `cpf: true`.

Se o seu app já tem um validador com o mesmo nome (um `app/validators/cpf_validator.rb`,
por exemplo), o Rails passa a ignorar o arquivo do app sem avisar, porque a classe já
existe. Para ficar com o seu, carregue só os documentos:

```ruby
# Gemfile
gem "br_validators", require: "br_validators/documentos"
```

Os módulos (`BrValidators::CPF`...) continuam disponíveis; só os validadores do Rails
ficam de fora.

Já existem boas gems para CPF e CNPJ. A ideia aqui é juntar num lugar só os documentos
que costumam aparecer em sistemas brasileiros (inclusive CNS, Pix, boleto, placa, NF-e e
processo judicial), com mensagens de erro em português e inglês.

## Tipos (RBS)

A gem vem com assinaturas de tipo em `sig/`, para quem usa Steep, o Ruby LSP ou outra
ferramenta que lê RBS. A documentação de cada módulo fica em
[rubydoc.info](https://rubydoc.info/gems/br_validators).

## Página de teste

Dá para testar cada validador no navegador em https://br-validators.vercel.app. O link
pode abrir direto num documento: `?documento=placa`, `?documento=boleto`... A página
mostra o resultado, explica por que um número é inválido e monta o trecho de código
Ruby que faz o mesmo.

A página (`public/`) é HTML, CSS e JavaScript puro, sem build, e chama uma função Ruby
da Vercel (`api/validar.rb`) que usa a própria gem, então as regras ficam num lugar só.
O visual segue o do [portfólio do autor](https://pedrassolli.vercel.app), com as fontes
[Geist e Geist Mono](https://github.com/vercel/geist-font) (licença OFL, em
`public/fontes`).

```
GET /api/validar?documento=cnpj&valor=12.ABC.345/01DE-35
{"documento":"cnpj","valido":true,"formatado":"12.ABC.345/01DE-35","tipo":null,"detalhe":null,"caracteres":14}

GET /api/validar?documento=titulo_eleitor&valor=1023%208501%200671
{"documento":"titulo_eleitor","valido":true,"formatado":"1023 8501 0671","tipo":null,"detalhe":"PR","caracteres":12}
```

`caracteres` é o tamanho sem pontos, traços e espaços (para a chave Pix, `null`).

## Desenvolvimento

Precisa de Ruby 3.3 ou mais novo.

```sh
bundle install
bundle exec rake test   # testes (a cobertura mínima é 100% das linhas)
bundle exec rubocop     # estilo
bundle exec rbs -r uri -I sig validate   # assinaturas de tipo
node --test "test/js/*.test.mjs"   # testes da página de teste
```

O passo a passo para contribuir está no [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença

[MIT](LICENSE)
