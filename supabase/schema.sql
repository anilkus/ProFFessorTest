-- ProFFessorTest veritabanı şeması
-- Supabase panelinde: SQL Editor -> New query -> bu dosyanın tamamını yapıştır -> Run.
-- En alttaki adminler satırına kendi e-posta adresini yaz.

-- ── Tablolar ──────────────────────────────────────────────
create table if not exists public.hocalar (
  id         text primary key,
  isim       text not null check (char_length(isim) between 3 and 120),
  uni        text check (char_length(uni) <= 150),
  created_at timestamptz not null default now()
);

create table if not exists public.yorumlar (
  id           text primary key,
  hoca_id      text not null references public.hocalar(id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  email_domain text not null default split_part(auth.jwt() ->> 'email', '@', 2),
  rol          text not null check (rol in ('ogrenci','mezun','meslektas')),
  genel        int  not null check (genel between 1 and 5),
  cats         jsonb not null default '{}',
  metin        text not null check (char_length(metin) between 20 and 3000),
  donem        text check (char_length(donem) <= 20),
  barkod       text check (char_length(barkod) <= 40),
  durum        text not null default 'bekleyen' check (durum in ('bekleyen','onaylandi','reddedildi')),
  agirlik      numeric not null default 1,
  tarih        text check (char_length(tarih) <= 20),
  created_at   timestamptz not null default now(),
  unique (hoca_id, user_id)            -- her hesap, her hocaya en fazla 1 yorum
);

create table if not exists public.adminler (
  email text primary key
);

-- ── Yardımcı: giriş yapan kişi admin mi? ──────────────────
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.adminler where email = auth.jwt() ->> 'email');
$$;
grant execute on function public.is_admin() to anon, authenticated;

-- ── Satır güvenliği (RLS) ─────────────────────────────────
alter table public.hocalar  enable row level security;
alter table public.yorumlar enable row level security;
alter table public.adminler enable row level security;   -- politika yok: kimse okuyamaz/yazamaz

drop policy if exists hocalar_oku   on public.hocalar;
drop policy if exists hocalar_ekle  on public.hocalar;
drop policy if exists hocalar_sil   on public.hocalar;
create policy hocalar_oku  on public.hocalar for select to anon, authenticated using (true);
create policy hocalar_ekle on public.hocalar for insert to anon, authenticated with check (true);
create policy hocalar_sil  on public.hocalar for delete to authenticated using (public.is_admin());

drop policy if exists yorumlar_oku      on public.yorumlar;
drop policy if exists yorumlar_ekle     on public.yorumlar;
drop policy if exists yorumlar_guncelle on public.yorumlar;
drop policy if exists yorumlar_sil      on public.yorumlar;
-- Ham tabloyu sadece admin ve yorumun sahibi görür (herkese açık liste aşağıdaki view'dan).
create policy yorumlar_oku on public.yorumlar for select to authenticated
  using (public.is_admin() or user_id = auth.uid());
-- Yorum yazmak: doğrulanmış .edu.tr e-postası ya da mezuniyet belgesi barkodu olan mezun.
create policy yorumlar_ekle on public.yorumlar for insert to authenticated
  with check (
    user_id = auth.uid()
    and durum = 'bekleyen'
    and email_domain = split_part(auth.jwt() ->> 'email', '@', 2)
    and (
      (auth.jwt() ->> 'email') like '%.edu.tr'
      or (rol = 'mezun' and char_length(coalesce(barkod, '')) >= 8)
    )
  );
create policy yorumlar_guncelle on public.yorumlar for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy yorumlar_sil on public.yorumlar for delete to authenticated
  using (public.is_admin());

-- ── Herkese açık, onaylı yorumlar (kimlik bilgisi içermez) ──
create or replace view public.yorumlar_public as
  select id, hoca_id, rol, genel, cats, metin, donem, tarih, agirlik, email_domain, created_at
  from public.yorumlar
  where durum = 'onaylandi';
grant select on public.yorumlar_public to anon, authenticated;

-- ── Admin ────────────────────────────────────────────────
-- Kendi e-posta adresini yaz ve bu satırı da çalıştır:
-- insert into public.adminler (email) values ('ornek@gmail.com') on conflict do nothing;
