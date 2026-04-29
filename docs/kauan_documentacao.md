# Documentação — Refatoração Arquitetural

**Integrante:** Kauan  
**Branch / PR:** Refatoração arquitetural base

---

## Problemas identificados

A primeira coisa que chamou atenção ao abrir o projeto foi que tudo estava em um único arquivo: `lib/main.dart`. O modelo de dados, a chamada HTTP, a lógica de carregamento e as duas telas da aplicação conviviam no mesmo lugar. Isso por si só já é um sinal de alerta — quando qualquer coisa precisa mudar, você mexe num arquivo que não deveria ter nada a ver com aquela mudança.

Além da organização, tinha um problema bem visível na prática: ao abrir o app, ele esperava 2 segundos antes de sequer tentar buscar os dados. Essa espera era intencional no projeto original, mas deixou claro como um atraso pequeno já torna a experiência frustrante. Em conjunto com isso, toda vez que o usuário abria a tela de detalhes de um produto e voltava, o app refazia a requisição inteira à API — como se os dados pudessem ter mudado naquele intervalo de segundos. Não fazia sentido.

Resumindo, os problemas que identifiquei foram:

- **Tudo no mesmo arquivo:** model, HTTP, lógica e UI misturados no `main.dart`
- **Delay artificial de 2 segundos** antes de cada requisição
- **A tela fazendo chamada HTTP diretamente**, sem nenhuma separação entre UI e acesso a dados
- **Reload desnecessário ao voltar dos detalhes**, refazendo uma requisição sem motivo

---

## O que foi feito

A ideia central foi separar o que estava misturado, sem inventar complexidade desnecessária.

Criei a pasta `lib/models/` e movi a classe `Product` para lá. Criei a pasta `lib/services/` com a classe `ProductService`, que ficou responsável por toda a comunicação com a API — a tela não precisa mais saber que existe uma URL, um `http.get` ou um `jsonDecode`. Movi cada tela para seu próprio arquivo em `lib/pages/`. O `main.dart` ficou com só o que é dele: inicializar o app.

Aproveitei também para remover o `await Future.delayed(const Duration(seconds: 2))` que estava forçando a espera, e simplifiquei o `openDetails()` para só navegar, sem chamar `loadProducts()` ao voltar.

---

## Por que essas mudanças melhoram o projeto

Separar o código em camadas não é só questão de organização visual. Quando a `ProductListPage` fazia a chamada HTTP diretamente, qualquer mudança na API — uma URL diferente, um campo novo no JSON — obrigava a mexer na tela. Com o `ProductService` no meio, essa mudança fica isolada: a tela continua igual, só o service muda. Isso também facilita a vida dos outros integrantes do grupo, já que cada um consegue trabalhar na sua parte sem esbarrar no mesmo arquivo.

O delay de 2 segundos tornou bem concreto algo que a gente sabe na teoria: latência percebida importa. Mesmo sabendo que era artificial, a espera incomodava. Removê-lo não resolve o tempo de rede real, mas elimina uma penalidade que estava sendo adicionada por cima da conexão sem nenhuma justificativa.

O reload ao voltar dos detalhes era o problema mais fácil de sentir no uso: o usuário clicava num produto, via as informações, voltava — e tinha que esperar de novo como se o app tivesse esquecido o que acabou de carregar. Os dados já estavam em memória, não tinha por que ir à rede de novo. Remover essa chamada fez a navegação ficar imediata, sem nenhuma espera.
