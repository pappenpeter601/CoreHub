# Kafka Schemas and Policies (Draft)

## Naming & Structure
- Topic format: domain.event_name (e.g., order.created, invoice.posted, bank.tx.imported, gl.journal.posted, pricing.rule.changed, audit.appended).
- Key: business aggregate id (order_id, invoice_id, bank_tx_id, rule_id). Ensures ordering per aggregate.
- Partitions: start 6-12 per active domain; increase with throughput; maintain key-based partitioning.

## Event Envelope (JSON baseline)
```json
{
  "event_id": "uuid",
  "event_type": "order.created",
  "occurred_at": "2026-01-18T12:00:00Z",
  "producer": "orders-service",
  "trace_id": "uuid",
  "tenant_id": "uuid",
  "version": 1,
  "payload": { "...domain fields..." },
  "signature": "optional-signature"
}
```

## Core Event Payloads (indicative)
- order.created: {order_id, customer_id, currency, totals, lines[{line_id, sku, qty, price, tax_code}], status}
- order.confirmed: {order_id, confirmed_at}
- delivery.created: {delivery_id, order_id, ship_date, warehouse_id, items[{line_id, qty}]}
- invoice.posted: {invoice_id, sources[{source_type, source_id}], doc_date, due_date, totals, legal_entity_id}
- payment.captured: {payment_id, invoice_id, amount, currency, received_at, method, provider_order_id?, provider_capture_id?}
- bank.statement.imported: {statement_id, account_ref, source_type, imported_at}
- bank.tx.matched: {bank_tx_id, open_item_id, confidence, decided_by}
- gl.journal.posted: {journal_entry_id, doc_type, doc_id, lines[{account_id, debit, credit, cost_refs}]}
- pricing.rule.changed: {rule_id, version, active_from, active_to, scope, adjustments}
- tax.rule.changed: {rule_id, country, region, rate, valid_from, valid_to}
- audit.appended: {audit_log_id, entity_type, entity_id, event_type, occurred_at, actor_id}

## Avro/Schema Registry Plan
- Introduce Schema Registry with Avro after PoC; keep JSON during PoC for speed.
- Strategy: envelope stays stable; payload evolves with backward-compatible changes (additive fields). Use version field.
- Compatibility: backward-compatible by default; require approval for breaking changes.

## Retention & Compaction
- Business events: 7-14 days retention; also maintain compacted topic per aggregate where needed for current state (e.g., order.state, pricing.rule.state).
- Audit/finance critical events: 30-90 days retention; consider offloading to immutable store; optional compaction for state topics.
- DLQ per domain: 14-30 days retention; include error cause in headers.

## Headers
- trace_id, tenant_id, schema_version, idempotency_key (if applicable), signature (if signing enabled).

## DLQ Policy
- Each consumer has a domain DLQ (e.g., order.dlq, finance.dlq).
- Push message with headers: error_type, error_message, stacktrace(optional), consumer_group.
- Operational playbook: retry with backoff; cap attempts; alert on DLQ growth; periodic reprocess job.

## Security & Compliance
- TLS and auth (SASL/OAuth); per-tenant isolation via ACLs if multi-tenant Kafka.
- PII minimization in events; avoid sensitive fields in payloads; prefer IDs.
- Sign critical events (finance/audit) and hash-chain anchors stored separately for tamper evidence.

## Monitoring
- Lag per consumer group; DLQ growth; partition skew; schema error rates; end-to-end latency dashboards.
