# Avro Schemas (Draft)

## Envelope (referenced by payload schemas)
```json
{
  "type": "record",
  "name": "EventEnvelope",
  "namespace": "corehub.events",
  "fields": [
    {"name": "event_id", "type": "string"},
    {"name": "event_type", "type": "string"},
    {"name": "occurred_at", "type": {"type": "long", "logicalType": "timestamp-millis"}},
    {"name": "producer", "type": "string"},
    {"name": "trace_id", "type": "string"},
    {"name": "tenant_id", "type": "string"},
    {"name": "version", "type": "int"},
    {"name": "payload", "type": "bytes"},
    {"name": "signature", "type": ["null", "string"], "default": null}
  ]
}
```
> Payload stored as Avro binary; schema ID from registry in message headers.

## order.created
```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "corehub.orders",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "customer_id", "type": "string"},
    {"name": "currency", "type": "string"},
    {"name": "status", "type": "string"},
    {"name": "totals", "type": {"type": "record", "name": "OrderTotals", "fields": [
      {"name": "net", "type": "double"},
      {"name": "tax", "type": "double"},
      {"name": "gross", "type": "double"}
    ]}},
    {"name": "lines", "type": {"type": "array", "items": {
      "name": "OrderLine",
      "type": "record",
      "fields": [
        {"name": "line_id", "type": "string"},
        {"name": "sku", "type": "string"},
        {"name": "qty", "type": "double"},
        {"name": "price", "type": "double"},
        {"name": "tax_code", "type": ["null", "string"], "default": null}
      ]
    }}}
  ]
}
```

## invoice.posted
```json
{
  "type": "record",
  "name": "InvoicePosted",
  "namespace": "corehub.invoices",
  "fields": [
    {"name": "invoice_id", "type": "string"},
    {"name": "sources", "type": {"type": "array", "items": {
      "name": "InvoiceSource",
      "type": "record",
      "fields": [
        {"name": "source_type", "type": "string"},
        {"name": "source_id", "type": "string"}
      ]
    }}},
    {"name": "doc_date", "type": {"type": "int", "logicalType": "date"}},
    {"name": "due_date", "type": {"type": "int", "logicalType": "date"}},
    {"name": "totals_net", "type": "double"},
    {"name": "totals_tax", "type": "double"},
    {"name": "totals_gross", "type": "double"},
    {"name": "legal_entity_id", "type": "string"}
  ]
}
```

## bank.tx.matched
```json
{
  "type": "record",
  "name": "BankTxMatched",
  "namespace": "corehub.banking",
  "fields": [
    {"name": "bank_tx_id", "type": "string"},
    {"name": "open_item_id", "type": "string"},
    {"name": "confidence", "type": "double"},
    {"name": "decided_by", "type": ["null", "string"], "default": null},
    {"name": "decided_at", "type": ["null", {"type": "long", "logicalType": "timestamp-millis"}], "default": null}
  ]
}
```

## delivery.created
```json
{
  "type": "record",
  "name": "DeliveryCreated",
  "namespace": "corehub.fulfillment",
  "fields": [
    {"name": "delivery_id", "type": "string"},
    {"name": "order_id", "type": "string"},
    {"name": "ship_date", "type": {"type": "int", "logicalType": "date"}},
    {"name": "warehouse_id", "type": "string"},
    {"name": "items", "type": {"type": "array", "items": {
      "name": "DeliveryItem",
      "type": "record",
      "fields": [
        {"name": "order_line_id", "type": "string"},
        {"name": "qty", "type": "double"}
      ]
    }}}
  ]
}
```

## return.created
```json
{
  "type": "record",
  "name": "ReturnCreated",
  "namespace": "corehub.fulfillment",
  "fields": [
    {"name": "return_id", "type": "string"},
    {"name": "order_id", "type": "string"},
    {"name": "reason", "type": ["null", "string"], "default": null},
    {"name": "items", "type": {"type": "array", "items": {
      "name": "ReturnItem",
      "type": "record",
      "fields": [
        {"name": "order_line_id", "type": "string"},
        {"name": "qty", "type": "double"}
      ]
    }}}
  ]
}
```

## ap.payment.posted
```json
{
  "type": "record",
  "name": "ApPaymentPosted",
  "namespace": "corehub.ap",
  "fields": [
    {"name": "ap_payment_id", "type": "string"},
    {"name": "supplier_invoice_id", "type": "string"},
    {"name": "amount", "type": "double"},
    {"name": "currency", "type": "string"},
    {"name": "paid_at", "type": {"type": "long", "logicalType": "timestamp-millis"}}
  ]
}
```

## cost.allocation.run
```json
{
  "type": "record",
  "name": "CostAllocationRun",
  "namespace": "corehub.costing",
  "fields": [
    {"name": "distribution_run_id", "type": "string"},
    {"name": "rule_id", "type": "string"},
    {"name": "period_id", "type": "string"},
    {"name": "executed_at", "type": {"type": "long", "logicalType": "timestamp-millis"}},
    {"name": "status", "type": "string"},
    {"name": "result_ref", "type": ["null", "string"], "default": null}
  ]
}
```

## payment.captured
```json
{
  "type": "record",
  "name": "PaymentCaptured",
  "namespace": "corehub.payments",
  "fields": [
    {"name": "payment_id", "type": "string"},
    {"name": "invoice_id", "type": "string"},
    {"name": "method", "type": "string"},
    {"name": "provider_order_id", "type": ["null", "string"], "default": null},
    {"name": "provider_capture_id", "type": ["null", "string"], "default": null},
    {"name": "amount", "type": "double"},
    {"name": "currency", "type": "string"},
    {"name": "captured_at", "type": {"type": "long", "logicalType": "timestamp-millis"}}
  ]
}
```

## audit.appended
```json
{
  "type": "record",
  "name": "AuditAppended",
  "namespace": "corehub.audit",
  "fields": [
    {"name": "audit_log_id", "type": "string"},
    {"name": "entity_type", "type": "string"},
    {"name": "entity_id", "type": "string"},
    {"name": "event_type", "type": "string"},
    {"name": "occurred_at", "type": {"type": "long", "logicalType": "timestamp-millis"}},
    {"name": "actor_id", "type": ["null", "string"], "default": null},
    {"name": "trace_id", "type": ["null", "string"], "default": null}
  ]
}
```

> Use backward-compatible changes only (additive fields). Store schema IDs in headers; envelope remains stable.
