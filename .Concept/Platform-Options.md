# Platform Options & Recommendations (Draft)

## Databases
- **MariaDB 10 (current choice)**
  - Pros: familiar MySQL dialect; easy self-host; compatible with AWS Aurora MySQL for future lift; good community tooling.
  - Cons: manual scaling/HA if self-hosted; limited managed features vs. cloud engines.
  - When to choose: quick start, on-prem/VM, smooth path to Aurora.
- **PostgreSQL**
  - Pros: richer SQL (window funcs, JSONB, partial indexes), strong extensions; wide managed support.
  - Cons: Migration effort from MySQL dialect; PHP ORM/driver parity mostly fine but need testing.
  - When to choose: heavier reporting, complex queries, future analytics; if comfortable switching early.
- **Aurora MySQL (cloud managed)**
  - Pros: managed HA/backups, read replicas, autoscaling storage; MySQL-compatible (keeps current schema largely intact).
  - Cons: Cloud lock-in; higher cost than self-host; requires AWS infra.
  - When to choose: cloud move with minimal SQL changes; reduce ops toil.
- **Aurora PostgreSQL**
  - Pros: managed Postgres strengths; good for future analytics; HA and replicas.
  - Cons: SQL dialect shift; migration effort; AWS-specific.
  - When to choose: cloud + richer SQL; willing to migrate early.

**Recommendation:** Start on MariaDB (current plan) with strict SQL modes and utf8mb4; design schemas cloud-ready. Keep migration path open to Aurora MySQL. If we expect heavy analytical workloads soon, reconsider Postgres early before data volume grows.

## Backend / Runtime
- **PHP monolith (current)**
  - Pros: fastest to ship; direct fit with existing plan; simple hosting; broad talent pool.
  - Cons: Monolith scaling limits; background jobs need separate worker; typed safety depends on discipline.
  - When to choose: fast MVP, small team, existing PHP comfort.
- **PHP + gradual services (containers)**
  - Pros: allows extraction of hot spots (Identity, Pricing, Workflow) into services; still reuse code; can add message queue, cache.
  - Cons: More DevOps complexity; service contracts needed; distributed tracing required.
  - When to choose: step after MVP, with Kafka/queue in place.
- **Node/TypeScript services (select domains)**
  - Pros: strong SDK ecosystem, typed; good for integration-heavy services (webhooks, adapters, shop connectors); can coexist with PHP front.
  - Cons: polyglot overhead; two runtimes to maintain.
  - When to choose: for edge/integration services while core stays PHP.
- **Full microservices now**
  - Pros: scalable, team autonomy.
  - Cons: heavy upfront complexity; slower initial delivery; ops load.
  - When to choose: not recommended for MVP.

**Recommendation:** Start PHP monolith + worker, modular boundaries in code. Plan to containerize and peel out services where needed (Identity, Pricing, Workflow, Integrations) once load/complexity grows.

## Frontend
- **Server-rendered PHP (initial)**
  - Pros: simplest path; SEO-friendly; minimal build tooling.
  - Cons: Less dynamic UX; harder to deliver SPA-like interactions; state handling more manual.
  - When to choose: admin/backoffice; quick forms; low JS sophistication needed.
- **SPA (React/Vue) + API**
  - Pros: rich UX, offline/PWA options, better mobile experience, component reuse; pairs well with APIs; easier portal UX.
  - Cons: More tooling (bundler, state mgmt); SEO needs SSR/hydration if public.
  - When to choose: customer portal, self-service, dashboards.
- **Hybrid (SSR + SPA islands)**
  - Pros: keep PHP SSR for shell/SEO; mount SPA components where needed; progressive migration.
  - Cons: Two render stacks; shared design system required.

**Recommendation:** Start with PHP-rendered pages for backoffice/admin; build the customer portal as a SPA (React or Vue) against the APIs. Add SSR/hydration for public/shop pages if needed. Use a shared design system and REST APIs from day one to enable gradual migration.

## Cloud vs. Self-Hosted
- **Self-hosted (VM/docker on-prem/VPS)**
  - Pros: fast start, low initial cost; full control.
  - Cons: DIY HA/backup/monitoring; slower scaling; ops burden.
- **Cloud managed (AWS as target)**
  - Pros: managed DB (Aurora), MQ (SQS/SNS/Kafka MSK), object storage, CDN, WAF; easier HA/DR.
  - Cons: Ongoing cost; cloud lock-in; needs IaC and ops maturity.

**Recommendation:** Start self-hosted or simple cloud VM for MVP; keep infra-as-code; aim to move DB to Aurora MySQL and add managed MQ/cache/object storage when traffic/ops justify. Design stateless app nodes and externalize session/storage to ease the lift.

## UX & Mobile
- Prioritize responsive layouts and PWA-ready portal; magic-link login optimized for mobile; API-first to support future mobile apps.

## Summary Choices (pragmatic path)
- DB: MariaDB now; keep Aurora MySQL migration path open. Revisit Postgres early if analytics-heavy.
- Backend: PHP monolith + worker; containerize later; optionally add Node/TS for integrations.
- Frontend: PHP SSR for admin/backoffice; SPA (React/Vue) for customer portal; shared design system.
- Hosting: start simple; target managed cloud services when scale/ops demand it.
