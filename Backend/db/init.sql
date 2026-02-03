create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  username text not null unique,
  password_hash text not null,
  created_at timestamptz not null default now()
);

create table if not exists profiles (
  user_id uuid primary key references users(id) on delete cascade,
  username text not null unique,
  name text not null default '',
  headline text not null default '',
  bio text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists skills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  name text not null,
  proficiency int not null check (proficiency between 1 and 10),
  created_at timestamptz not null default now()
);

create table if not exists educations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  school text not null,
  degree text not null,
  major text not null,
  start_year int not null,
  end_year int not null,
  created_at timestamptz not null default now()
);

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  owner_id uuid not null references users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists projects_members (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  username text not null,
  roleKey text not null,
  created_at timestamptz not null default now()
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  title text not null,
  details text not null default '',
  status text not null default 'backlog', -- backlog | inProgress | blocked | done
  assignee_id uuid null references users(id) on delete set null,
  difficulty int not null default 2 check (difficulty between 1 and 5),
  sort_index int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists idx_tasks_project_id on tasks(project_id);
create index if not exists idx_tasks_project_status on tasks(project_id, status);
create index if not exists idx_tasks_project_sort on tasks(project_id, sort_index, created_at);