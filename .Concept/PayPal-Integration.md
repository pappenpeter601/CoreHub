# PayPal Integration (Deferred)

This integration is parked until PSP work is prioritized. When in scope, include:
- Create/capture with idempotency keys; store provider order/capture IDs.
- Webhook verification (signature + fetch), idempotent consume, enqueue `payment.captured`/refund events.
- Reconciliation to open items, handling partials/refunds, and GL postings.
- Secrets in a manager; minimal PII; retries + DLQ for robustness.
