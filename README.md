# Bolso

Controle financeiro mensal: ganhos, contas fixas, gastos variáveis e gastos extras, com abas por mês, visão do ano e exportação em PDF e Excel. Funciona no computador, no tablet e no celular.

- Site: [thechrisart.github.io/bolso](https://thechrisart.github.io/bolso/), no GitHub Pages (pasta raiz deste repositório)
- App: instalável na tela de início do celular (PWA); o próprio site mostra como instalar
- Banco de dados e login: Supabase

## Como configurar o banco (uma vez)

1. Crie um projeto em [supabase.com](https://supabase.com).
2. No projeto, abra **SQL Editor**, cole o conteúdo de [`supabase.sql`](supabase.sql) e clique em **Run**.
3. Em **Authentication → URL Configuration**, coloque o endereço do site em **Site URL** e em **Redirect URLs**.
4. Em **Project Settings → API**, copie a **Project URL** e a chave **anon / publishable** para o arquivo [`config.js`](config.js).

A chave anon é pública por natureza. Quem protege os dados são as regras do banco (Row Level Security): cada pessoa só vê e altera os próprios meses.

## Arquivos

| Arquivo | O que é |
|---|---|
| `index.html` | O app inteiro |
| `config.js` | Endereço e chave pública do Supabase |
| `i18n.js` | Traduções para inglês e espanhol |
| `supabase.sql` | Tabela e regras de segurança do banco |
| `manifest.json`, `icon*` | Nome e ícones do app instalado |
| `sw.js` | Service worker: abre o app sem internet (nunca guarda dados financeiros) |

## App para iPhone e iPad

A pasta [`ios/`](ios) empacota o site em um app nativo (WKWebView), com as bibliotecas dentro do app. Para gerar o IPA é preciso ter Xcode e [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
ios/scripts/build-ipa.sh
```

O resultado é `ios/dist/Bolso-sem-assinatura.ipa`, que precisa ser assinado (por exemplo, pelo Sideloadly) para instalar. Para gerar também `ios/dist/Bolso.ipa` já assinado, defina `TEAM_ID`; os aparelhos precisam estar registrados na conta de desenvolvedor:

```bash
TEAM_ID=XXXXXXXXXX ios/scripts/build-ipa.sh
```

Alterações em `index.html` só chegam ao app depois de gerar e instalar um novo IPA.
