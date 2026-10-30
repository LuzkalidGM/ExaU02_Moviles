-- Ejecutar una sola vez en gameon-dev tras revisar el proyecto seleccionado.
-- La aprobación administrativa se simula: las cuentas móviles nacen activas.
begin;

alter table public.usuarios_instalaciones
  add column if not exists auth_id uuid unique references auth.users(id);

-- Nunca se guarda la contraseña de Supabase Auth en la columna heredada del web.
alter table public.usuarios_instalaciones
  alter column password set default md5(gen_random_uuid()::text || clock_timestamp()::text);

create or replace function public.crear_gestor_movil()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.raw_user_meta_data->>'tipo_cuenta' = 'gestor' then
    insert into public.usuarios_instalaciones
      (username, auth_id, tipo_usuario, estado)
    values ('movil_' || left(replace(new.id::text, '-', ''), 32), new.id,
            'gestor', 1);
  end if;
  return new;
end;
$$;

drop trigger if exists crear_gestor_movil_auth on auth.users;
create trigger crear_gestor_movil_auth after insert on auth.users
  for each row execute function public.crear_gestor_movil();

create or replace function public.gestor_actual()
returns integer language sql stable security definer set search_path = '' as $$
  select id from public.usuarios_instalaciones
  where auth_id = (select auth.uid()) and estado = 1 limit 1;
$$;
revoke all on function public.gestor_actual() from public;
grant execute on function public.gestor_actual() to authenticated;

alter table public.usuarios_instalaciones enable row level security;
-- Las credenciales heredadas y claves de pago nunca se exponen por PostgREST.
revoke all on public.usuarios_instalaciones from anon, authenticated;

create policy gestor_crea_centros on public.instituciones_deportivas
  for insert to authenticated with check
  (usuario_instalacion_id = (select public.gestor_actual()));
create policy gestor_edita_centros on public.instituciones_deportivas
  for update to authenticated using
  (usuario_instalacion_id = (select public.gestor_actual())) with check
  (usuario_instalacion_id = (select public.gestor_actual()));

create policy gestor_crea_areas on public.areas_deportivas
  for insert to authenticated with check (exists (
    select 1 from public.instituciones_deportivas i
    where i.id = institucion_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));
create policy gestor_edita_areas on public.areas_deportivas
  for update to authenticated using (exists (
    select 1 from public.instituciones_deportivas i
    where i.id = institucion_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())))
  with check (exists (
    select 1 from public.instituciones_deportivas i
    where i.id = institucion_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));

create policy gestor_crea_horarios on public.areas_horarios
  for insert to authenticated with check (exists (
    select 1 from public.areas_deportivas a
    join public.instituciones_deportivas i on i.id = a.institucion_deportiva_id
    where a.id = area_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));
create policy gestor_edita_horarios on public.areas_horarios
  for update to authenticated using (exists (
    select 1 from public.areas_deportivas a
    join public.instituciones_deportivas i on i.id = a.institucion_deportiva_id
    where a.id = area_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())))
  with check (exists (
    select 1 from public.areas_deportivas a
    join public.instituciones_deportivas i on i.id = a.institucion_deportiva_id
    where a.id = area_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));
create policy gestor_borra_horarios on public.areas_horarios
  for delete to authenticated using (exists (
    select 1 from public.areas_deportivas a
    join public.instituciones_deportivas i on i.id = a.institucion_deportiva_id
    where a.id = area_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));

create policy gestor_crea_deportes on public.instituciones_deportes
  for insert to authenticated with check (exists (
    select 1 from public.instituciones_deportivas i
    where i.id = institucion_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));
create policy gestor_borra_deportes on public.instituciones_deportes
  for delete to authenticated using (exists (
    select 1 from public.instituciones_deportivas i
    where i.id = institucion_deportiva_id
      and i.usuario_instalacion_id = (select public.gestor_actual())));

grant select, insert, update on public.instituciones_deportivas,
  public.areas_deportivas, public.areas_horarios to authenticated;
grant select, insert, delete on public.instituciones_deportes to authenticated;
grant usage, select on sequence public.instituciones_deportivas_id_seq,
  public.areas_deportivas_id_seq, public.areas_horarios_id_seq to authenticated;

insert into storage.buckets (id, name, public)
values ('gestor-imagenes', 'gestor-imagenes', true)
on conflict (id) do nothing;
create policy gestor_subir_imagen on storage.objects
  for insert to authenticated with check (
    bucket_id = 'gestor-imagenes'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select public.gestor_actual()) is not null);
create policy gestor_actualizar_imagen on storage.objects
  for update to authenticated using (
    bucket_id = 'gestor-imagenes'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select public.gestor_actual()) is not null)
  with check (
    bucket_id = 'gestor-imagenes'
    and (storage.foldername(name))[1] = (select auth.uid())::text);

commit;
