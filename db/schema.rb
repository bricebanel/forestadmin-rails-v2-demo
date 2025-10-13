# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_10_13_081725) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_graphql"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "supabase_vault"
  enable_extension "uuid-ossp"

  create_table "account_transactions", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.string "transaction_type", limit: 50, null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "direction", limit: 10, null: false
    t.decimal "balance_after", precision: 12, scale: 2, null: false
    t.string "description", limit: 500
    t.string "reference_type", limit: 50
    t.integer "reference_id"
    t.datetime "transaction_date", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["company_id"], name: "idx_transactions_company_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.text "summary"
    t.date "published_at"
    t.bigint "author_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["category_id"], name: "index_books_on_category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "company_name", limit: 255, null: false
    t.string "siret", limit: 14, null: false
    t.string "legal_form", limit: 50
    t.string "contact_name", limit: 255, null: false
    t.string "contact_email", limit: 255, null: false
    t.string "contact_phone", limit: 20
    t.text "address"
    t.string "city", limit: 100
    t.string "postal_code", limit: 10
    t.string "specialization", limit: 100
    t.string "company_size", limit: 20
    t.string "status", limit: 50, default: "active"
    t.datetime "onboarded_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.string "kyc_status", limit: 50, default: "pending"
    t.decimal "credit_limit_eur", precision: 12, scale: 2
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["kyc_status"], name: "idx_companies_kyc_status"
    t.index ["status"], name: "idx_companies_status"
    t.unique_constraint ["siret"], name: "companies_siret_key"
  end

  create_table "factoring_operations", id: :serial, force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "company_id"
    t.datetime "request_date", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.decimal "invoice_amount", precision: 12, scale: 2, null: false
    t.decimal "advance_rate", precision: 5, scale: 2, default: "85.0"
    t.decimal "advance_amount", precision: 12, scale: 2, null: false
    t.decimal "fee_rate", precision: 5, scale: 2, default: "2.5"
    t.decimal "fee_amount", precision: 12, scale: 2, null: false
    t.decimal "net_amount", precision: 12, scale: 2, null: false
    t.string "status", limit: 50, default: "pending"
    t.datetime "approved_at", precision: nil
    t.datetime "funded_at", precision: nil
    t.datetime "final_payment_at", precision: nil
    t.string "approved_by", limit: 255
    t.text "rejection_reason"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["company_id"], name: "idx_factoring_company_id"
    t.index ["status"], name: "idx_factoring_status"
  end

  create_table "invoices", id: :serial, force: :cascade do |t|
    t.string "invoice_number", limit: 100, null: false
    t.integer "company_id"
    t.integer "project_id"
    t.string "invoice_type", limit: 50, null: false
    t.date "invoice_date", null: false
    t.date "due_date", null: false
    t.decimal "amount_ht", precision: 12, scale: 2, null: false
    t.decimal "amount_ttc", precision: 12, scale: 2, null: false
    t.decimal "vat_amount", precision: 12, scale: 2, null: false
    t.text "description"
    t.string "payment_status", limit: 50, default: "pending"
    t.datetime "paid_at", precision: nil
    t.integer "payment_delay_days", default: 0
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["company_id"], name: "idx_invoices_company_id"
    t.index ["payment_status"], name: "idx_invoices_payment_status"
    t.unique_constraint ["invoice_number"], name: "invoices_invoice_number_key"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.datetime "borrowed_at"
    t.datetime "returned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_loans_on_book_id"
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "project_participants", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "company_id"
    t.string "role", limit: 50, null: false
    t.decimal "contract_amount_eur", precision: 12, scale: 2, null: false
    t.decimal "retention_guarantee_amount_eur", precision: 12, scale: 2
    t.decimal "retention_guarantee_rate", precision: 5, scale: 2, default: "5.0"
    t.date "contract_signed_at"
    t.text "work_scope"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "project_name", limit: 500, null: false
    t.string "contracting_authority", limit: 255, null: false
    t.string "project_type", limit: 100
    t.string "location", limit: 255
    t.decimal "total_budget_eur", precision: 15, scale: 2
    t.date "start_date"
    t.date "expected_end_date"
    t.date "actual_end_date"
    t.string "status", limit: 50, default: "planned"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["status"], name: "idx_projects_status"
  end

  create_table "retention_guarantees", id: :serial, force: :cascade do |t|
    t.integer "project_participant_id"
    t.integer "company_id"
    t.decimal "guarantee_amount", precision: 12, scale: 2, null: false
    t.string "guarantee_type", limit: 50, default: "retention"
    t.date "issue_date", null: false
    t.date "release_date"
    t.string "status", limit: 50, default: "active"
    t.decimal "annual_fee_rate", precision: 5, scale: 2, default: "1.5"
    t.decimal "fee_amount", precision: 10, scale: 2
    t.string "beneficiary", limit: 255, null: false
    t.string "contract_reference", limit: 255
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index ["status"], name: "idx_guarantees_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "account_transactions", "companies", name: "account_transactions_company_id_fkey", on_delete: :cascade
  add_foreign_key "books", "authors"
  add_foreign_key "books", "categories"
  add_foreign_key "factoring_operations", "companies", name: "factoring_operations_company_id_fkey", on_delete: :cascade
  add_foreign_key "factoring_operations", "invoices", name: "factoring_operations_invoice_id_fkey", on_delete: :cascade
  add_foreign_key "invoices", "companies", name: "invoices_company_id_fkey", on_delete: :cascade
  add_foreign_key "invoices", "projects", name: "invoices_project_id_fkey", on_delete: :cascade
  add_foreign_key "loans", "books"
  add_foreign_key "loans", "users"
  add_foreign_key "project_participants", "companies", name: "project_participants_company_id_fkey", on_delete: :cascade
  add_foreign_key "project_participants", "projects", name: "project_participants_project_id_fkey", on_delete: :cascade
  add_foreign_key "retention_guarantees", "companies", name: "retention_guarantees_company_id_fkey", on_delete: :cascade
  add_foreign_key "retention_guarantees", "project_participants", name: "retention_guarantees_project_participant_id_fkey", on_delete: :cascade
end
