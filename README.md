# A Muralha Digital

Ambiente Docker para testar filtros com Nginx, Squid e FTP.

## Servicos

- `nginx`: portal HTTP com paginas e diretorio `/imagens/`.
- `squid`: proxy HTTP em `localhost:3128` e proxy FTP nativo em `localhost:2121`.
- `ftp`: servidor FTP com usuario `student` e senha `student`.

## Subir o ambiente

```bash
docker compose up -d --no-build
docker compose ps
```

Somente o Squid fica exposto no host. O Nginx e o FTP ficam internos na rede Docker para evitar acesso direto sem filtro.

Se precisar reconstruir as imagens:

```bash
docker compose up -d --build
```

Importante: desative temporariamente o proxy do Windows antes de usar `--build`. Se o Windows/Docker Desktop estiver configurado para usar `localhost:3128` e o Squid ainda nao estiver rodando, o Docker pode tentar baixar imagens pelo proprio Squid e falhar.

## Tarefa A: Nginx + Squid

Configure o Chrome/Windows para usar proxy HTTP:

- Host: `localhost` ou o IP da WSL2.
- Porta: `3128`.

No campo de proxy do Windows, use apenas `localhost`, sem `http://`.

URLs de teste pelo proxy:

- Liberada: `http://portal.local/`
- Bloqueada por palavra `sexo`: `http://portal.local/sexo.html`
- Bloqueada por palavra `sexy`: `http://portal.local/sexy.html`
- Bloqueada por palavra `playboy`: `http://portal.local/playboy.html`
- Bloqueada por diretorio `imagens`: `http://portal.local/imagens/`

### Excecao por IP

Edite `squid/allowed_ips.txt` e coloque o IP do Windows ou do colega, um por linha:

```txt
192.168.1.50
```

Depois reinicie o Squid:

```bash
docker compose restart squid
```

Para descobrir o IP que o Squid esta enxergando, acompanhe o access log enquanto faz uma requisicao pelo proxy:

```bash
docker compose exec squid tail -f /var/log/squid/access.log
```

## Tarefa B: FTP + Squid

O Squid tambem escuta como proxy FTP nativo na porta `2121`. Para testar sem FileZilla, use `telnet`:

```bash
telnet localhost 2121
```

Login FTP pelo Squid:

```txt
USER student@ftp.local
PASS student
PWD
QUIT
```

Download de `.txt` bloqueado:

```txt
USER student@ftp.local
PASS student
PASV
RETR bloqueado.txt
QUIT
```

Upload de `.pdf` bloqueado:

```txt
USER student@ftp.local
PASS student
PASV
STOR upload/teste.pdf
QUIT
```

Quando o Squid bloquear, a resposta esperada e:

```txt
451-ERR_ACCESS_DENIED
451 Forbidden
```

Arquivos iniciais no FTP:

- `permitido.md`: download permitido.
- `bloqueado.txt`: download bloqueado pelo Squid.

Regras configuradas:

- Upload de `.pdf` bloqueado.
- Download de `.txt` bloqueado.

## Testes por terminal

Com o ambiente rodando:

```bash
./tests/test-proxy.sh
```

Resultado esperado:

```txt
Resumo: 9 OK, 0 erro(s)
```

Os testes usam `ftp://` passando pelo proxy HTTP do Squid em `3128`. Eles validam rapidamente as ACLs principais.

## Comandos uteis

Ver logs do Squid:

```bash
docker compose logs -f squid
```

Ver access log do Squid:

```bash
docker compose exec squid tail -f /var/log/squid/access.log
```

Parar o ambiente:

```bash
docker compose down
```

## Referencias usadas

- Squid `ftp_port`: https://www.squid-cache.org/Doc/config/ftp_port/
- Squid FTP relay: https://wiki.squid-cache.org/Features/FtpRelay
- Squid ACLs: https://wiki.squid-cache.org/SquidFaq/SquidAcl
