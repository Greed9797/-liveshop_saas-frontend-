# Livelab SaaS React

Nova versão React/Vite do frontend LiveShop SaaS, criada para substituir a camada Flutter Web/CanvasKit em deploys Vercel.

## Rodar localmente

```bash
npm install
cp .env.example .env.local
npm run dev
```

Configure a API em `.env.local`:

```bash
VITE_API_URL=http://127.0.0.1:3001/v1
```

Para usar Railway/staging:

```bash
VITE_API_URL=https://liveshop-saas-api-production.up.railway.app/v1
```

## Build

```bash
npm run build
npm run preview
```

O build gera `dist/`, compatível com Vercel como static site.

## Deploy na Vercel

Configuração sugerida:

- Root Directory: `react-app`
- Build Command: `npm run build`
- Output Directory: `dist`
- Environment Variable: `VITE_API_URL=https://.../v1`

O backend Fastify usa allowlist CORS. Antes de publicar em Vercel, inclua o domínio final da Vercel em `CORS_ORIGIN` no backend, por exemplo:

```bash
CORS_ORIGIN=https://app.grupolivelab.com.br,https://seu-projeto.vercel.app
```

Validação feita em 2026-05-12: Railway responde `/health`, aceita preflight de `https://app.grupolivelab.com.br` e `https://livelab-3601f.web.app`, mas rejeita `http://127.0.0.1:5173` e domínios Vercel não cadastrados.

## Migrado nesta etapa

- Login/autenticação com JWT + refresh.
- Layout responsivo com sidebar por papel.
- Dashboard de unidade.
- Dashboard Master, unidades, consolidado e CRM.
- Dashboard cliente parceiro e histórico de lives.
- Cabines, solicitações, apresentadoras, analytics, financeiro e base de conhecimento.
- API client centralizado em `src/services/api.ts`.

## Ainda falta

- Fluxos avançados de edição/criação em CRM, contratos, usuários e Knowledge Base.
- Detalhes de cabine/live com SSE.
- Agenda completa do cliente parceiro.
- Perfil/configurações do cliente parceiro.
- E2E Playwright para login e smoke das rotas principais.
