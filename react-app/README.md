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
VITE_API_URL=https://liveshop-saas-api-production.up.railway.app/v1
```

Para backend local:

```bash
VITE_API_URL=http://127.0.0.1:3001/v1
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
- Dashboard cliente parceiro, histórico de lives, agenda e configurações.
- CRM com criação/edição de leads, mudança de etapa, contato, tarefa e exclusão.
- Cabines com criação/edição, status, reserva por contrato, histórico, live atual e encerramento.
- Solicitações com aprovar/recusar e criação de agendamento por papel permitido.
- Apresentadoras/equipe com criação, edição, ativação/inativação e exclusão lógica.
- Financeiro com custos, faturamento, fluxo de caixa, boletos e tela detalhada de cobranças.
- Analytics e base de conhecimento em modo leitura.
- API client centralizado em `src/services/api.ts`.
- Matriz de contrato em `../ROUTE_CONTRACT.md`.

## Ainda falta

- Upload multipart de logo no onboarding quando o backend expuser endpoint próprio.
- CRUD admin da Knowledge Base se a base passar a ser gerenciada pelo painel.
- E2E real contra Railway com usuários de teste por papel.
- Smoke test no domínio Vercel e, depois, em `app.grupolivelab.com.br`.
