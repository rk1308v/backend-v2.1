# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190607154024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.string   "profile_type"
    t.integer  "profile_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["profile_type", "profile_id"], name: "index_accounts_on_profile_type_and_profile_id", using: :btree
    t.index ["user_id"], name: "index_accounts_on_user_id", using: :btree
  end

  create_table "activities", force: :cascade do |t|
    t.string   "activity"
    t.decimal  "amount"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "status"
    t.integer  "smx_transaction_id"
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "addresses", force: :cascade do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "line3"
    t.string   "city"
    t.string   "postcode_prefix"
    t.string   "zip_postcode"
    t.string   "state_province_county"
    t.text     "description"
    t.integer  "address_type"
    t.integer  "user_id",               null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "country_id"
    t.index ["country_id"], name: "index_addresses_on_country_id", using: :btree
    t.index ["user_id"], name: "index_addresses_on_user_id", using: :btree
  end

  create_table "admin_transactions", force: :cascade do |t|
    t.decimal  "amount",       null: false
    t.integer  "trans_type",   null: false
    t.integer  "status",       null: false
    t.text     "description"
    t.integer  "admin_id"
    t.integer  "recipient_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["admin_id"], name: "index_admin_transactions_on_admin_id", using: :btree
    t.index ["recipient_id"], name: "index_admin_transactions_on_recipient_id", using: :btree
  end

  create_table "agent_accounts", force: :cascade do |t|
    t.string   "company_name"
    t.decimal  "money_in",          default: "0.0"
    t.decimal  "money_out",         default: "0.0"
    t.decimal  "commission_earned", default: "0.0"
    t.decimal  "payin_amount_due",  default: "0.0"
    t.text     "description"
    t.integer  "user_id",                           null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["user_id"], name: "index_agent_accounts_on_user_id", using: :btree
  end

  create_table "agent_transactions", force: :cascade do |t|
    t.decimal  "net_amount",   null: false
    t.decimal  "fees",         null: false
    t.decimal  "commission",   null: false
    t.integer  "trans_type",   null: false
    t.integer  "payment_type", null: false
    t.integer  "status",       null: false
    t.text     "description"
    t.integer  "user_id"
    t.integer  "agent_id",     null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["agent_id"], name: "index_agent_transactions_on_agent_id", using: :btree
    t.index ["user_id"], name: "index_agent_transactions_on_user_id", using: :btree
  end

  create_table "authtokens", force: :cascade do |t|
    t.string   "token"
    t.datetime "last_used_at"
    t.string   "sign_in_ip"
    t.string   "user_agent"
    t.string   "device_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_authtokens_on_user_id", using: :btree
  end

  create_table "contact_books", force: :cascade do |t|
    t.boolean  "smx_user",   default: false
    t.string   "name"
    t.string   "telephone"
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["user_id"], name: "index_contact_books_on_user_id", using: :btree
  end

  create_table "countries", force: :cascade do |t|
    t.string   "iso_alpha_3",       null: false
    t.string   "name",              null: false
    t.boolean  "transfer"
    t.boolean  "susu"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "flag_file_name"
    t.string   "flag_content_type"
    t.integer  "flag_file_size"
    t.datetime "flag_updated_at"
  end

  create_table "currency_exchanges", force: :cascade do |t|
    t.decimal  "value"
    t.datetime "effective_date"
    t.boolean  "active"
    t.string   "currency_from",                           null: false
    t.string   "currency_to",                             null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.decimal  "effective_exchange_rate", default: "0.0"
    t.float    "money_gram_rate",         default: 0.0
    t.float    "western_union_rate",      default: 0.0
    t.index ["currency_from"], name: "index_currency_exchanges_on_currency_from", using: :btree
    t.index ["currency_to"], name: "index_currency_exchanges_on_currency_to", using: :btree
  end

  create_table "fees_and_commissions", force: :cascade do |t|
    t.decimal  "amount_from"
    t.decimal  "amount_to"
    t.decimal  "amount"
    t.decimal  "percentage"
    t.boolean  "percent_based",        null: false
    t.boolean  "active"
    t.integer  "fc_type"
    t.integer  "rank"
    t.integer  "money_type"
    t.integer  "tansaction_type"
    t.integer  "sending_country_id",   null: false
    t.integer  "receiving_country_id", null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["receiving_country_id"], name: "index_fees_and_commissions_on_receiving_country_id", using: :btree
    t.index ["sending_country_id"], name: "index_fees_and_commissions_on_sending_country_id", using: :btree
  end

  create_table "invite_notifications", force: :cascade do |t|
    t.integer  "notified_by_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["notified_by_id"], name: "index_invite_notifications_on_notified_by_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean  "read"
    t.string   "notice"
    t.integer  "user_id"
    t.string   "noticeable_type"
    t.integer  "noticeable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["noticeable_type", "noticeable_id"], name: "index_notifications_on_noticeable_type_and_noticeable_id", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string   "issuer_name"
    t.boolean  "valid"
    t.string   "token"
    t.datetime "token_valid_until"
    t.integer  "payment_type"
    t.integer  "card_type"
    t.text     "description"
    t.integer  "country_id",        null: false
    t.integer  "user_id",           null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["country_id"], name: "index_payment_methods_on_country_id", using: :btree
    t.index ["user_id"], name: "index_payment_methods_on_user_id", using: :btree
  end

  create_table "payment_organisations", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "service_name"
    t.string   "name"
    t.integer  "termination_type"
    t.string   "service_coverage"
    t.string   "availability"
    t.string   "business_model"
    t.string   "payment_speed"
    t.float    "max_transaction_amount"
    t.string   "benificiary_lookup"
    t.decimal  "commission_less_hundred"
    t.decimal  "commission_greater_hundred"
    t.decimal  "min_commission"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["country_id"], name: "index_payment_organisations_on_country_id", using: :btree
  end

  create_table "payment_processors", force: :cascade do |t|
    t.string   "name"
    t.integer  "country_id",                null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "api_key",    default: ""
    t.string   "api_secret", default: ""
    t.boolean  "is_live",    default: true
    t.index ["country_id"], name: "index_payment_processors_on_country_id", using: :btree
  end

  create_table "payment_services", force: :cascade do |t|
    t.string   "service_name"
    t.string   "api_key"
    t.boolean  "isactive"
    t.text     "service_description"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["user_id"], name: "index_pictures_on_user_id", using: :btree
  end

  create_table "referral_contacts", force: :cascade do |t|
    t.string   "phone_number"
    t.boolean  "open_lead",      default: true
    t.integer  "reminder_count", default: 0
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["user_id"], name: "index_referral_contacts_on_user_id", using: :btree
  end

  create_table "smx_transactions", force: :cascade do |t|
    t.decimal  "amount",               null: false
    t.string   "transactionable_type"
    t.integer  "transactionable_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["transactionable_type", "transactionable_id"], name: "index_smx_transactions_on_transactionable", using: :btree
  end

  create_table "susu_invites", force: :cascade do |t|
    t.boolean  "accepted",     default: false
    t.integer  "susu_id",                      null: false
    t.integer  "sender_id",                    null: false
    t.integer  "recipient_id",                 null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["recipient_id"], name: "index_susu_invites_on_recipient_id", using: :btree
    t.index ["sender_id"], name: "index_susu_invites_on_sender_id", using: :btree
    t.index ["susu_id"], name: "index_susu_invites_on_susu_id", using: :btree
  end

  create_table "susu_memberships", force: :cascade do |t|
    t.boolean  "admin"
    t.boolean  "collected"
    t.integer  "last_payin_round", default: 0
    t.integer  "payout_round",     default: 0
    t.text     "description"
    t.integer  "user_id",                      null: false
    t.integer  "susu_id",                      null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["susu_id"], name: "index_susu_memberships_on_susu_id", using: :btree
    t.index ["user_id"], name: "index_susu_memberships_on_user_id", using: :btree
  end

  create_table "susu_notifications", force: :cascade do |t|
    t.integer  "notice_type"
    t.integer  "smx_transaction_id"
    t.integer  "susu_id"
    t.integer  "notified_by_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["notified_by_id"], name: "index_susu_notifications_on_notified_by_id", using: :btree
    t.index ["smx_transaction_id"], name: "index_susu_notifications_on_smx_transaction_id", using: :btree
    t.index ["susu_id"], name: "index_susu_notifications_on_susu_id", using: :btree
  end

  create_table "susu_transactions", force: :cascade do |t|
    t.decimal  "net_amount",   null: false
    t.decimal  "fees",         null: false
    t.integer  "round",        null: false
    t.integer  "trans_type",   null: false
    t.integer  "payment_type", null: false
    t.integer  "status",       null: false
    t.text     "description"
    t.integer  "susu_id",      null: false
    t.integer  "user_id",      null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["susu_id"], name: "index_susu_transactions_on_susu_id", using: :btree
    t.index ["user_id"], name: "index_susu_transactions_on_user_id", using: :btree
  end

  create_table "susus", force: :cascade do |t|
    t.string   "name"
    t.integer  "members_count",              null: false
    t.integer  "rounds_count"
    t.integer  "current_round",  default: 0
    t.integer  "days_per_round",             null: false
    t.decimal  "payin_amount",               null: false
    t.decimal  "payout_amount",              null: false
    t.decimal  "fees",                       null: false
    t.datetime "started_at",                 null: false
    t.datetime "ended_at"
    t.integer  "status",                     null: false
    t.text     "description"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "transfer_notifications", force: :cascade do |t|
    t.integer  "notice_type"
    t.decimal  "amount"
    t.integer  "smx_transaction_id"
    t.integer  "notified_by_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["notified_by_id"], name: "index_transfer_notifications_on_notified_by_id", using: :btree
    t.index ["smx_transaction_id"], name: "index_transfer_notifications_on_smx_transaction_id", using: :btree
  end

  create_table "user_accounts", force: :cascade do |t|
    t.decimal  "balance",             default: "0.0"
    t.decimal  "single_send_limit"
    t.decimal  "monthtly_send_limit"
    t.text     "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "user_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "card_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_cards_on_user_id", using: :btree
  end

  create_table "user_charges", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "charge_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_user_charges_on_user_id", using: :btree
  end

  create_table "user_transactions", force: :cascade do |t|
    t.decimal  "net_amount",                                        null: false
    t.decimal  "fees",                                              null: false
    t.decimal  "exchange_rate",                                     null: false
    t.string   "country_from",                                      null: false
    t.string   "country_to",                                        null: false
    t.integer  "trans_type",                                        null: false
    t.integer  "payment_type",                                      null: false
    t.integer  "status",                                            null: false
    t.text     "description"
    t.integer  "sender_id",                                         null: false
    t.integer  "recipient_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "recipient_telephone",               default: ""
    t.integer  "recipient_type",                    default: 1
    t.string   "transaction_id",                    default: ""
    t.string   "transaction_service",               default: ""
    t.string   "job_id",                            default: ""
    t.integer  "payment_service_id"
    t.text     "response_hash"
    t.string   "stripe_charge",                     default: ""
    t.decimal  "payment_processor_fees",            default: "0.0", null: false
    t.float    "payment_processor_fees_percentage"
    t.string   "payout_service",                    default: ""
    t.string   "payment_method",                    default: ""
    t.string   "status_worker_job_id",              default: ""
    t.integer  "payment_organisation_id"
    t.index ["payment_service_id"], name: "index_user_transactions_on_payment_service_id", using: :btree
    t.index ["recipient_id"], name: "index_user_transactions_on_recipient_id", using: :btree
    t.index ["sender_id"], name: "index_user_transactions_on_sender_id", using: :btree
    t.index ["transaction_id"], name: "index_user_transactions_on_transaction_id", using: :btree
    t.index ["transaction_service"], name: "index_user_transactions_on_transaction_service", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.string   "telephone"
    t.boolean  "active"
    t.string   "country",                                null: false
    t.integer  "rank"
    t.text     "description"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "username"
    t.boolean  "phone_verified",         default: false
    t.integer  "role"
    t.boolean  "email_verified",         default: false
    t.integer  "pin"
    t.datetime "pin_sent_at"
    t.string   "confirm_token"
    t.string   "email_token"
    t.string   "stripe_customer_id",     default: ""
    t.string   "fcm_token",              default: ""
    t.string   "apns_token",             default: ""
    t.boolean  "push_enabled",           default: false
    t.string   "kyc_document",           default: ""
    t.boolean  "kyc_verified",           default: false
    t.string   "device_id",              default: ""
    t.string   "registration_state",     default: ""
    t.string   "registration_ip",        default: ""
    t.date     "date_of_birth"
    t.string   "kyc_file_name"
    t.string   "kyc_content_type"
    t.integer  "kyc_file_size"
    t.datetime "kyc_updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "activities", "users"
  add_foreign_key "addresses", "countries"
  add_foreign_key "addresses", "users"
  add_foreign_key "admin_transactions", "users", column: "admin_id"
  add_foreign_key "admin_transactions", "users", column: "recipient_id"
  add_foreign_key "agent_accounts", "users"
  add_foreign_key "agent_transactions", "users"
  add_foreign_key "agent_transactions", "users", column: "agent_id"
  add_foreign_key "authtokens", "users"
  add_foreign_key "contact_books", "users"
  add_foreign_key "fees_and_commissions", "countries", column: "receiving_country_id"
  add_foreign_key "fees_and_commissions", "countries", column: "sending_country_id"
  add_foreign_key "invite_notifications", "users", column: "notified_by_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "payment_methods", "countries"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "payment_organisations", "countries"
  add_foreign_key "payment_processors", "countries"
  add_foreign_key "pictures", "users"
  add_foreign_key "referral_contacts", "users"
  add_foreign_key "susu_invites", "susus"
  add_foreign_key "susu_invites", "users", column: "recipient_id"
  add_foreign_key "susu_invites", "users", column: "sender_id"
  add_foreign_key "susu_memberships", "susus"
  add_foreign_key "susu_memberships", "users"
  add_foreign_key "susu_notifications", "smx_transactions"
  add_foreign_key "susu_notifications", "susus"
  add_foreign_key "susu_notifications", "users", column: "notified_by_id"
  add_foreign_key "susu_transactions", "susus"
  add_foreign_key "susu_transactions", "users"
  add_foreign_key "transfer_notifications", "smx_transactions"
  add_foreign_key "transfer_notifications", "users", column: "notified_by_id"
  add_foreign_key "user_cards", "users"
  add_foreign_key "user_charges", "users"
  add_foreign_key "user_transactions", "users", column: "recipient_id"
  add_foreign_key "user_transactions", "users", column: "sender_id"
end
