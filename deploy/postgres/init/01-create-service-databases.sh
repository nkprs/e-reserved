#!/bin/sh
set -eu

create_service_database() {
  db_name="$1"
  role_name="$2"
  role_password="$3"

  psql \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --set=db_name="$db_name" \
    --set=role_name="$role_name" \
    --set=role_password="$role_password" \
    -v ON_ERROR_STOP=1 <<'SQL'
SELECT format(
  'CREATE ROLE %I LOGIN PASSWORD %L',
  :'role_name',
  :'role_password'
) \gexec

SELECT format(
  'CREATE DATABASE %I OWNER %I',
  :'db_name',
  :'role_name'
) \gexec
SQL
}

create_service_database user_db user_app "$USER_DB_PASSWORD"
create_service_database order_db order_app "$ORDER_DB_PASSWORD"
create_service_database payment_db payment_app "$PAYMENT_DB_PASSWORD"