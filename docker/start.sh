#!/usr/bin/env sh

echo "✼ Start intentarverwaltung, database already created in image."
exec /usr/bin/supervisord -c /etc/supervisord.conf
