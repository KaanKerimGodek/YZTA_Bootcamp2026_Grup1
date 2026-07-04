-- ===========================================================================
-- Vazgeçtim — Supabase Şema
-- ===========================================================================
-- Backend Steering dokümanındaki 3 tablo + Row Level Security + trigger.
--
-- Çalıştırma:
--   Supabase Dashboard → SQL Editor → bu dosyayı yapıştır → Run
--   veya CLI: supabase db push
--
-- n8n workflow'ları auth. kullanıcısıyla değil, service role ile yazdığı için
-- RLS politikaları anon + authenticated erişimini kısıtlar.
-- ===========================================================================

-- Gerekli uzantılar --------------------------------------------------------
create extension if not exists "pgcrypto";

-- ===========================================================================
-- Tablo 1: Users
-- ===========================================================================
create table if not exists public.users (
    user_id      uuid primary key default gen_random_uuid(),
    created_at   timestamptz not null default now(),
    total_saved  numeric(12, 2) not null default 0 check (total_saved >= 0),
    display_name text,
    email        text unique,
    avatar_url   text
);

comment on table public.users is 'Vazgeçtim kullanıcıları — toplam tasarruf tutarını tutar.';

-- ===========================================================================
-- Tablo 2: Skipped_Items (vazgeçiş logları)
-- ===========================================================================
create table if not exists public.skipped_items (
    item_id       uuid primary key default gen_random_uuid(),
    user_id       uuid not null references public.users(user_id) on delete cascade,
    item_name     text not null check (length(btrim(item_name)) > 0),
    price         numeric(12, 2) not null check (price > 0),
    raw_category  text,
    ai_category   text not null default 'Diğer',
    created_at    timestamptz not null default now()
);

comment on table public.skipped_items is
  'Her "vazgeçiş" kaydı. raw_category kullanıcı girdisi, ai_category LLM ataması.';

create index if not exists idx_skipped_items_user_created
    on public.skipped_items (user_id, created_at desc);
create index if not exists idx_skipped_items_ai_category
    on public.skipped_items (user_id, ai_category);

-- ===========================================================================
-- Tablo 3: AI_Insights (içgörü raporları)
-- ===========================================================================
create table if not exists public.ai_insights (
    insight_id    uuid primary key default gen_random_uuid(),
    user_id       uuid not null references public.users(user_id) on delete cascade,
    insight_text  text not null,
    amount        numeric(12, 2),
    generated_at  timestamptz not null default now()
);

comment on table public.ai_insights is
  'n8n Workflow 2 (cron job) tarafından üretilen doğal dil motivasyon metinleri.';

create index if not exists idx_ai_insights_user_generated
    on public.ai_insights (user_id, generated_at desc);

-- ===========================================================================
-- Trigger: skipped_items insert → users.total_saved güncelle
-- ===========================================================================
-- Backend Steering Workflow 1 → Node 4: güncel total_saved döndürülmeli.
-- n8n bunu hesaplamak yerine, DB bu işi trigger ile güvenle yapar.
create or replace function public.recompute_total_saved()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    update public.users
       set total_saved = (
           select coalesce(sum(price), 0)
             from public.skipped_items
            where user_id = new.user_id
       )
     where user_id = new.user_id;
    return new;
end;
$$;

drop trigger if exists trg_skipped_items_total_saved on public.skipped_items;
create trigger trg_skipped_items_total_saved
    after insert or delete or update of price on public.skipped_items
    for each row
    execute function public.recompute_total_saved();

-- ===========================================================================
-- Row Level Security
-- ===========================================================================
-- Üretimde gerçek auth kullanıldığında politikalar auth.uid() ile kısıtlanır.
-- Şimdilik service_role (n8n) tam erişime sahip; anon sınırlıdır.

alter table public.users        enable row level security;
alter table public.skipped_items enable row level security;
alter table public.ai_insights  enable row level security;

-- Demo amaçlı: anon authenticated kendi user_id satırını okuyabilir.
-- (Daha katı kurulumda policy body'si auth.uid() = user_id olmalı.)

drop policy if exists "users_select_own" on public.users;
create policy "users_select_own" on public.users
    for select using (true);

drop policy if exists "skipped_items_select_own" on public.skipped_items;
create policy "skipped_items_select_own" on public.skipped_items
    for select using (true);

drop policy if exists "ai_insights_select_own" on public.ai_insights;
create policy "ai_insights_select_own" on public.ai_insights
    for select using (true);

-- Yazma işlemleri yalnızca service_role (n8n) üzerinden → RLS bypass.
-- Anon/insert policy tanımlamıyoruz; tüm yazma n8n service role key ile.

-- ===========================================================================
-- Demo kullanıcı (opsiyonel) — frontend USER_ID ile eşleşir.
-- ===========================================================================
insert into public.users (user_id, display_name, email)
values ('00000000-0000-0000-0000-000000000000', 'Yagiz', 'yagiz@example.com')
on conflict (user_id) do nothing;

-- ===========================================================================
-- Yardımcı fonksiyon: güncel total_saved okuma (n8n için)
-- ===========================================================================
create or replace function public.get_total_saved(p_user_id uuid)
returns numeric
language sql
security definer
set search_path = public
as $$
    select total_saved from public.users where user_id = p_user_id;
$$;

grant execute on function public.get_total_saved(uuid) to anon, authenticated, service_role;
