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

ActiveRecord::Schema.define(version: 20170615132436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"

  create_table "accounts", force: :cascade do |t|
    t.string   "address",         limit: 42, null: false
    t.integer  "user_id"
    t.integer  "balance"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "external"
    t.boolean  "primary_account"
    t.index ["user_id"], name: "index_accounts_on_user_id", using: :btree
  end

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "ethtransaction_id"
    t.string   "item_type"
    t.integer  "item_id"
    t.string   "description"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "onetimer_id"
    t.string   "extra_info"
    t.integer  "addition",                  default: 0, null: false
    t.string   "extra_type"
    t.integer  "extra_id"
    t.string   "txaddress"
    t.integer  "blockchain_transaction_id"
    t.integer  "numerical_value"
    t.index ["ethtransaction_id"], name: "index_activities_on_ethtransaction_id", using: :btree
    t.index ["extra_type", "extra_id"], name: "index_activities_on_extra_type_and_extra_id", using: :btree
    t.index ["item_type", "item_id"], name: "index_activities_on_item_type_and_item_id", using: :btree
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "authentications", force: :cascade do |t|
    t.string   "provider"
    t.string   "username"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "provider", "uid"], name: "index_authentications_on_user_id_and_provider_and_uid", unique: true, using: :btree
    t.index ["user_id"], name: "index_authentications_on_user_id", using: :btree
  end

  create_table "blockchain_transactions", force: :cascade do |t|
    t.integer  "transaction_type_id"
    t.integer  "account_id"
    t.integer  "ethtransaction_id"
    t.integer  "value"
    t.datetime "submitted_at"
    t.datetime "confirmed_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "recipient_id"
    t.index ["account_id"], name: "index_blockchain_transactions_on_account_id", using: :btree
    t.index ["ethtransaction_id"], name: "index_blockchain_transactions_on_ethtransaction_id", using: :btree
    t.index ["transaction_type_id"], name: "index_blockchain_transactions_on_transaction_type_id", using: :btree
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.string   "item_type"
    t.integer  "item_id"
    t.integer  "user_id"
    t.text     "content"
    t.string   "image"
    t.string   "image_content_type"
    t.integer  "image_size"
    t.integer  "image_width"
    t.integer  "image_height"
    t.string   "attachment"
    t.integer  "attachment_size"
    t.string   "attachment_content_type"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "systemflag",              default: false, null: false
    t.boolean  "frontpage",               default: false, null: false
    t.index ["item_type", "item_id"], name: "index_comments_on_item_type_and_item_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "credits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "awarder_id"
    t.string   "description"
    t.integer  "ethtransaction_id"
    t.string   "attachment"
    t.string   "attachment_content_type"
    t.integer  "attachment_size"
    t.integer  "value"
    t.integer  "rate_id"
    t.string   "notes"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_credits_on_deleted_at", using: :btree
    t.index ["ethtransaction_id"], name: "index_credits_on_ethtransaction_id", using: :btree
    t.index ["rate_id"], name: "index_credits_on_rate_id", using: :btree
    t.index ["user_id"], name: "index_credits_on_user_id", using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "emails", force: :cascade do |t|
    t.datetime "sent_at"
    t.boolean  "sent",        default: false, null: false
    t.text     "body"
    t.string   "subject"
    t.string   "slug"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "sent_number"
  end

  create_table "ethtransactions", force: :cascade do |t|
    t.integer  "transaction_type_id",                                null: false
    t.string   "txaddress",               limit: 66,                 null: false
    t.string   "source_account"
    t.string   "recipient_account"
    t.integer  "source_user"
    t.integer  "recipient_user"
    t.integer  "value"
    t.datetime "timeof"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "credit_id"
    t.boolean  "confirmed",                          default: false, null: false
    t.datetime "checked_confirmation_at"
    t.index ["transaction_type_id"], name: "index_ethtransactions_on_transaction_type_id", using: :btree
  end

  create_table "event_translations", force: :cascade do |t|
    t.integer  "event_id",    null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
    t.index ["event_id"], name: "index_event_translations_on_event_id", using: :btree
    t.index ["locale"], name: "index_event_translations_on_locale", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.integer  "place_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "published"
    t.integer  "primary_sponsor_id"
    t.integer  "secondary_sponsor_id"
    t.string   "slug"
    t.float    "cost_euros"
    t.integer  "cost_bb"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "image"
    t.string   "image_content_type"
    t.integer  "image_size"
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",                default: 0,     null: false
    t.integer  "children_count",       default: 0,     null: false
    t.string   "sequence"
    t.integer  "proposal_id"
    t.boolean  "collapse_in_website",  default: false, null: false
    t.index ["place_id"], name: "index_events_on_place_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "hardwares", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.macaddr  "mac_address"
    t.text     "description"
    t.string   "authentication_token", limit: 30
    t.integer  "hardwaretype_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "checkable"
    t.datetime "last_checked_at"
    t.boolean  "notified_of_error"
    t.index ["authentication_token"], name: "index_hardwares_on_authentication_token", unique: true, using: :btree
    t.index ["hardwaretype_id"], name: "index_hardwares_on_hardwaretype_id", using: :btree
    t.index ["slug"], name: "index_hardwares_on_slug", unique: true, using: :btree
  end

  create_table "hardwaretypes", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["slug"], name: "index_hardwaretypes_on_slug", unique: true, using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.string   "image"
    t.string   "image_content_type"
    t.integer  "image_size"
    t.integer  "image_width"
    t.integer  "image_height"
    t.string   "item_type"
    t.integer  "item_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["item_type", "item_id"], name: "index_images_on_item_type_and_item_id", using: :btree
  end

  create_table "instance_translations", force: :cascade do |t|
    t.integer  "instance_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
    t.index ["instance_id"], name: "index_instance_translations_on_instance_id", using: :btree
    t.index ["locale"], name: "index_instance_translations_on_locale", using: :btree
  end

  create_table "instances", force: :cascade do |t|
    t.integer  "event_id",                               null: false
    t.integer  "cost_bb"
    t.float    "cost_euros"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "place_id"
    t.boolean  "published"
    t.string   "image"
    t.string   "image_content_type"
    t.integer  "image_height"
    t.integer  "image_width"
    t.integer  "image_size"
    t.string   "slug"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "sequence"
    t.boolean  "is_meeting"
    t.integer  "proposal_id"
    t.boolean  "allow_multiple_entry"
    t.boolean  "spent_biathlon",         default: false, null: false
    t.boolean  "request_rsvp"
    t.boolean  "request_registration"
    t.float    "custom_bb_fee"
    t.string   "email_registrations_to"
    t.string   "question1_text"
    t.string   "question2_text"
    t.string   "question3_text"
    t.string   "question4_text"
    t.string   "boolean1_text"
    t.string   "boolean2_text"
    t.boolean  "require_approval"
    t.boolean  "hide_registrants"
    t.boolean  "show_guests_to_public"
    t.integer  "max_attendees"
    t.boolean  "registration_open",      default: true,  null: false
    t.index ["event_id"], name: "index_instances_on_event_id", using: :btree
    t.index ["place_id"], name: "index_instances_on_place_id", using: :btree
    t.index ["proposal_id"], name: "index_instances_on_proposal_id", using: :btree
  end

  create_table "instances_users", force: :cascade do |t|
    t.integer  "instance_id", null: false
    t.integer  "user_id",     null: false
    t.date     "visit_date"
    t.integer  "activity_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["activity_id"], name: "index_instances_users_on_activity_id", using: :btree
    t.index ["user_id", "instance_id", "visit_date"], name: "index_instances_users_on_user_id_and_instance_id_and_visit_date", unique: true, using: :btree
  end

  create_table "nfcs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "tag_address",   limit: 20
    t.boolean  "active"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "security_code"
    t.datetime "last_used"
    t.boolean  "keyholder",                default: false, null: false
    t.index ["tag_address"], name: "index_nfcs_on_tag_address", unique: true, using: :btree
    t.index ["user_id"], name: "index_nfcs_on_user_id", using: :btree
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.boolean  "is_open",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "onetimers", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "code",        limit: 7
    t.boolean  "claimed",               default: false, null: false
    t.integer  "user_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["code"], name: "index_onetimers_on_code", unique: true, using: :btree
    t.index ["instance_id"], name: "index_onetimers_on_instance_id", using: :btree
    t.index ["user_id"], name: "index_onetimers_on_user_id", using: :btree
  end

  create_table "opensessions", force: :cascade do |t|
    t.integer  "node_id",    null: false
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_opensessions_on_node_id", using: :btree
    t.index ["node_id"], name: "null_valid_from", unique: true, where: "(closed_at IS NULL)", using: :btree
  end

  create_table "page_translations", force: :cascade do |t|
    t.integer  "page_id",    null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
    t.text     "body"
    t.index ["locale"], name: "index_page_translations_on_locale", using: :btree
    t.index ["page_id"], name: "index_page_translations_on_page_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.boolean  "published"
    t.string   "slug"
    t.string   "image"
    t.string   "image_content_type"
    t.integer  "image_size"
    t.integer  "image_height"
    t.integer  "image_width"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.string   "searchable_type"
    t.integer  "searchable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree
  end

  create_table "place_translations", force: :cascade do |t|
    t.integer  "place_id",   null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.index ["locale"], name: "index_place_translations_on_locale", using: :btree
    t.index ["place_id"], name: "index_place_translations_on_place_id", using: :btree
  end

  create_table "places", force: :cascade do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "country"
    t.string   "postcode"
    t.decimal  "latitude",   precision: 10, scale: 6
    t.decimal  "longitude",  precision: 10, scale: 6
    t.string   "slug"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "pledges", force: :cascade do |t|
    t.string   "item_type"
    t.integer  "item_id"
    t.integer  "user_id"
    t.integer  "pledge"
    t.string   "comment"
    t.integer  "converted"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
    t.string   "extra_info"
    t.integer  "instance_id"
    t.index ["item_type", "item_id"], name: "index_pledges_on_item_type_and_item_id", using: :btree
    t.index ["user_id"], name: "index_pledges_on_user_id", using: :btree
  end

  create_table "post_translations", force: :cascade do |t|
    t.integer  "post_id",    null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
    t.text     "body"
    t.index ["locale"], name: "index_post_translations_on_locale", using: :btree
    t.index ["post_id"], name: "index_post_translations_on_post_id", using: :btree
  end

  create_table "postcategories", force: :cascade do |t|
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "postcategory_translations", force: :cascade do |t|
    t.integer  "postcategory_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "name"
    t.index ["locale"], name: "index_postcategory_translations_on_locale", using: :btree
    t.index ["postcategory_id"], name: "index_postcategory_translations_on_postcategory_id", using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.string   "slug"
    t.boolean  "published"
    t.integer  "user_id"
    t.datetime "published_at"
    t.string   "image"
    t.integer  "image_width"
    t.integer  "image_height"
    t.string   "image_content_type"
    t.integer  "image_size"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "sticky"
    t.integer  "instance_id"
    t.integer  "postcategory_id"
    t.index ["user_id"], name: "index_posts_on_user_id", using: :btree
  end

  create_table "proposals", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "short_description"
    t.string   "timeframe"
    t.text     "goals"
    t.string   "intended_participants"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "comment_count",                       default: 0
    t.boolean  "notified"
    t.boolean  "scheduled"
    t.boolean  "allow_rescheduling"
    t.integer  "recurrence"
    t.integer  "intended_sessions"
    t.boolean  "stopped",                             default: false, null: false
    t.integer  "proposalstatus_id"
    t.integer  "total_needed_with_recurrence_cached"
    t.string   "needed_array_cached"
    t.boolean  "has_enough_cached"
    t.integer  "number_that_can_be_scheduled_cached"
    t.boolean  "pledgeable_cached"
    t.integer  "pledged_cached"
    t.integer  "remaining_pledges_cached"
    t.integer  "spent_cached"
    t.integer  "published_instances",                 default: 0,     null: false
    t.integer  "duration",                            default: 1
    t.boolean  "is_month_long",                       default: false, null: false
    t.boolean  "require_all",                         default: false, null: false
    t.index ["user_id"], name: "index_proposals_on_user_id", using: :btree
  end

  create_table "proposalstatus_translations", force: :cascade do |t|
    t.integer  "proposalstatus_id", null: false
    t.string   "locale",            null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "name"
    t.index ["locale"], name: "index_proposalstatus_translations_on_locale", using: :btree
    t.index ["proposalstatus_id"], name: "index_proposalstatus_translations_on_proposalstatus_id", using: :btree
  end

  create_table "proposalstatuses", force: :cascade do |t|
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rates", force: :cascade do |t|
    t.boolean  "current"
    t.integer  "experiment_cost"
    t.float    "euro_exchange"
    t.integer  "instance_id"
    t.text     "comments"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "room_cost",       default: 25, null: false
    t.index ["instance_id"], name: "index_rates_on_instance_id", using: :btree
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.string   "phone"
    t.text     "question1"
    t.text     "question2"
    t.boolean  "boolean1"
    t.boolean  "boolean2"
    t.text     "question3"
    t.text     "question4"
    t.boolean  "approved"
    t.boolean  "waiting_list", default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["instance_id"], name: "index_registrations_on_instance_id", using: :btree
    t.index ["user_id"], name: "index_registrations_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "roombookings", force: :cascade do |t|
    t.date     "day",               null: false
    t.integer  "user_id",           null: false
    t.integer  "ethtransaction_id"
    t.integer  "rate_id",           null: false
    t.string   "purpose"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["day"], name: "index_roombookings_on_day", unique: true, using: :btree
    t.index ["ethtransaction_id"], name: "index_roombookings_on_ethtransaction_id", using: :btree
    t.index ["rate_id"], name: "index_roombookings_on_rate_id", using: :btree
    t.index ["user_id"], name: "index_roombookings_on_user_id", using: :btree
  end

  create_table "rsvps", force: :cascade do |t|
    t.integer  "instance_id", null: false
    t.integer  "user_id",     null: false
    t.text     "comment"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["instance_id", "user_id"], name: "index_rsvps_on_instance_id_and_user_id", unique: true, using: :btree
    t.index ["instance_id"], name: "index_rsvps_on_instance_id", using: :btree
    t.index ["user_id"], name: "index_rsvps_on_user_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.hstore   "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transaction_types", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "factorial",  default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                     default: ""
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "username"
    t.string   "authentication_token"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "name"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "slug"
    t.integer  "latest_balance",            default: 0,     null: false
    t.datetime "latest_balance_checked_at"
    t.string   "geth_pwd"
    t.boolean  "show_name",                 default: false, null: false
    t.string   "avatar"
    t.string   "avatar_content_type"
    t.integer  "avatar_size"
    t.integer  "avatar_width"
    t.integer  "avatar_height"
    t.boolean  "opt_in",                    default: true
    t.string   "website"
    t.text     "about_me"
    t.string   "twitter_name"
    t.string   "address"
    t.string   "postcode"
    t.string   "city"
    t.string   "country"
    t.boolean  "show_twitter_link",         default: false, null: false
    t.boolean  "show_facebook_link",        default: false, null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "activities", "ethtransactions"
  add_foreign_key "authentications", "users"
  add_foreign_key "blockchain_transactions", "accounts"
  add_foreign_key "blockchain_transactions", "ethtransactions"
  add_foreign_key "blockchain_transactions", "transaction_types"
  add_foreign_key "comments", "users"
  add_foreign_key "credits", "ethtransactions"
  add_foreign_key "credits", "rates"
  add_foreign_key "credits", "users"
  add_foreign_key "ethtransactions", "transaction_types"
  add_foreign_key "events", "places"
  add_foreign_key "hardwares", "hardwaretypes"
  add_foreign_key "instances", "events"
  add_foreign_key "instances", "places"
  add_foreign_key "nfcs", "users"
  add_foreign_key "onetimers", "users"
  add_foreign_key "opensessions", "nodes"
  add_foreign_key "pledges", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "proposals", "users"
  add_foreign_key "rates", "instances"
  add_foreign_key "registrations", "instances"
  add_foreign_key "registrations", "users"
  add_foreign_key "roombookings", "ethtransactions"
  add_foreign_key "roombookings", "rates"
  add_foreign_key "roombookings", "users"
  add_foreign_key "rsvps", "instances"
  add_foreign_key "rsvps", "users"
end
