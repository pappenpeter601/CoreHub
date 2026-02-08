# CoreHub OpenAPI Stubs (Draft Outline)

## Conventions
- Versioned base path: /v1
- Idempotency-Key header on POST creating side effects.
- Trace-Id header echoed in responses; error payloads include trace_id, code, message, details.
- Auth: Bearer JWT (Keycloak); magic-link token for verify endpoints.

## Auth/IAM
```yaml
POST /v1/auth/login:
  requestBody: {email, password}
  responses: 200 {access_token, refresh_token}
POST /v1/auth/magic-link:
  requestBody: {email}
  responses: 202
POST /v1/auth/verify-magic:
  requestBody: {token}
  responses: 200 {access_token}
GET /v1/users: paginated; filters: status, email
POST /v1/users: create user
PATCH /v1/users/{id}: update
GET /v1/roles; POST /v1/roles; POST /v1/roles/{id}/permissions
POST /v1/feature-flags/{key}/toggle
```

## Catalog/Pricing
```yaml
GET /v1/articles; POST /v1/articles
GET /v1/variants; POST /v1/variants
POST /v1/articles/{id}/variants
POST /v1/price-rules
POST /v1/pricing/simulate: {items, customer, shop, date}
POST /v1/tax/validate: {items, country, region, date}
```

## Orders & Fulfillment
```yaml
GET/POST /v1/orders
POST /v1/orders/{id}/confirm
POST /v1/orders/{id}/deliver
POST /v1/orders/{id}/return
GET/POST /v1/deliveries
```

## Invoicing & Documents
```yaml
GET/POST /v1/invoices
  - POST payload supports sources: [{source_type: order|delivery|invoice|credit_note|return, source_id}]
POST /v1/invoices/{id}/issue
POST /v1/invoices/{id}/pdf
GET/POST /v1/credit-notes
POST /v1/credit-notes/{id}/pdf
POST /v1/credit-notes/{id}/post
GET/POST /v1/number-ranges
GET /v1/number-ranges?doc_type=invoice&fiscal_year=YYYY&legal_entity_id=UUID
```

## Inventory
```yaml
POST /v1/stock-movements
POST /v1/reservations
POST /v1/adjustments
```

## Procurement
```yaml
GET/POST /v1/purchase-orders
POST /v1/purchase-orders/{id}/receive
POST /v1/supplier-invoices
  - payload: {supplier_id, purchase_order_id?, invoice_no, totals}
POST /v1/supplier-invoices/{id}/post
```

## Finance/GL
```yaml
POST /v1/journal-entries
GET /v1/accounts
GET /v1/open-items
POST /v1/reconciliation/match
```

## Banking
```yaml
POST /v1/bank-statements/import (csv|mt940)
GET /v1/bank-tx
POST /v1/bank-tx/{id}/match
```

## Communication
```yaml
POST /v1/messages
POST /v1/notifications
GET/POST /v1/templates
```

## Common Schemas (indicative)
- Money: {amount: number, currency: string}
- Address: {line1, line2, postal_code, city, country}
- LineItem: {sku, description, qty, uom, price, tax_code, cost_refs}
- Error: {trace_id, code, message, details}

> Full OpenAPI can be generated from these stubs; include ETag/If-Match on updates of critical resources (orders, invoices, price rules).
