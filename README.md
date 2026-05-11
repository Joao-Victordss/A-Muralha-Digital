# A Muralha Digital

Ambiente Docker para testar filtros com Nginx, Squid e FTP.

## Servicos

- `nginx`: portal HTTP com paginas e diretorio `/imagens/`.
- `squid`: proxy HTTP em `localhost:3128` e proxy FTP nativo em `localhost:2121`.
- `ftp`: servidor FTP com usuario `student` e senha `student`.

## Subir o ambiente

```bash
docker compose up --build
```

Somente o Squid fica exposto no host. O Nginx e o FTP ficam internos na rede Docker para evitar acesso direto sem filtro.

## Tarefa A: Nginx + Squid

Configure o Chrome/Windows para usar proxy HTTP:

- Host: IP da WSL2 ou `localhost`, se estiver acessando pela propria maquina.
- Porta: `3128`.

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

Para descobrir o IP que o Squid esta enxergando, acompanhe os logs enquanto faz uma requisicao pelo proxy:

```bash
docker compose logs -f squid
```

## Tarefa B: FTP + Squid

O Squid tambem escuta como proxy FTP nativo na porta `2121`. No FileZilla:

- Abra `Editar > Configuracoes > FTP > Proxy FTP`.
- Tipo de proxy: `USER@HOST`.
- Proxy host: IP da WSL2 ou `localhost`.
- Proxy port: `2121`.
- Ao conectar, use host `ftp.local`, usuario `student`, senha `student`.

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

Os testes usam `ftp://` passando pelo proxy HTTP do Squid em `3128`. Eles nao substituem o teste com Chrome/FileZilla, mas validam rapidamente as ACLs principais.

## Referencias usadas

- Squid `ftp_port`: https://www.squid-cache.org/Doc/config/ftp_port/
- Squid FTP relay: https://wiki.squid-cache.org/Features/FtpRelay
- Squid ACLs: https://wiki.squid-cache.org/SquidFaq/SquidAcl
