# CoreHub Data Model – Table Specs (Initial)

## Conventions
- Columns: `id` UUID (unless noted), `tenant_id` UUID, `created_at/by`, `updated_at/by`; `status` as enum; `validity_from/to` for mutable master/rules. Pure junction/link tables may omit audit columns unless explicitly listed.
- Types: `str` varchar, `text`, `int`, `dec` decimal(18,4), `bool`, `dt` datetime, `json`.
- Keys: PK on `id`; FKs noted; unique constraints noted.

## Identity & Access
- user(id, email str unique, password_hash str, status enum, locale str, tenant_id FK, created_at/by, updated_at/by)
- role(id, name str, tenant_id FK, unique(name, tenant_id))
- permission(id, resource str, action str, unique(resource, action))
- user_role(user_id FK, role_id FK, PK(user_id, role_id))
- role_permission(role_id FK, permission_id FK, PK(role_id, permission_id))
- magic_link_token(id, user_id FK, token str unique, fallback_code_hash str, fallback_code_expires_at dt, fallback_code_used_at dt, expires_at dt, used_at dt, ip_hint str, device_hint str)
- session(id, user_id FK, issued_at dt, expires_at dt, revoked_at dt, ip str, ua str)
- feature_flag(id, key str, scope str, value str/json, active_from dt, active_to dt, tenant_id FK, unique(key, tenant_id, scope))

## Master Data
- customer(id, type enum B2C/B2B, legal_entity str, vat_id str, addresses json, contacts json, status, tenant_id FK, validity_from/to, created/updated)
- supplier(id, legal_entity str, vat_id str, addresses json, contacts json, status, tenant_id FK, validity_from/to)
- article(id, name str, status, tenant_id FK, validity_from/to)
- variant(id, sku str unique, name str, attrs json, uom str, status, tenant_id FK, validity_from/to)
- article_variant(id, article_id FK, variant_id FK, base_price dec, status, validity_from/to, unique(article_id, variant_id))
- bundle(id, name str, status, tenant_id FK)
- bundle_item(bundle_id FK, article_id FK, qty dec, PK(bundle_id, article_id))
- product(id, name str, status, tenant_id FK)
- product_bundle(product_id FK, bundle_id FK, qty dec, PK(product_id, bundle_id))
- price_rule(id, scope json (shop, customer_group, channel), currency str, conditions json, adjustments json, validity_from/to, tenant_id FK)
- tax_rule(id, country str, region str, rate dec, type str, reverse_charge bool, validity_from/to, tenant_id FK)
- warehouse(id, name str, location str/json, status, tenant_id FK)

## Inventory
- stock_item(id, article_variant_id FK, warehouse_id FK, unique(article_variant_id, warehouse_id), tenant_id FK)
- stock_lot(id, stock_item_id FK, lot_no str, expiry_date dt, tenant_id FK)
- stock_movement(id, stock_item_id FK, qty dec, direction enum in/out, ref_type str, ref_id uuid, cost dec, occurred_at dt, tenant_id FK)
- reservation(id, stock_item_id FK, order_line_id FK unique, qty dec, expires_at dt, tenant_id FK)
- adjustment(id, stock_item_id FK, qty dec, reason str, occurred_at dt, tenant_id FK)

## Sales & Fulfillment
- sales_order(id, customer_id FK, status enum, order_date dt, currency str, totals json, tenant_id FK, validity_from/to)
- order_line(id, sales_order_id FK, article_variant_id FK, qty dec, price dec, tax_code str, cost_center_id FK, cost_object_id FK, result_object_id FK)
- delivery(id, sales_order_id FK, status enum, ship_date dt, tracking_no str, tenant_id FK)
- return(id, sales_order_id FK, status enum, reason str, qty json, tenant_id FK)
- number_range(id, doc_type enum, legal_entity_id FK, fiscal_year int, prefix str, suffix str, next_number int, min_length int, status enum, active_from dt, active_to dt, tenant_id FK, unique(doc_type, legal_entity_id, fiscal_year))
- invoice(id, invoice_no str, status enum, doc_date dt, due_date dt, currency str, totals json, number_range_id FK, legal_entity_id FK, pdf_uri str, tenant_id FK, unique(invoice_no, legal_entity_id, year(doc_date)))
- document_link(id, source_type enum order/delivery/invoice/credit_note/return/etc, source_id FK, target_type enum order/delivery/invoice/credit_note/return/etc, target_id FK, tenant_id FK, unique(source_type, source_id, target_type, target_id))
- invoice_line(id, invoice_id FK, order_line_id FK, qty dec, price dec, tax_code str)
- credit_note(id, invoice_id FK, status enum, totals json, tenant_id FK)
- payment(id, invoice_id FK, amount dec, method str, received_at dt, open_item_id FK, tenant_id FK)

## Procurement
- purchase_order(id, supplier_id FK, status enum, order_date dt, currency str, totals json, tenant_id FK)
- po_line(id, purchase_order_id FK, article_variant_id FK, qty dec, price dec, tax_code str)
- po_receipt(id, purchase_order_id FK, status enum, received_at dt, tenant_id FK)
- supplier_invoice(id, supplier_id FK, purchase_order_id FK, invoice_no str, status enum, totals json, open_item_id FK, tenant_id FK, unique(invoice_no, supplier_id))
- ap_payment(id, supplier_invoice_id FK, amount dec, paid_at dt, tenant_id FK)

## Finance / GL / AR / AP
- account(id, code str unique, name str, type enum asset/liability/equity/income/expense, tax_code str, status, tenant_id FK)
- fiscal_year(id, legal_entity_id FK, start_date dt, end_date dt, status enum, tenant_id FK, unique(legal_entity_id, start_date, end_date))
- period(id, fiscal_year_id FK, seq int, start_date dt, end_date dt, status enum, tenant_id FK, unique(fiscal_year_id, seq))
- journal_entry(id, doc_type str, doc_id uuid, date dt, status enum, legal_entity_id FK, tenant_id FK, unique(doc_type, doc_id))
- journal_line(id, journal_entry_id FK, account_id FK, debit dec, credit dec, cost_center_id FK, cost_object_id FK, result_object_id FK, tenant_id FK)
- open_item(id, party_type enum customer/supplier, party_id FK, doc_type str, doc_id uuid, amount dec, currency str, due_date dt, status enum, tenant_id FK)
- bank_statement(id, account_ref str, period_id FK, imported_at dt, source_type enum csv/mt940, tenant_id FK)
- bank_tx(id, bank_statement_id FK, amount dec, currency str, value_date dt, counterparty str, ref_text str, match_status enum, open_item_id FK, tenant_id FK)
- reconciliation_match(id, bank_tx_id FK unique, open_item_id FK, confidence dec, decided_by FK user, decided_at dt, tenant_id FK)

## Kost / Controlling
- cost_center(id, code str unique, name str, status enum, validity_from/to, tenant_id FK)
- cost_category(id, code str unique, name str, status enum, tenant_id FK)
-- cost_center_distribution(id, cost_center_id FK, cost_category_id FK, share dec, validity_from/to, tenant_id FK, unique(cost_center_id, cost_category_id, validity_from))
	- Rule: shares per (cost_center_id, validity window) must sum to 1.0
- cost_object(id, code str unique, name str, status enum, validity_from/to, tenant_id FK)
-- cost_category_distribution(id, cost_category_id FK, cost_object_id FK, share dec, validity_from/to, tenant_id FK, unique(cost_category_id, cost_object_id, validity_from))
	- Rule: shares per (cost_category_id, validity window) must sum to 1.0
- result_object(id, code str unique, name str, status enum, validity_from/to, tenant_id FK)
- allocation_rule(id, source_type enum account/cost_center, target_type enum cost_center/cost_object/result_object, driver_type enum qty/value, formula json, validity_from/to, tenant_id FK)
- distribution_run(id, rule_id FK, period_id FK, executed_at dt, status enum, result json, tenant_id FK)

## Communication / Docs
- message_thread(id, type enum order/invoice/ticket/customer, ref_id uuid, customer_id FK, status enum, tenant_id FK)
- message(id, thread_id FK, sender_type enum system/user/customer, body text, direction enum in/out, sent_at dt, tenant_id FK)
- template(id, type enum email/pdf, locale str, version int, body text, status enum, tenant_id FK, unique(type, locale, version))
- attachment(id, uri str, content_type str, checksum str, linked_type str, linked_id uuid, tenant_id FK)
- notification(id, user_id FK, channel enum email/sms/webhook, payload json, sent_at dt, status enum, tenant_id FK)

## Audit / Tamper Evidence
- audit_log(id, event_type str, entity_type str, entity_id uuid, before json, after json, actor_id FK user, actor_ip str, actor_ua str, trace_id str, occurred_at dt, signature str, hash_chain str, tenant_id FK)
- audit_anchor(id, tenant_id FK, anchor_date date, root_hash str, signature str)
