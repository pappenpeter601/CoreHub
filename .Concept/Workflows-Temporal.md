# CoreHub Temporal Workflows (Draft)

## Order-to-Cash Workflow
- Steps (activities):
  1) validate_order
  2) reserve_stock
  3) confirm_order
  4) create_delivery
  5) capture_shipment (optional tracking)
  6) create_invoice
  7) issue_invoice (assign number, lock data, render PDF/XRechnung)
  8) post_gl_entry
  9) send_invoice_email
 10) await_payment (timer; listen to payment.matched event)
 11) reconcile_payment (close open item)
- Compensations: release_stock_reservation; cancel_delivery; void_invoice_draft; reverse_gl_entry (if posted) before finalization.
- Timeouts/Retry: per-activity exponential backoff; heartbeats on external calls (PDF, email); SLA timer for payment (dunning trigger).

## Procure-to-Pay Workflow
- Steps: create_po -> optional approval -> send_to_supplier (email/API) -> receive_goods -> three_way_match -> post_ap -> schedule_payment -> mark_paid.
- Compensations: reverse_receipt; cancel_ap_entry prior to payment; notify purchasing.

## Invoice Correction Workflow
- Steps: detect_issue -> create_credit_note -> issue_credit_note -> post_gl_entry -> notify_customer -> (optional) create_replacement_invoice.
- Rule: original invoice is never deleted; corrections happen via credit notes and replacement invoices.

## Bank Reconciliation Workflow
- Steps: import_statement -> parse_lines -> match_candidates (rules+AI) -> human_review_task for low confidence -> post_matches -> emit events.
- Timers: reminder for pending tasks; SLA breach alerts.

## Pricing/Tax Update Workflow
- Steps: draft_rule -> simulate -> approval_gate -> activate_flag -> emit pricing.rule.changed.
- Compensation: revert to previous version; deactivate faulty rule.

## Magic-Link Auth Workflow
- Steps: generate_token -> send_email -> verify_token -> create_session -> optional_device_binding.
- Guards: rate limit per IP/email; short token TTL.

## Technical Notes
- Idempotent activity design (use business keys); saga pattern for compensations.
- Use task queues per domain; activity heartbeats for long-running I/O.
  - reserve_stock: {order_id, lines[{stock_item_id|article_variant_id, qty}]}
  - create_invoice: {sources[{source_type, source_id}], invoice_id?, currency, lines[{order_line_id, qty, price, tax_code}]}
  - post_gl_entry: {doc_type, doc_id, lines[{account_id, debit, credit, cost_refs}]}
  - send_invoice_email: {invoice_id, customer_email, pdf_uri, locale}
  - match_bank_tx: {bank_tx_id, candidates[{open_item_id, confidence}]}
  - generate_magic_link: {user_id, email, ttl_seconds}

  - payment_received(order_id or open_item_id)
  - manual_match_decision(bank_tx_id, open_item_id, confidence)
  - query workflow_status (returns step, last_error, retries)

## PayPal/PSP Payment Workflow (deferred)
- Placeholder for future PSP integration; detailed steps (capture, webhooks, reconciliation, refunds) will be defined when payments move into scope.
