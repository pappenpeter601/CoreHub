-- CoreHub MariaDB DDL (initial cut)
-- Conventions: utf8mb4, strict SQL modes, InnoDB, FK constraints; timestamps in UTC.

CREATE TABLE user (
  id CHAR(36) PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  locale VARCHAR(16),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE role (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_role_name_tenant (name, tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permission (
  id CHAR(36) PRIMARY KEY,
  resource VARCHAR(128) NOT NULL,
  action VARCHAR(32) NOT NULL,
  UNIQUE KEY uq_perm (resource, action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_role (
  user_id CHAR(36) NOT NULL,
  role_id CHAR(36) NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES user(id),
  CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES role(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE role_permission (
  role_id CHAR(36) NOT NULL,
  permission_id CHAR(36) NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_role_perm_role FOREIGN KEY (role_id) REFERENCES role(id),
  CONSTRAINT fk_role_perm_perm FOREIGN KEY (permission_id) REFERENCES permission(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE feature_flag (
  id CHAR(36) PRIMARY KEY,
  key_name VARCHAR(128) NOT NULL,
  scope VARCHAR(64) NOT NULL,
  value JSON,
  active_from DATETIME(3),
  active_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_flag (key_name, tenant_id, scope)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE magic_link_token (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  fallback_code_hash VARCHAR(255),
  fallback_code_expires_at DATETIME(3),
  fallback_code_used_at DATETIME(3),
  expires_at DATETIME(3) NOT NULL,
  used_at DATETIME(3),
  ip_hint VARCHAR(64),
  device_hint VARCHAR(128),
  CONSTRAINT fk_magic_user FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE customer (
  id CHAR(36) PRIMARY KEY,
  type VARCHAR(8) NOT NULL,
  legal_entity VARCHAR(255),
  vat_id VARCHAR(64),
  addresses JSON,
  contacts JSON,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_customer_vat (vat_id),
  KEY idx_customer_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE supplier (
  id CHAR(36) PRIMARY KEY,
  legal_entity VARCHAR(255),
  vat_id VARCHAR(64),
  addresses JSON,
  contacts JSON,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_supplier_vat (vat_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE article (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE variant (
  id CHAR(36) PRIMARY KEY,
  sku VARCHAR(128) NOT NULL,
  name VARCHAR(255) NOT NULL,
  attrs JSON,
  uom VARCHAR(32) NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_variant_sku (sku)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bundle (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bundle_item (
  bundle_id CHAR(36) NOT NULL,
  article_id CHAR(36) NOT NULL,
  qty DECIMAL(18,4) NOT NULL,
  PRIMARY KEY (bundle_id, article_id),
  CONSTRAINT fk_bi_bundle FOREIGN KEY (bundle_id) REFERENCES bundle(id),
  CONSTRAINT fk_bi_article FOREIGN KEY (article_id) REFERENCES article(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_bundle (
  product_id CHAR(36) NOT NULL,
  bundle_id CHAR(36) NOT NULL,
  qty DECIMAL(18,4) NOT NULL,
  PRIMARY KEY (product_id, bundle_id),
  CONSTRAINT fk_pb_product FOREIGN KEY (product_id) REFERENCES product(id),
  CONSTRAINT fk_pb_bundle FOREIGN KEY (bundle_id) REFERENCES bundle(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE price_rule (
  id CHAR(36) PRIMARY KEY,
  scope JSON,
  currency VARCHAR(8),
  conditions JSON,
  adjustments JSON,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tax_rule (
  id CHAR(36) PRIMARY KEY,
  country VARCHAR(8) NOT NULL,
  region VARCHAR(16),
  rate DECIMAL(9,4) NOT NULL,
  type VARCHAR(32),
  reverse_charge TINYINT(1) DEFAULT 0,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_tax_country_region (country, region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE warehouse (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  location JSON,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE article_variant (
  id CHAR(36) PRIMARY KEY,
  article_id CHAR(36) NOT NULL,
  variant_id CHAR(36) NOT NULL,
  base_price DECIMAL(18,4),
  status VARCHAR(32) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_article_variant (article_id, variant_id),
  KEY idx_variant_article (article_id),
  KEY idx_variant_variant (variant_id),
  CONSTRAINT fk_variant_article FOREIGN KEY (article_id) REFERENCES article(id),
  CONSTRAINT fk_variant_variant FOREIGN KEY (variant_id) REFERENCES variant(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sales_order (
  id CHAR(36) PRIMARY KEY,
  customer_id CHAR(36) NOT NULL,
  status VARCHAR(32) NOT NULL,
  order_date DATETIME(3) NOT NULL,
  currency VARCHAR(8) NOT NULL,
  totals JSON,
  tenant_id CHAR(36) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_order_customer (customer_id),
  KEY idx_order_status (status),
  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customer(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_line (
  id CHAR(36) PRIMARY KEY,
  sales_order_id CHAR(36) NOT NULL,
  article_variant_id CHAR(36) NOT NULL,
  qty DECIMAL(18,4) NOT NULL,
  price DECIMAL(18,4) NOT NULL,
  tax_code VARCHAR(32),
  cost_center_id CHAR(36),
  cost_object_id CHAR(36),
  result_object_id CHAR(36),
  KEY idx_ol_order (sales_order_id),
  KEY idx_ol_variant (article_variant_id),
  CONSTRAINT fk_ol_order FOREIGN KEY (sales_order_id) REFERENCES sales_order(id),
  CONSTRAINT fk_ol_variant FOREIGN KEY (article_variant_id) REFERENCES article_variant(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE number_range (
  id CHAR(36) PRIMARY KEY,
  doc_type VARCHAR(32) NOT NULL,
  legal_entity_id CHAR(36) NOT NULL,
  fiscal_year INT NOT NULL,
  prefix VARCHAR(32),
  suffix VARCHAR(32),
  next_number INT NOT NULL,
  min_length INT NOT NULL DEFAULT 4,
  status VARCHAR(32) NOT NULL,
  active_from DATE,
  active_to DATE,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_number_range (doc_type, legal_entity_id, fiscal_year),
  KEY idx_nr_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE invoice (
  id CHAR(36) PRIMARY KEY,
  invoice_no VARCHAR(64) NOT NULL,
  status VARCHAR(32) NOT NULL,
  doc_date DATE NOT NULL,
  due_date DATE NOT NULL,
  currency VARCHAR(8) NOT NULL,
  totals JSON,
  number_range_id CHAR(36),
  legal_entity_id CHAR(36),
  pdf_uri VARCHAR(512),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_invoice_no (invoice_no, legal_entity_id, doc_date),
  KEY idx_invoice_due (due_date),
  CONSTRAINT fk_invoice_number_range FOREIGN KEY (number_range_id) REFERENCES number_range(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE document_link (
  id CHAR(36) PRIMARY KEY,
  source_type VARCHAR(32) NOT NULL,
  source_id CHAR(36) NOT NULL,
  target_type VARCHAR(32) NOT NULL,
  target_id CHAR(36) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  UNIQUE KEY uq_document_link (source_type, source_id, target_type, target_id),
  KEY idx_document_link_source (source_type, source_id),
  KEY idx_document_link_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE invoice_line (
  id CHAR(36) PRIMARY KEY,
  invoice_id CHAR(36) NOT NULL,
  order_line_id CHAR(36),
  qty DECIMAL(18,4) NOT NULL,
  price DECIMAL(18,4) NOT NULL,
  tax_code VARCHAR(32),
  KEY idx_il_invoice (invoice_id),
  CONSTRAINT fk_il_invoice FOREIGN KEY (invoice_id) REFERENCES invoice(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE credit_note (
  id CHAR(36) PRIMARY KEY,
  invoice_id CHAR(36) NOT NULL,
  status VARCHAR(32) NOT NULL,
  totals JSON,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_cn_invoice FOREIGN KEY (invoice_id) REFERENCES invoice(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE open_item (
  id CHAR(36) PRIMARY KEY,
  party_type VARCHAR(16) NOT NULL,
  party_id CHAR(36) NOT NULL,
  doc_type VARCHAR(32) NOT NULL,
  doc_id CHAR(36) NOT NULL,
  amount DECIMAL(18,4) NOT NULL,
  currency VARCHAR(8) NOT NULL,
  due_date DATE NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_oi_party (party_type, party_id),
  KEY idx_oi_due (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment (
  id CHAR(36) PRIMARY KEY,
  invoice_id CHAR(36) NOT NULL,
  amount DECIMAL(18,4) NOT NULL,
  method VARCHAR(32),
  received_at DATETIME(3) NOT NULL,
  open_item_id CHAR(36),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoice(id),
  CONSTRAINT fk_payment_oi FOREIGN KEY (open_item_id) REFERENCES open_item(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bank_statement (
  id CHAR(36) PRIMARY KEY,
  account_ref VARCHAR(128) NOT NULL,
  period_id CHAR(36),
  imported_at DATETIME(3) NOT NULL,
  source_type VARCHAR(16) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bank_tx (
  id CHAR(36) PRIMARY KEY,
  bank_statement_id CHAR(36) NOT NULL,
  amount DECIMAL(18,4) NOT NULL,
  currency VARCHAR(8) NOT NULL,
  value_date DATE NOT NULL,
  counterparty VARCHAR(255),
  ref_text VARCHAR(512),
  match_status VARCHAR(16) NOT NULL,
  open_item_id CHAR(36),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_btx_stmt (bank_statement_id),
  KEY idx_btx_value_date (value_date),
  KEY idx_btx_match (match_status),
  CONSTRAINT fk_btx_stmt FOREIGN KEY (bank_statement_id) REFERENCES bank_statement(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reconciliation_match (
  id CHAR(36) PRIMARY KEY,
  bank_tx_id CHAR(36) NOT NULL,
  open_item_id CHAR(36) NOT NULL,
  confidence DECIMAL(5,2),
  decided_by CHAR(36),
  decided_at DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_rm_btxt (bank_tx_id),
  CONSTRAINT fk_rm_btxt FOREIGN KEY (bank_tx_id) REFERENCES bank_tx(id),
  CONSTRAINT fk_rm_oi FOREIGN KEY (open_item_id) REFERENCES open_item(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_order (
  id CHAR(36) PRIMARY KEY,
  supplier_id CHAR(36) NOT NULL,
  status VARCHAR(32) NOT NULL,
  order_date DATETIME(3) NOT NULL,
  currency VARCHAR(8) NOT NULL,
  totals JSON,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  KEY idx_po_supplier (supplier_id),
  KEY idx_po_status (status),
  CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE po_line (
  id CHAR(36) PRIMARY KEY,
  purchase_order_id CHAR(36) NOT NULL,
  article_variant_id CHAR(36) NOT NULL,
  qty DECIMAL(18,4) NOT NULL,
  price DECIMAL(18,4) NOT NULL,
  tax_code VARCHAR(32),
  KEY idx_pol_po (purchase_order_id),
  KEY idx_pol_variant (article_variant_id),
  CONSTRAINT fk_pol_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(id),
  CONSTRAINT fk_pol_variant FOREIGN KEY (article_variant_id) REFERENCES article_variant(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE po_receipt (
  id CHAR(36) PRIMARY KEY,
  purchase_order_id CHAR(36) NOT NULL,
  status VARCHAR(32) NOT NULL,
  received_at DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_por_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE supplier_invoice (
  id CHAR(36) PRIMARY KEY,
  supplier_id CHAR(36) NOT NULL,
  purchase_order_id CHAR(36),
  invoice_no VARCHAR(64) NOT NULL,
  status VARCHAR(32) NOT NULL,
  totals JSON,
  open_item_id CHAR(36),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_sinv_no_supplier (invoice_no, supplier_id),
  KEY idx_sinv_supplier (supplier_id),
  CONSTRAINT fk_sinv_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(id),
  CONSTRAINT fk_sinv_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(id),
  CONSTRAINT fk_sinv_oi FOREIGN KEY (open_item_id) REFERENCES open_item(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ap_payment (
  id CHAR(36) PRIMARY KEY,
  supplier_invoice_id CHAR(36) NOT NULL,
  amount DECIMAL(18,4) NOT NULL,
  paid_at DATETIME(3) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_appay_sinv FOREIGN KEY (supplier_invoice_id) REFERENCES supplier_invoice(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE account (
  id CHAR(36) PRIMARY KEY,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(16) NOT NULL,
  tax_code VARCHAR(32),
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_account_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fiscal_year (
  id CHAR(36) PRIMARY KEY,
  legal_entity_id CHAR(36) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_fy_entity (legal_entity_id, start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE period (
  id CHAR(36) PRIMARY KEY,
  fiscal_year_id CHAR(36) NOT NULL,
  seq INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_period_seq (fiscal_year_id, seq),
  CONSTRAINT fk_period_fy FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE journal_entry (
  id CHAR(36) PRIMARY KEY,
  doc_type VARCHAR(32) NOT NULL,
  doc_id CHAR(36) NOT NULL,
  date DATE NOT NULL,
  status VARCHAR(32) NOT NULL,
  legal_entity_id CHAR(36) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_je_doc (doc_type, doc_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE journal_line (
  id CHAR(36) PRIMARY KEY,
  journal_entry_id CHAR(36) NOT NULL,
  account_id CHAR(36) NOT NULL,
  debit DECIMAL(18,4) DEFAULT 0,
  credit DECIMAL(18,4) DEFAULT 0,
  cost_center_id CHAR(36),
  cost_object_id CHAR(36),
  result_object_id CHAR(36),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_jl_je FOREIGN KEY (journal_entry_id) REFERENCES journal_entry(id),
  CONSTRAINT fk_jl_account FOREIGN KEY (account_id) REFERENCES account(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cost_center (
  id CHAR(36) PRIMARY KEY,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_cc_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cost_category (
  id CHAR(36) PRIMARY KEY,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_cost_category_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cost_center_distribution (
  id CHAR(36) PRIMARY KEY,
  cost_center_id CHAR(36) NOT NULL,
  cost_category_id CHAR(36) NOT NULL,
  share DECIMAL(9,6) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_cc_dist (cost_center_id, cost_category_id, validity_from),
  KEY idx_ccd_center (cost_center_id),
  KEY idx_ccd_category (cost_category_id),
  CONSTRAINT fk_ccd_center FOREIGN KEY (cost_center_id) REFERENCES cost_center(id),
  CONSTRAINT fk_ccd_category FOREIGN KEY (cost_category_id) REFERENCES cost_category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cost_object (
  id CHAR(36) PRIMARY KEY,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_co_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cost_category_distribution (
  id CHAR(36) PRIMARY KEY,
  cost_category_id CHAR(36) NOT NULL,
  cost_object_id CHAR(36) NOT NULL,
  share DECIMAL(9,6) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_ccat_dist (cost_category_id, cost_object_id, validity_from),
  KEY idx_ccatd_category (cost_category_id),
  KEY idx_ccatd_object (cost_object_id),
  CONSTRAINT fk_ccatd_category FOREIGN KEY (cost_category_id) REFERENCES cost_category(id),
  CONSTRAINT fk_ccatd_object FOREIGN KEY (cost_object_id) REFERENCES cost_object(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE result_object (
  id CHAR(36) PRIMARY KEY,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_ro_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE allocation_rule (
  id CHAR(36) PRIMARY KEY,
  source_type VARCHAR(32) NOT NULL,
  target_type VARCHAR(32) NOT NULL,
  driver_type VARCHAR(32) NOT NULL,
  formula JSON,
  validity_from DATETIME(3),
  validity_to DATETIME(3),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE distribution_run (
  id CHAR(36) PRIMARY KEY,
  rule_id CHAR(36) NOT NULL,
  period_id CHAR(36) NOT NULL,
  executed_at DATETIME(3) NOT NULL,
  status VARCHAR(32) NOT NULL,
  result JSON,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_dr_rule FOREIGN KEY (rule_id) REFERENCES allocation_rule(id),
  CONSTRAINT fk_dr_period FOREIGN KEY (period_id) REFERENCES period(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE message_thread (
  id CHAR(36) PRIMARY KEY,
  type VARCHAR(32) NOT NULL,
  ref_id CHAR(36),
  customer_id CHAR(36),
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE message (
  id CHAR(36) PRIMARY KEY,
  thread_id CHAR(36) NOT NULL,
  sender_type VARCHAR(16) NOT NULL,
  body TEXT,
  direction VARCHAR(8) NOT NULL,
  sent_at DATETIME(3) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_msg_thread FOREIGN KEY (thread_id) REFERENCES message_thread(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE template (
  id CHAR(36) PRIMARY KEY,
  type VARCHAR(16) NOT NULL,
  locale VARCHAR(8) NOT NULL,
  version INT NOT NULL,
  body TEXT,
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  UNIQUE KEY uq_template (type, locale, version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attachment (
  id CHAR(36) PRIMARY KEY,
  uri VARCHAR(512) NOT NULL,
  content_type VARCHAR(128),
  checksum VARCHAR(128),
  linked_type VARCHAR(64),
  linked_id CHAR(36),
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notification (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  channel VARCHAR(16) NOT NULL,
  payload JSON,
  sent_at DATETIME(3),
  status VARCHAR(32) NOT NULL,
  tenant_id CHAR(36) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36),
  updated_at DATETIME(3),
  updated_by CHAR(36),
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE audit_log (
  id CHAR(36) PRIMARY KEY,
  event_type VARCHAR(64) NOT NULL,
  entity_type VARCHAR(64) NOT NULL,
  entity_id CHAR(36) NOT NULL,
  before JSON,
  after JSON,
  actor_id CHAR(36),
  actor_ip VARCHAR(64),
  actor_ua VARCHAR(256),
  trace_id CHAR(36),
  occurred_at DATETIME(3) NOT NULL,
  signature VARCHAR(512),
  hash_chain VARCHAR(512),
  tenant_id CHAR(36) NOT NULL,
  KEY idx_audit_entity (entity_type, entity_id),
  KEY idx_audit_time (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
