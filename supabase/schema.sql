-- ENUMS
create type user_role as enum ('super_admin','building_admin','building_co_admin','accountant','resident','owner');
create type subscription_tier as enum ('free','standard','pro','site');
create type subscription_status as enum ('active','past_due','canceled','trialing');
create type unit_type as enum ('apartment','shop','office','depot','parking');
create type dues_status as enum ('pending','partial','paid','overdue','waived');
create type payment_status as enum ('initiated','succeeded','failed','refunded');
create type payment_method as enum ('iyzico','bank_transfer','cash','other');
create type issue_status as enum ('open','in_progress','resolved','closed','rejected');
create type issue_priority as enum ('low','medium','high','urgent');
create type issue_category as enum ('plumbing','electric','elevator','heating','cleaning','security','common_area','other');
create type expense_category as enum ('elevator','heating','electric','water','cleaning','security','maintenance','salaries','tax','other');
create type announcement_priority as enum ('info','important','urgent');
create type poll_status as enum ('draft','active','closed');

-- PROFILES
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null, phone text unique, email text,
  avatar_url text, notification_token text, language text default 'tr',
  created_at timestamptz default now(), updated_at timestamptz default now()
);

-- BUILDINGS
create table public.buildings (
  id uuid primary key default gen_random_uuid(),
  name text not null, address text, city text, district text,
  iban text, iban_owner text, logo_url text, total_units int default 0,
  monthly_dues_amount numeric(10,2), dues_due_day int default 5,
  late_fee_percent numeric(5,2) default 0,
  created_by uuid references profiles(id),
  created_at timestamptz default now(), updated_at timestamptz default now()
);

-- UNITS
create table public.units (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  block text, floor int, door_number text not null,
  type unit_type default 'apartment', size_m2 numeric(7,2),
  share_ratio numeric(7,4), custom_dues_amount numeric(10,2),
  is_active boolean default true,
  created_at timestamptz default now(),
  unique(building_id, block, door_number)
);

-- MEMBERSHIPS
create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  building_id uuid not null references buildings(id) on delete cascade,
  unit_id uuid references units(id) on delete set null,
  role user_role not null, is_primary_contact boolean default false,
  invited_by uuid references profiles(id), joined_at timestamptz default now(),
  status text default 'active',
  unique(user_id, building_id, role, unit_id)
);

-- INVITATIONS
create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  unit_id uuid references units(id) on delete set null,
  role user_role not null, phone text, email text,
  invite_code text unique not null,
  invited_by uuid references profiles(id),
  expires_at timestamptz default (now() + interval '14 days'),
  used_at timestamptz, created_at timestamptz default now()
);

-- DUES
create table public.dues_periods (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  period_year int not null,
  period_month int not null check (period_month between 1 and 12),
  due_date date not null, default_amount numeric(10,2) not null,
  description text, is_locked boolean default false,
  created_by uuid references profiles(id), created_at timestamptz default now(),
  unique(building_id, period_year, period_month)
);

create table public.dues_invoices (
  id uuid primary key default gen_random_uuid(),
  period_id uuid not null references dues_periods(id) on delete cascade,
  unit_id uuid not null references units(id) on delete cascade,
  amount numeric(10,2) not null, paid_amount numeric(10,2) default 0,
  status dues_status default 'pending', late_fee numeric(10,2) default 0,
  notes text, created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(period_id, unit_id)
);

-- PAYMENTS
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  unit_id uuid references units(id) on delete set null,
  invoice_id uuid references dues_invoices(id) on delete set null,
  payer_user_id uuid references profiles(id),
  amount numeric(10,2) not null, method payment_method not null,
  status payment_status default 'initiated',
  iyzico_payment_id text, iyzico_conversation_id text,
  bank_transaction_ref text, receipt_url text,
  paid_at timestamptz, created_at timestamptz default now()
);

-- ANNOUNCEMENTS
create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  author_id uuid references profiles(id), title text not null, body text not null,
  priority announcement_priority default 'info', attachment_urls text[],
  pinned boolean default false, published_at timestamptz default now(),
  expires_at timestamptz, created_at timestamptz default now()
);

create table public.announcement_reads (
  announcement_id uuid references announcements(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  read_at timestamptz default now(),
  primary key (announcement_id, user_id)
);

-- ISSUES
create table public.issues (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  unit_id uuid references units(id) on delete set null,
  reporter_id uuid references profiles(id),
  assignee_id uuid references profiles(id),
  title text not null, description text,
  category issue_category default 'other',
  priority issue_priority default 'medium',
  status issue_status default 'open',
  photo_urls text[], resolved_at timestamptz,
  created_at timestamptz default now(), updated_at timestamptz default now()
);

create table public.issue_comments (
  id uuid primary key default gen_random_uuid(),
  issue_id uuid not null references issues(id) on delete cascade,
  author_id uuid references profiles(id), body text not null,
  attachment_urls text[], created_at timestamptz default now()
);

-- EXPENSES, DOCUMENTS, POLLS, SUBSCRIPTIONS, NOTIFICATIONS, AUDIT
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  category expense_category default 'other',
  vendor text, description text not null,
  amount numeric(10,2) not null, expense_date date not null,
  receipt_url text, created_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  title text not null, category text, file_url text not null,
  file_size_bytes int, uploaded_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table public.polls (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references buildings(id) on delete cascade,
  title text not null, description text, status poll_status default 'draft',
  is_anonymous boolean default false, multi_choice boolean default false,
  closes_at timestamptz, created_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table public.poll_options (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid not null references polls(id) on delete cascade,
  label text not null, position int default 0
);

create table public.votes (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid not null references polls(id) on delete cascade,
  option_id uuid not null references poll_options(id) on delete cascade,
  voter_id uuid references profiles(id),
  unit_id uuid references units(id),
  weight numeric(7,4) default 1,
  created_at timestamptz default now(),
  unique(poll_id, unit_id)
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null unique references buildings(id) on delete cascade,
  tier subscription_tier default 'free',
  status subscription_status default 'trialing',
  trial_ends_at timestamptz default (now() + interval '30 days'),
  current_period_start timestamptz, current_period_end timestamptz,
  iyzico_subscription_ref text, amount numeric(10,2),
  created_at timestamptz default now(), updated_at timestamptz default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  building_id uuid references buildings(id) on delete cascade,
  type text not null, title text not null, body text, data jsonb,
  read_at timestamptz, created_at timestamptz default now()
);

create table public.audit_logs (
  id bigint generated by default as identity primary key,
  actor_id uuid references profiles(id),
  building_id uuid references buildings(id),
  action text not null, entity_type text, entity_id uuid,
  metadata jsonb, created_at timestamptz default now()
);

-- INDEXES
create index idx_buildings_created_by on buildings(created_by);
create index idx_units_building on units(building_id);
create index idx_memberships_user on memberships(user_id);
create index idx_memberships_building on memberships(building_id);
create index idx_invoices_period on dues_invoices(period_id);
create index idx_invoices_unit on dues_invoices(unit_id);
create index idx_invoices_status on dues_invoices(status);
create index idx_payments_invoice on payments(invoice_id);
create index idx_announcements_building_pub on announcements(building_id, published_at desc);
create index idx_issues_building_status on issues(building_id, status);
create index idx_expenses_building_date on expenses(building_id, expense_date desc);
create index idx_notifications_user_unread on notifications(user_id) where read_at is null;

-- TRIGGERS
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

create trigger trg_buildings_upd before update on buildings for each row execute function set_updated_at();
create trigger trg_units_upd before update on units for each row execute function set_updated_at();
create trigger trg_invoices_upd before update on dues_invoices for each row execute function set_updated_at();
create trigger trg_issues_upd before update on issues for each row execute function set_updated_at();
create trigger trg_subs_upd before update on subscriptions for each row execute function set_updated_at();

create or replace function init_subscription_for_new_building() returns trigger as $$
begin insert into subscriptions (building_id) values (new.id); return new; end;
$$ language plpgsql;
create trigger trg_buildings_init_sub after insert on buildings
  for each row execute function init_subscription_for_new_building();

create or replace function update_invoice_on_payment() returns trigger as $$
begin
  if new.status = 'succeeded' and (old.status is null or old.status <> 'succeeded') then
    update dues_invoices
    set paid_amount = paid_amount + new.amount,
        status = case when paid_amount + new.amount >= amount then 'paid'
                     when paid_amount + new.amount > 0 then 'partial' else status end
    where id = new.invoice_id;
  end if;
  return new;
end;
$$ language plpgsql;
create trigger trg_payments_update_invoice after insert or update on payments
  for each row execute function update_invoice_on_payment();