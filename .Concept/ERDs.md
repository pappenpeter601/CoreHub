# CoreHub ERDs (Text + Mermaid Drafts)

## Identity & Access
```mermaid
erDiagram
    USER ||--o{ USER_ROLE : assigns
    ROLE ||--o{ USER_ROLE : links
    ROLE ||--o{ ROLE_PERMISSION : grants
    PERMISSION ||--o{ ROLE_PERMISSION : defines
    USER ||--o{ SESSION : has
    USER ||--o{ MAGIC_LINK_TOKEN : issues
    FEATURE_FLAG {
        string key
        string scope
        string value
        datetime active_from
        datetime active_to
    }
```

## Master Data (Customer/Supplier/Articles)
```mermaid
erDiagram
    CUSTOMER ||--o{ SALES_ORDER : places
    CUSTOMER {
        uuid id
        enum type
        string vat_id
        json addresses
        json contacts
    }
    SUPPLIER ||--o{ PURCHASE_ORDER : receives
    ARTICLE ||--o{ ARTICLE_VARIANT : links
    VARIANT ||--o{ ARTICLE_VARIANT : defines
    ARTICLE_VARIANT ||--o{ ORDER_LINE : used_in
    ARTICLE_VARIANT ||--o{ PO_LINE : procured_in
    BUNDLE ||--o{ BUNDLE_ITEM : aggregates
    PRODUCT ||--o{ PRODUCT_BUNDLE : aggregates
    PRICE_RULE {
        uuid id
        json conditions
        json adjustments
        datetime validity_from
        datetime validity_to
    }
```

## Inventory
```mermaid
erDiagram
    WAREHOUSE ||--o{ STOCK_ITEM : hosts
    ARTICLE_VARIANT ||--o{ STOCK_ITEM : tracked_as
    STOCK_ITEM ||--o{ STOCK_LOT : batches
    STOCK_ITEM ||--o{ STOCK_MOVEMENT : moves
    STOCK_ITEM ||--o{ RESERVATION : reserves
    STOCK_ITEM ||--o{ ADJUSTMENT : adjusts
```

## Sales & Fulfillment
```mermaid
erDiagram
    CUSTOMER ||--o{ SALES_ORDER : owns
    SALES_ORDER ||--o{ ORDER_LINE : contains
    SALES_ORDER ||--o{ DELIVERY : results_in
    SALES_ORDER ||--o{ DOCUMENT_LINK : links
    DELIVERY ||--o{ DOCUMENT_LINK : links
    INVOICE ||--o{ DOCUMENT_LINK : links
    ORDER_LINE ||--o{ INVOICE_LINE : billed_as
    DELIVERY ||--o{ RETURN : may_create
    INVOICE ||--o{ PAYMENT : settles
    NUMBER_RANGE ||--|{ INVOICE : assigns
```

## Procurement
```mermaid
erDiagram
    SUPPLIER ||--o{ PURCHASE_ORDER : receives
    PURCHASE_ORDER ||--o{ PO_LINE : contains
    PURCHASE_ORDER ||--o{ PO_RECEIPT : leads_to
    PURCHASE_ORDER ||--o{ SUPPLIER_INVOICE : billed_by
    SUPPLIER ||--o{ SUPPLIER_INVOICE : bills
    SUPPLIER_INVOICE ||--o{ AP_PAYMENT : settled_by
```

## Finance (GL/AR/AP)
```mermaid
erDiagram
    FISCAL_YEAR ||--o{ PERIOD : spans
    JOURNAL_ENTRY ||--o{ JOURNAL_LINE : composed_of
    ACCOUNT ||--o{ JOURNAL_LINE : posted_to
    OPEN_ITEM ||--o{ RECONCILIATION_MATCH : matched_by
    BANK_STATEMENT ||--o{ BANK_TX : has
    BANK_TX ||--o{ RECONCILIATION_MATCH : linked
```

## Kost/Controlling
```mermaid
erDiagram
    COST_CENTER ||--o{ JOURNAL_LINE : allocates_from
    COST_OBJECT ||--o{ JOURNAL_LINE : allocates_from
    RESULT_OBJECT ||--o{ JOURNAL_LINE : allocates_from
    ALLOCATION_RULE ||--o{ DISTRIBUTION_RUN : executed_by
    JOURNAL_LINE ||--o{ DISTRIBUTION_RUN : produced_from
```

## Communication & Docs
```mermaid
erDiagram
    MESSAGE_THREAD ||--o{ MESSAGE : contains
    MESSAGE_THREAD ||--o{ ATTACHMENT : links
    TEMPLATE ||--o{ MESSAGE : renders
    NOTIFICATION ||--o{ ATTACHMENT : may_include
```

> Note: All core tables carry tenant_id, created_at/by, updated_at/by; validity_from/to on mutable master data and rules.
