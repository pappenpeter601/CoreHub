# Cost Calculation & Hosting Options (MVP)

## Current Setup
- IONOS Web Hosting + MariaDB: ~$5-20/month (depending on plan)

## Additional Services Needed

| Service | Purpose | MVP Option A (Defer) | MVP Option B (Lean) | MVP Option C (Premium) | Cost Range |
|---------|---------|----------------------|----------------------|------------------------|-----------|
| **Message Queue / Events** | Kafka for async order/invoice events | File-based queue + cron (free, unreliable) | Upstash Kafka free tier | AWS SNS/SQS or Kafka MSK | $0 / $0-10 / $0.50-2 |
| **Identity / Auth** | Keycloak or managed auth | Simplified PHP magic-link + sessions (free) | Auth0 free tier (5K users) | Keycloak self-host or Auth0 paid | $0 / $0-13 / $25+ |
| **Workflow Engine** | Temporal for order-to-cash, reconciliation | PHP cron + state machine (free, slow) | Self-host Temporal on cheap VPS | Temporal Cloud managed | $0 / $5-10 / $25+ |
| **Caching** | Redis for sessions, catalog | PHP file-based cache (free, slower) | IONOS add-on or Upstash Redis free tier | Managed Redis (DigitalOcean, AWS) | $0 / $0-10 / $5-20 |
| **Object Storage** | PDFs, attachments, invoices | IONOS file system (free, limited) | Backblaze B2 or DigitalOcean Spaces | AWS S3 or managed | $0 / $5 / $5-50 |
| **Monitoring / Logging** | Error tracking, uptime | PHP file logging (free, basic) | Sentry free tier or Upstash Logs | Sentry paid or ELK | $0 / $0-10 / $29+ |

## MVP Cost Scenarios

### Scenario 1: Minimal (No external services)
- IONOS hosting + MariaDB: $5-20/month
- Everything in PHP (auth, queue, cache, storage): Free
- **Total: $5-20/month** ✓ Cheapest
- Trade-off: Slower, less reliable, limited scalability; acceptable for MVP testing.

### Scenario 2: Balanced (Recommended for MVP launch)
- IONOS hosting + MariaDB: $5-20/month
- Auth0 free tier (or IONOS email + PHP magic-link): $0-5/month
- Upstash Kafka free tier: $0/month
- PHP cron + simple state machine for workflows: $0/month
- File-based cache/storage: $0/month
- **Total: $5-25/month** ✓ Recommended
- Trade-off: Functional, reasonable reliability; ready for customer beta.

### Scenario 3: Growth (Scale after MVP validation)
- IONOS hosting + MariaDB: $5-20/month (or migrate to Aurora MySQL: +$20-50/month)
- Auth0 paid tier or Keycloak self-host: $13-25/month
- Upstash Kafka standard tier: $10-30/month
- Self-hosted Temporal on cheap VPS: $5-10/month
- Managed Redis (e.g., Upstash): $10-20/month
- S3-compatible storage (Backblaze B2 or Spaces): $5-10/month
- Sentry error tracking: $29+/month
- **Total: $77-184/month** (scaling tier)
- Trade-off: Professional reliability, auto-scaling, better ops observability.

## When to Add Services (by milestone)

### MVP (now → 3 months)
- Keep everything on IONOS.
- Defer: Temporal, advanced caching, advanced monitoring.
- Optional: Upstash Kafka free tier for early async patterns.

### Beta (3-6 months)
- If order volume grows: Add Upstash Kafka paid tier ($10-20/month).
- If auth complexity rises: Evaluate Auth0 free → paid ($13/month).
- Monitor PHP performance; add Redis if queries slow down ($5-10/month).

### Production (6+ months)
- Migrate MariaDB to Aurora MySQL for HA ($20-50/month).
- Add managed Kafka or upgrade to cloud (SNS/SQS).
- Deploy Temporal for complex workflows ($5-25/month).
- Add S3/object storage for compliance ($5-50/month).
- Add Sentry for error tracking ($29+/month).

## Cost Comparison: IONOS MVP vs. Full Cloud

| Scenario | IONOS MVP | Full AWS | Delta |
|----------|-----------|----------|-------|
| DB (MariaDB 10 → Aurora) | $10 | $30-50 | +$20-40 |
| App hosting | $10 | $15-40 (EC2/fargate) | +$5-30 |
| Message queue | $0 (file) | $10-30 (SQS/SNS/Kafka MSK) | +$10-30 |
| Cache | $0 (PHP) | $10-20 (ElastiCache) | +$10-20 |
| Storage | $0 (IONOS) | $5-50 (S3) | +$5-50 |
| **Monthly Total** | **~$20** | **~$70-190** | **+$50-170** |

IONOS MVP saves ~$50-170/month at launch; worth it for first validation phase.

## Recommendation
1. **Start with Scenario 2 (Balanced)**: IONOS + Auth0 free + Upstash Kafka free tier. ~$10-25/month.
2. **Milestone checkpoints**: Review costs and service needs every 3 months.
3. **Defer Temporal** until workflow complexity demands it (returns, refunds, multi-approvals).
4. **Add object storage** when compliance/audit archiving becomes critical.
5. **Plan Aurora migration** once IONOS limits appear (CPU, connections, backups).
