# Bolso

Controle financeiro mensal: receitas, contas fixas, gastos variáveis e gastos extras, com abas por mês, visão do ano e exportação em PDF e Excel. Funciona no computador, no tablet e no celular.

- Site: hospedado no GitHub Pages (pasta raiz deste repositório)
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
| `supabase.sql` | Tabela e regras de segurança do banco |
| `manifest.json`, `icon.*` | Ícone para "Adicionar à tela de início" |
