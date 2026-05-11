#!/usr/bin/env bash
set -euo pipefail

proxy_http="http://localhost:3128"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

pass_count=0
fail_count=0

check_http_code() {
  local label="$1"
  local expected="$2"
  local url="$3"
  local code

  code="$(curl -sS -o /dev/null -w '%{http_code}' -x "$proxy_http" "$url")"

  if [[ "$code" == "$expected" ]]; then
    printf '[OK] %s -> HTTP %s\n' "$label" "$code"
    pass_count=$((pass_count + 1))
  else
    printf '[ERRO] %s -> esperado HTTP %s, recebido HTTP %s\n' "$label" "$expected" "$code"
    fail_count=$((fail_count + 1))
  fi
}

check_command_fails() {
  local label="$1"
  shift

  if "$@" >"$tmp_dir/out" 2>"$tmp_dir/err"; then
    printf '[ERRO] %s -> comando deveria falhar\n' "$label"
    fail_count=$((fail_count + 1))
  else
    printf '[OK] %s -> bloqueado\n' "$label"
    pass_count=$((pass_count + 1))
  fi
}

check_command_succeeds() {
  local label="$1"
  shift

  if "$@" >"$tmp_dir/out" 2>"$tmp_dir/err"; then
    printf '[OK] %s -> permitido\n' "$label"
    pass_count=$((pass_count + 1))
  else
    printf '[ERRO] %s -> comando deveria passar\n' "$label"
    cat "$tmp_dir/err"
    fail_count=$((fail_count + 1))
  fi
}

printf '== Tarefa A: HTTP via Squid ==\n'
check_http_code 'pagina inicial' '200' 'http://portal.local/'
check_http_code 'bloqueio sexo' '403' 'http://portal.local/sexo.html'
check_http_code 'bloqueio sexy' '403' 'http://portal.local/sexy.html'
check_http_code 'bloqueio playboy' '403' 'http://portal.local/playboy.html'
check_http_code 'bloqueio imagens' '403' 'http://portal.local/imagens/'

printf '\n== Tarefa B: FTP via Squid HTTP ==\n'
printf 'PDF bloqueado\n' > "$tmp_dir/bloqueado.pdf"
printf 'MD permitido\n' > "$tmp_dir/permitido-upload.md"

check_command_fails \
  'upload PDF' \
  curl --fail-with-body -sS -x "$proxy_http" -T "$tmp_dir/bloqueado.pdf" 'ftp://student:student@ftp.local/upload/bloqueado.pdf'

check_command_succeeds \
  'upload MD' \
  curl --fail-with-body -sS -x "$proxy_http" -T "$tmp_dir/permitido-upload.md" 'ftp://student:student@ftp.local/upload/permitido-upload.md'

check_command_fails \
  'download TXT' \
  curl --fail-with-body -sS -x "$proxy_http" 'ftp://student:student@ftp.local/bloqueado.txt'

check_command_succeeds \
  'download MD' \
  curl --fail-with-body -sS -x "$proxy_http" 'ftp://student:student@ftp.local/permitido.md'

printf '\nResumo: %s OK, %s erro(s)\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
