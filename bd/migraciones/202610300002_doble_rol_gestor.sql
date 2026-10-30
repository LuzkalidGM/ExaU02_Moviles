-- Aplicar después de 202610300001_gestor_movil.sql.
-- Una cuenta de Supabase Auth puede ser deportista y gestora a la vez.
begin;

alter table public.usuarios_instalaciones
  add column if not exists nombre_negocio varchar(100),
  add column if not exists ruc varchar(11);

create or replace function public.crear_gestor_movil()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.raw_user_meta_data->>'tipo_cuenta' = 'gestor' then
    insert into public.usuarios_instalaciones
      (username, auth_id, tipo_usuario, estado, nombre_negocio, ruc)
    values (
      'movil_' || left(replace(new.id::text, '-', ''), 32), new.id,
      'gestor', 1,
      nullif(left(trim(new.raw_user_meta_data->>'nombre_institucion'), 100), ''),
      nullif(left(trim(new.raw_user_meta_data->>'ruc'), 11), '')
    );
  end if;
  return new;
end;
$$;

create or replace function public.registrar_gestor_actual(
  p_nombre text, p_ruc text
) returns integer language plpgsql security definer set search_path = '' as $$
declare v_id integer;
begin
  if (select auth.uid()) is null then
    raise exception 'Inicia sesión' using errcode = '42501';
  end if;
  if length(trim(coalesce(p_nombre, ''))) not between 1 and 100
     or coalesce(p_ruc, '') !~ '^[0-9]{11}$' then
    raise exception 'Nombre o RUC inválido' using errcode = '22023';
  end if;
  insert into public.usuarios_instalaciones
    (username, auth_id, tipo_usuario, estado, nombre_negocio, ruc)
  values (
    'movil_' || left(replace((select auth.uid())::text, '-', ''), 32),
    (select auth.uid()), 'gestor', 1, trim(p_nombre), p_ruc
  ) on conflict (auth_id) do nothing;
  select id into v_id from public.usuarios_instalaciones
    where auth_id = (select auth.uid()) and estado = 1;
  return v_id;
end;
$$;
revoke all on function public.registrar_gestor_actual(text, text) from public;
grant execute on function public.registrar_gestor_actual(text, text) to authenticated;

commit;
