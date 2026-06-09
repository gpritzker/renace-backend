#!/bin/bash
set -e

# Reinicia Sidekiq automáticamente si muere
(while true; do
  echo "[start.sh] Iniciando Sidekiq..."
  bundle exec sidekiq || true
  echo "[start.sh] Sidekiq terminó, reiniciando en 5s..."
  sleep 5
done) &

bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RAILS_ENV:-production}
