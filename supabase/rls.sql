-- HELPER FUNCTIONS
create or replace function is_building_admin(b_id uuid) returns boolean
language sql security definer stable as $$
  select exists(select 1 from memberships
    where user_id = auth.uid() and building_id = b_id
    and role in ('building_admin','building_co_admin') and status = 'active');
$$;

create or replace function is_building_member(b_id uuid) returns boolean
language sql security definer stable as $$
  select exists(select 1 from memberships
    where user_id = auth.uid() and building_id = b_id and status = 'active');
$$;

-- ENABLE RLS
alter table profiles enable row level security;
alter table buildings enable row level security;
alter table units enable row level security;
alter table memberships enable row level security;
alter table dues_periods enable row level security;
alter table dues_invoices enable row level security;
alter table payments enable row level security;
alter table announcements enable row level security;
alter table announcement_reads enable row level security;
alter table issues enable row level security;
alter table issue_comments enable row level security;
alter table expenses enable row level security;
alter table documents enable row level security;
alter table polls enable row level security;
alter table poll_options enable row level security;
alter table votes enable row level security;
alter table subscriptions enable row level security;
alter table notifications enable row level security;
alter table invitations enable row level security;

-- PROFILES
create policy "self_profile" on profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "same_building_profiles" on profiles for select using (
  exists(select 1 from memberships m1 join memberships m2 on m1.building_id = m2.building_id
    where m1.user_id = auth.uid() and m2.user_id = profiles.id));

-- BUILDINGS
create policy "members_view_building" on buildings for select using (is_building_member(id));
create policy "admin_update_building" on buildings for update using (is_building_admin(id));
create policy "anyone_create_building" on buildings for insert with check (created_by = auth.uid());

-- UNITS, MEMBERSHIPS, PERIODS, ANNOUNCEMENTS, EXPENSES, DOCUMENTS, POLLS — admin CRUD, members view
create policy "members_view_units" on units for select using (is_building_member(building_id));
create policy "admin_crud_units" on units for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));

create policy "members_view_memberships" on memberships for select using (is_building_member(building_id));
create policy "admin_crud_memberships" on memberships for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));

create policy "members_view_periods" on dues_periods for select using (is_building_member(building_id));
create policy "admin_crud_periods" on dues_periods for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));

create policy "members_view_announcements" on announcements for select using (is_building_member(building_id));
create policy "admin_crud_announcements" on announcements for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));

create policy "self_ann_reads" on announcement_reads for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "members_view_expenses" on expenses for select using (is_building_member(building_id));
create policy "admin_crud_expenses" on expenses for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));

create policy "members_view_documents" on documents for select using (is_building_member(building_id));
create policy "admin_crud_documents" on documents for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));

-- INVOICES (sakin sadece kendi unit'i)
create policy "view_invoices" on dues_invoices for select using (
  is_building_admin((select building_id from dues_periods where id = period_id))
  or unit_id in (select unit_id from memberships where user_id = auth.uid())
);
create policy "admin_modify_invoices" on dues_invoices for all
  using (is_building_admin((select building_id from dues_periods where id = period_id)))
  with check (is_building_admin((select building_id from dues_periods where id = period_id)));

-- PAYMENTS
create policy "view_payments" on payments for select using (
  payer_user_id = auth.uid() or is_building_admin(building_id));
create policy "create_payment" on payments for insert with check (
  payer_user_id = auth.uid() or is_building_admin(building_id));

-- ISSUES
create policy "members_view_issues" on issues for select using (is_building_member(building_id));
create policy "members_create_issue" on issues for insert
  with check (is_building_member(building_id) and reporter_id = auth.uid());
create policy "reporter_or_admin_update_issue" on issues for update
  using (reporter_id = auth.uid() or is_building_admin(building_id));

create policy "members_view_comments" on issue_comments for select
  using (is_building_member((select building_id from issues where id = issue_id)));
create policy "members_add_comment" on issue_comments for insert with check (
  is_building_member((select building_id from issues where id = issue_id)) and author_id = auth.uid());

-- POLLS
create policy "members_view_polls" on polls for select using (is_building_member(building_id));
create policy "admin_crud_polls" on polls for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));
create policy "members_view_options" on poll_options for select
  using (is_building_member((select building_id from polls where id = poll_id)));
create policy "admin_crud_options" on poll_options for all
  using (is_building_admin((select building_id from polls where id = poll_id)));
create policy "members_view_votes" on votes for select
  using (is_building_member((select building_id from polls where id = poll_id)));
create policy "members_cast_vote" on votes for insert with check (
  voter_id = auth.uid() and is_building_member((select building_id from polls where id = poll_id)));

-- SUBSCRIPTIONS, NOTIFICATIONS, INVITATIONS
create policy "admin_view_subscription" on subscriptions for select using (is_building_admin(building_id));
create policy "admin_update_subscription" on subscriptions for update using (is_building_admin(building_id));

create policy "self_notifications" on notifications for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "admin_manage_invitations" on invitations for all using (is_building_admin(building_id))
  with check (is_building_admin(building_id));