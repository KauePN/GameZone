# Configuração do Supabase no GameZone

## 1. Criar o projeto

Abra o Supabase Dashboard e crie um projeto chamado `GameZone`.

## 2. Criar tabela e políticas

No SQL Editor, execute todo o conteúdo abaixo:

```sql
create table public.games (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  genre text not null,
  platform text not null,
  year integer,
  description text,
  cover_url text,
  created_at timestamptz not null default now()
);

alter table public.games enable row level security;

create policy "Users can view their own games"
on public.games
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own games"
on public.games
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own games"
on public.games
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own games"
on public.games
for delete
to authenticated
using (auth.uid() = user_id);

grant select, insert, update, delete
on public.games
to authenticated;
```

## 3. Authentication

Em Authentication > Providers, deixe o provedor Email habilitado.

Durante os testes escolares, você pode desativar a confirmação de e-mail. Se a confirmação ficar habilitada, o aluno deverá confirmar o e-mail antes de conseguir uma sessão de login.

## 4. Conectar o Flutter

No painel do Supabase, abra Connect e copie:

- Project URL
- Publishable key

No arquivo `lib/main.dart`, coloque os valores nestas constantes:

```dart
const supabaseUrl = 'COLE_AQUI_A_PROJECT_URL';
const supabasePublishableKey = 'COLE_AQUI_A_PUBLISHABLE_KEY';
```

Use somente a chave pública/publishable key no aplicativo.

## 5. Rodar

No terminal:

```powershell
cd C:\Kaue\gamezone
flutter pub get
flutter run
```
