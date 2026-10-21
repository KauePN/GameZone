#  GameZone

Projeto AV1 desenvolvido com Flutter e Dart.

## Sobre

O GameZone é uma aplicação para gerenciamento de uma biblioteca pessoal de jogos. O sistema possui autenticação de usuários e CRUD completo utilizando **Supabase Auth** e **Supabase PostgreSQL**.

## Funcionalidades

- Login com e-mail e senha
- Cadastro de usuário
- Validação de formulários
- Cadastro de jogos
- Consulta dos jogos
- Edição de jogos
- Exclusão de jogos
- Interface responsiva
- Identidade visual própria
- Banco de dados persistente
- Manual técnico em HTML/CSS

## Tecnologias

- Flutter
- Dart
- Supabase Auth
- Supabase PostgreSQL
- Git/GitHub
- HTML5
- CSS3

## Configuração

1. Crie um projeto em https://supabase.com/dashboard.
2. Crie a tabela `games` executando o SQL de `SUPABASE_SETUP.md`.
3. Confira se o provedor de e-mail está habilitado em Authentication.
4. Abra `lib/main.dart`.
5. Substitua `COLE_AQUI_A_PROJECT_URL` pela URL do seu projeto.
6. Substitua `COLE_AQUI_A_PUBLISHABLE_KEY` pela Publishable key do seu projeto.
7. Execute:

```bash
flutter pub get
flutter run
```

> Nunca coloque a `service_role` key no aplicativo Flutter. Use apenas a chave pública/publishable key.

## Banco de dados

```text
games
├── id
├── user_id
├── title
├── genre
├── platform
├── year
├── description
├── cover_url
└── created_at
```

A tabela utiliza Row Level Security (RLS) para que cada usuário autenticado possa acessar apenas os próprios jogos.

## Estrutura do projeto

```text
lib/
├── models/
├── screens/
├── services/
├── widgets/
├── theme/
└── utils/

manual/
├── index.html
└── style.css
```

## Build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Git

```bash
git add .
git commit -m "feat: migra autenticação e banco para Supabase"

git add .
git commit -m "feat: implementa CRUD de jogos com Supabase"

git add .
git commit -m "docs: atualiza README e manual"
```
