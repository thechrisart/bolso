# Bolso na App Store: passo a passo

Este guia leva o Bolso do projeto do Xcode até a App Store, para **iPhone, iPad e Mac**, num único app ("compra universal": quem baixa no iPhone também tem no Mac).

Tempo total: umas 3 a 4 horas de trabalho seu, mais 1 a 2 dias esperando a Apple (aprovação da conta de desenvolvedor e revisão do app).

---

## 0. O que você precisa antes

| Item | Onde | Custo |
|---|---|---|
| Um Mac com macOS atualizado | — | — |
| **Xcode** (versão 16 ou mais nova) | Mac App Store, busque "Xcode" | Grátis |
| Apple ID com verificação em duas etapas | appleid.apple.com | Grátis |
| **Apple Developer Program** | developer.apple.com/programs/enroll | **US$ 99 por ano** |

**Pessoa física ou empresa?**
- **Pessoa física (Individual):** aprovação rápida (minutos a 2 dias). Na App Store aparece o seu nome como vendedor.
- **Empresa (Organization), ex.: KSA Grand Construction LLC:** aparece o nome da empresa. Precisa de um **número D-U-N-S** (grátis, pedido em dnb.com, demora de 1 a 2 semanas) e um site da empresa. A Apple liga para confirmar.

---

## 1. Preparar o banco (uma vez, 2 minutos)

A Apple exige que quem cria conta no app consiga **excluir a conta pelo próprio app**. O botão "Excluir minha conta" já está no Bolso, mas o banco precisa da função:

1. Abra o Supabase → seu projeto → **SQL Editor** → **New query**.
2. Cole todo o conteúdo do arquivo `supabase-excluir-conta.sql` (está nesta pasta) e clique em **Run**.
3. Deve aparecer "Success. No rows returned".

---

## 2. Abrir o projeto e testar

1. Dê dois cliques em **`Bolso.xcodeproj`**. O Xcode abre o projeto.
2. Na barra da esquerda, clique no ícone azul **Bolso** (o primeiro item) → alvo **Bolso** → aba **Signing & Capabilities**.
3. Em **Team**, escolha sua conta de desenvolvedor. Se não aparecer, clique em **Add Account…** e entre com seu Apple ID.
4. **Bundle Identifier:** já vem como `com.ksagrandconstruction.bolso`. Pode manter. Se o Xcode reclamar que já existe, troque por algo único, como `com.ksagrand.bolso`.

**Testar no iPhone (simulador):**
1. No topo do Xcode, ao lado do botão ▶, escolha um simulador, ex.: **iPhone 16 Pro Max**.
2. Aperte **▶** (ou ⌘R). O simulador abre com o Bolso.
3. Entre com seu e-mail e senha e teste: criar mês, digitar valores, PDF, Excel, Sair.

**Testar no iPad:** escolha um simulador **iPad Pro 13-inch** e aperte ▶.

**Testar no Mac:** escolha **My Mac** e aperte ▶. O Bolso abre numa janela do Mac.

**Testar no seu iPhone de verdade (opcional, recomendado):**
1. Ligue o iPhone no Mac com o cabo e toque em "Confiar".
2. No iPhone: **Ajustes → Privacidade e Segurança → Modo de Desenvolvedor → ativar** (o iPhone reinicia).
3. No Xcode, escolha seu iPhone na lista e aperte ▶.

---

## 3. Criar uma conta de teste para a Apple

O Bolso pede login, então o revisor da Apple precisa de uma conta para entrar.

1. Abra https://thechrisart.github.io/bolso/ e toque em **Ainda não tenho conta**.
2. Use um e-mail que você controle, ex.: `bolso.revisao@gmail.com`, e uma senha simples de digitar.
3. Confirme o e-mail, entre e **preencha 2 ou 3 meses com valores de exemplo**, para o revisor ver o app funcionando.
4. Guarde o e-mail e a senha: vão no passo 6.

---

## 4. Tirar as capturas de tela

A App Store exige imagens de cada aparelho. Use a conta de teste com os meses preenchidos.

| Aparelho | Simulador | Tamanho exigido |
|---|---|---|
| iPhone | iPhone 16 Pro Max (ou mais novo, "Pro Max") | 1320 × 2868 ou 1290 × 2796 |
| iPad | iPad Pro 13-inch | 2064 × 2752 ou 2048 × 2732 |
| Mac | My Mac | 2880 × 1800, 2560 × 1600, 1440 × 900 ou 1280 × 800 |

- **iPhone/iPad:** com o app aberto no simulador, aperte **⌘S**. A imagem vai para a Mesa do Mac.
- **Mac:** deixe a janela do Bolso grande e use **⇧⌘4**, depois **barra de espaço**, e clique na janela. Depois ajuste o tamanho no app Pré-Visualização (**Ferramentas → Ajustar Tamanho**) para 2880 × 1800.

Tire de 3 a 5 de cada: mês preenchido, conta vencendo em vermelho, aba Ano com gráfico e tela de login.

---

## 5. Criar o app no App Store Connect

1. Entre em **https://appstoreconnect.apple.com** → **Apps** → botão **+** → **Novo app**.
2. Preencha:
   - **Plataformas:** marque **iOS** e **macOS**.
   - **Nome:** precisa ser único na App Store. "Bolso" provavelmente já existe; tente **"Bolso: Controle Financeiro"** ou **"Bolso Finanças"**. Até 30 caracteres.
   - **Idioma principal:** Português (Brasil).
   - **ID do pacote (Bundle ID):** escolha `com.ksagrandconstruction.bolso`. Se não aparecer, faça antes o passo 7 (enviar o primeiro build) ou crie o ID em developer.apple.com → Certificates, IDs & Profiles → Identifiers.
   - **SKU:** `bolso-001` (é um código interno seu).
   - **Acesso:** Acesso total.

---

## 6. Preencher as informações do app

### Informações do app (menu da esquerda)
- **Subtítulo:** `Ganhos, contas e gastos do mês`
- **Categoria:** Finanças
- **Classificação etária:** responda "Não" a tudo → fica **4+**.

### Privacidade do app
- **URL da política de privacidade:** `https://thechrisart.github.io/bolso/privacidade.html`
- Clique em **Começar** no questionário "Coleta de dados" → **Sim, coletamos dados**:
  - **Informações de contato → Endereço de e-mail**
  - **Informações financeiras → Outras informações financeiras**
- Para cada um responda: uso **Funcionalidade do app**; **vinculado à identidade: Sim**; **usado para rastreamento: Não**.

### Preço e disponibilidade
- **Preço:** Grátis (US$ 0).
- **Disponibilidade:** todos os países ou só os que você quiser.

### Versão 1.0 para iOS (e depois a de macOS, com os mesmos textos)
- **Capturas de tela:** arraste as do iPhone e do iPad (passo 4).
- **Texto promocional:** `Controle seus ganhos, contas fixas, gastos variáveis e extras, mês a mês.`
- **Descrição:**
  ```
  O Bolso organiza o dinheiro do mês de um jeito simples.

  • Ganhos, contas fixas, gastos variáveis e gastos extras separados
  • Totais e saldo calculados enquanto você digita
  • Marque cada conta como paga e veja quanto falta pagar
  • Contas que vencem em até 3 dias ficam destacadas em vermelho
  • Abas de janeiro a dezembro e visão do ano com gráfico
  • Copie o mês anterior com um toque
  • Exporte o mês ou o ano em PDF e Excel
  • Sincroniza entre iPhone, iPad, Mac e navegador

  Seus dados ficam protegidos na sua conta. Sem anúncios e sem rastreamento.
  ```
- **Palavras-chave:** `finanças,orçamento,gastos,contas,despesas,controle financeiro,planilha,dinheiro`
- **URL de suporte:** `https://thechrisart.github.io/bolso/privacidade.html#suporte`
- **Copyright:** `2026 KSA Grand Construction` (ou seu nome)
- **Informações para a revisão do app:**
  - **Login necessário:** marque e coloque o e-mail e a senha da conta de teste (passo 3).
  - **Notas:**
    ```
    Bolso is a personal budgeting app. Sign in with the demo account above.
    Months can be opened from the tabs at the top. Bills due within 3 days are highlighted in red.
    PDF and Excel export open the system share sheet (iOS) or a Save dialog (macOS).
    Account deletion: scroll to the bottom of any month and tap "Excluir minha conta" (Delete my account).
    ```
  - **Contato:** seu nome, telefone e e-mail.

---

## 7. Enviar o app (build) para a Apple

Faça isto duas vezes: uma para iPhone/iPad e outra para Mac.

**iPhone e iPad:**
1. No Xcode, no seletor de destino ao lado do ▶, escolha **Any iOS Device (arm64)**.
2. Menu **Product → Archive**. Espere terminar (1 a 3 minutos).
3. Abre a janela **Organizer**. Selecione o arquivo e clique em **Distribute App** → **App Store Connect** → **Distribute**.
4. Aguarde "Upload Successful".

**Mac:**
1. Escolha o destino **Any Mac (Apple Silicon, Intel)**.
2. **Product → Archive** → **Distribute App** → **App Store Connect** → **Distribute**.

A Apple processa cada build em 15 a 60 minutos e manda um e-mail quando terminar.

**Toda vez que enviar uma nova versão**, aumente o número em **Signing & Capabilities → General → Build** (1, 2, 3…). Para uma versão nova na loja, aumente também a **Version** (1.0 → 1.1).

---

## 8. Enviar para revisão

1. No App Store Connect, abra a versão **iOS 1.0** → seção **Build** → **+** → escolha o build enviado.
2. Se aparecer a pergunta sobre **criptografia**, responda que o app **não usa criptografia própria** (só HTTPS do sistema). O projeto já declara isso.
3. Clique em **Adicionar para revisão** → **Enviar para revisão do app**.
4. Repita para a versão **macOS 1.0** com o build do Mac.

A revisão costuma levar de 24 a 48 horas. Você recebe e-mail quando o status mudar.

---

## 9. Se a Apple recusar

O motivo mais comum para apps feitos a partir de um site é a **regra 4.2 (Funcionalidade mínima)**. O Bolso tem argumentos a favor: login, dados sincronizados, exportação nativa (Compartilhar/Salvar) e funciona como app, não como um site aberto num navegador. Se recusarem:

1. Leia a mensagem no **Centro de Resoluções** do App Store Connect.
2. Responda explicando o que o app faz (pode usar o texto da descrição) ou me mande a mensagem que eu te ajudo a responder ou a ajustar o app.

Outros motivos comuns, já resolvidos neste projeto:
- **Exclusão de conta (5.1.1):** botão "Excluir minha conta" no rodapé.
- **Política de privacidade:** página publicada e link no login e no rodapé.
- **Conta de teste:** passo 3.

---

## 10. Atualizar o app depois

Quando o app web mudar:
1. Copie os arquivos novos (`index.html`, `config.js`…) para a pasta **`Bolso/Web`** deste projeto, substituindo os antigos.
2. Aumente o **Build** (e a **Version**, se for versão nova na loja).
3. Repita os passos 7 e 8.

O site no GitHub continua funcionando separado, com os mesmos dados.

---

## Materiais oficiais da Apple (com vídeos)

- Inscrição no Apple Developer Program: https://developer.apple.com/programs/enroll/
- Ajuda do App Store Connect (passo a passo com imagens): https://developer.apple.com/help/app-store-connect/
- Enviar seu app: https://developer.apple.com/app-store/submitting/
- Diretrizes de revisão da App Store: https://developer.apple.com/app-store/review/guidelines/
- Tamanhos de capturas de tela: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/
- Vídeos oficiais da Apple (busque "App Store Connect" e "Distribute your app"): https://developer.apple.com/videos/
