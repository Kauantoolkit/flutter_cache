# PR #2 — Cache de Dados (Tales)

## Problemas identificados no projeto original

### 1. Ausência de cache local
A cada abertura do app, loadProducts() disparava uma requisição HTTP completa. Como os dados raramente mudam, essas requisições eram desnecessárias — impondo 1–3 segundos de loading a cada interação.

### 2. Reload desnecessário ao voltar dos detalhes
openDetails() usava await Navigator.push(...) e chamava loadProducts() em seguida. O produto já estava em memória — o reload só desperdiçava rede e travava a interface.

### 3. Blocking load sem fallback
O carregamento sempre mostrava um CircularProgressIndicator bloqueante. Sem cache, o usuário ficava com tela vazia enquanto a requisição completava.

## Mudanças realizadas

- pubspec.yaml: adicionado shared_preferences: ^2.3.2
- ProductService: adicionados fetchFromCache() e _saveToCache(). A API agora salva no cache automaticamente após cada resposta bem-sucedida.
- ProductListPage: implementada estratégia cache-first — exibe cache imediatamente e atualiza em background. Removido o reload desnecessário ao voltar dos detalhes. Adicionado indicador sutil no AppBar durante o refresh.

## Justificativa técnica

Cache local elimina latência percebida. O padrão cache-first garante que o usuário veja conteúdo útil imediatamente, enquanto a atualização ocorre de forma transparente em background. O reload ao voltar dos detalhes era arquiteturalmente incorreto — os dados já estavam em memória, refazê-lo só penalizava o usuário sem nenhum benefício.
