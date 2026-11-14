-- Assisted by Claude (SI) — reviewed by <Ilya Cortés Ruiz>
create table if not exists cuadrantes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  ra double precision not null,
  dec double precision not null,
  fov numeric default 2,
  epoca_a text,
  epoca_b text,
  estado text not null default 'pendiente' check (estado in ('pendiente', 'confirmado', 'descartado')),
  es_objeto_prueba boolean,
  tipo_prueba text check (tipo_prueba in ('movimiento', 'brillo')),
  url_dinamica text,
  creado_en timestamptz default now()
);

create table if not exists reportes (
  id uuid primary key default gen_random_uuid(),
  cuadrante_id uuid not null references cuadrantes(id),
  ra double precision not null,
  dec double precision not null,
  tipo text not null check (tipo in ('movimiento', 'brillo', 'limpio')),
  creado_en timestamptz default now()
);

create table if not exists validaciones (
  id uuid primary key default gen_random_uuid(),
  reporte_id uuid not null references reportes(id),
  coincide boolean not null,
  es_simulado boolean default false,
  creado_en timestamptz default now()
);

create or replace view vw_reportes_confirmados as
select reporte_id, count(*) as votos_coinciden
from validaciones
where coincide = true
group by reporte_id
having count(*) >= 3;

insert into cuadrantes (nombre, ra, dec, fov, es_objeto_prueba, tipo_prueba, url_dinamica) values
  ('Barnard''s Star', 269.452075, 4.693365, 2, true, 'movimiento', '/?ra=17h57m&dec=+4d41m&fov=2'),
  ('WISE 0855-0714', 133.795133, -7.245146, 2, true, 'movimiento', '/?ra=08h55m&dec=-7d14m&fov=2'),
  ('Epsilon Indi B', 331.044147, -56.782844, 2, true, 'movimiento', '/?ra=22h04m&dec=-56d47m&fov=2'),
  ('RW Aurigae', 76.956067, 30.401326, 2, true, 'brillo', '/?ra=05h07m&dec=+30d24m&fov=2'),
  ('R Draconis', 248.167625, 66.754972, 2, true, 'brillo', '/?ra=16h32m&dec=+66d45m&fov=2')
on conflict (nombre) do nothing;