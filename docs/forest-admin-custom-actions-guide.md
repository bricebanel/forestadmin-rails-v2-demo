# Forest Admin Custom Actions Guide (Ruby)

This guide documents the correct way to implement custom actions in Forest Admin for Ruby/Rails applications, based on lessons learned from debugging the "Approve Onboarding" action.

## Table of Contents

1. [Common Pitfalls & Solutions](#common-pitfalls--solutions)
2. [API Reference](#api-reference)
3. [Best Practices](#best-practices)
4. [Complete Working Example](#complete-working-example)
5. [Quick Reference Cheat Sheet](#quick-reference-cheat-sheet)

---

## Common Pitfalls & Solutions

### ❌ Pitfall 1: Wrong Argument Style for ResultBuilder Methods

**Error:** `ArgumentError: wrong number of arguments (given 1, expected 0)`

**Wrong:**
```ruby
result_builder.success("Success message")
result_builder.error("Error message")
```

**Correct:**
```ruby
result_builder.success(message: "Success message")
result_builder.error(message: "Error message")
```

**Explanation:** The `ResultBuilder` methods use **keyword arguments**, not positional arguments. Always use `message:` parameter.

---

### ❌ Pitfall 2: Using `return` Instead of `next` in Blocks

**Error:** `LocalJumpError: unexpected return`

**Wrong:**
```ruby
do |context, result_builder|
  if some_condition
    return result_builder.error(message: "Error")
  end
end
```

**Correct:**
```ruby
do |context, result_builder|
  if some_condition
    next result_builder.error(message: "Error")
  end
end
```

**Explanation:** Ruby blocks cannot use `return` - use `next` to exit early from a block.

---

### ❌ Pitfall 3: Accessing Form Values with Method Syntax

**Error:** `NoMethodError: undefined method 'field_name' for an instance of Hash`

**Wrong:**
```ruby
value = context.form_values.field_name
```

**Correct:**
```ruby
value = context.get_form_value('field_name')
```

**Explanation:** `form_values` is a Hash, not an object with method accessors. Use the `get_form_value(key)` method to retrieve values.

---

## API Reference

### ResultBuilder Methods

The `result_builder` parameter provides methods to return different types of responses from your action.

#### `success(message:, options: {})`

Returns a success response to the user.

```ruby
result_builder.success(
  message: "Operation completed successfully!",
  options: {
    html: "<p>Custom HTML content</p>",  # Optional: custom HTML
    invalidated: ['relationship_name']    # Optional: relationships to refresh
  }
)
```

**Parameters:**
- `message:` (String) - The success message to display
- `options:` (Hash) - Optional parameters
  - `html:` (String) - Custom HTML to display
  - `invalidated:` (Array) - Array of relationship names to refresh

**Returns:** Hash with success response

---

#### `error(message:, options: {})`

Returns an error response to the user.

```ruby
result_builder.error(
  message: "Operation failed: Invalid status",
  options: {
    html: "<p>Custom error HTML</p>"  # Optional: custom HTML
  }
)
```

**Parameters:**
- `message:` (String) - The error message to display
- `options:` (Hash) - Optional parameters
  - `html:` (String) - Custom HTML to display

**Returns:** Hash with error response (status 400)

---

#### `webhook(url:, method: 'POST', headers: {}, body: {})`

Triggers a webhook call.

```ruby
result_builder.webhook(
  url: "https://api.example.com/webhook",
  method: "POST",
  headers: { "Authorization" => "Bearer token" },
  body: { data: "payload" }
)
```

**Parameters:**
- `url:` (String) - The webhook URL to call
- `method:` (String) - HTTP method (default: 'POST')
- `headers:` (Hash) - HTTP headers
- `body:` (Hash) - Request body

---

#### `file(content:, name: 'file', mime_type: 'application/octet-stream')`

Returns a file download response.

```ruby
result_builder.file(
  content: file_content,
  name: "report.pdf",
  mime_type: "application/pdf"
)
```

**Parameters:**
- `content:` (String) - File content/stream
- `name:` (String) - File name (default: 'file')
- `mime_type:` (String) - MIME type (default: 'application/octet-stream')

---

#### `redirect_to(path:)`

Redirects to a different path.

```ruby
result_builder.redirect_to(path: "/admin/companies/123")
```

**Parameters:**
- `path:` (String) - The path to redirect to

---

#### `set_header(key, value)`

Sets a custom HTTP header in the response.

```ruby
result_builder.set_header('X-Custom-Header', 'value')
```

**Parameters:**
- `key` (String) - Header name
- `value` (String) - Header value

**Returns:** Self (chainable)

---

### ActionContext Methods

The `context` parameter provides methods to access action data and records.

#### `get_form_value(key)`

Retrieves a value from the submitted form.

```ruby
approved_limit = context.get_form_value('approved_credit_limit')
justification = context.get_form_value('justification')
```

**Parameters:**
- `key` (String) - The field ID as defined in the form configuration

**Returns:** The form value (type depends on field type)

---

#### `get_record(fields = [])`

Fetches a single record with specified fields. Used for `ActionScope::SINGLE` actions.

```ruby
company = context.get_record(['id', 'company_name', 'status'])
# Returns: { 'id' => 123, 'company_name' => 'Acme Corp', 'status' => 'active' }
```

**Parameters:**
- `fields` (Array<String>) - Array of field names to retrieve

**Returns:** Hash with the record data

**Note:** This handles ID type conversion internally - recommended over manual queries.

---

#### `get_records(fields = [])`

Fetches multiple records with specified fields. Used for bulk actions.

```ruby
companies = context.get_records(['id', 'company_name'])
# Returns: [{ 'id' => 1, ... }, { 'id' => 2, ... }]
```

**Parameters:**
- `fields` (Array<String>) - Array of field names to retrieve

**Returns:** Array of record Hashes

---

#### `record_ids` / `get_record_ids`

Gets array of primary key IDs for the selected records.

```ruby
ids = context.record_ids
# Returns: [123, 456, 789]
```

**Returns:** Array of IDs (simple primary keys)

---

#### `composite_record_ids` / `get_composite_record_ids`

Gets array of composite primary keys for the selected records.

```ruby
ids = context.composite_record_ids
# Returns: [[123, 'A'], [456, 'B']] for composite keys
```

**Returns:** Array of Arrays (for composite primary keys)

---

#### `field_changed?(field_name)` / `has_field_changed(field_name)`

Checks if a field value changed (useful in dynamic forms).

```ruby
if context.field_changed?('country')
  # Update dependent fields
end
```

**Parameters:**
- `field_name` (String) - The field ID to check

**Returns:** Boolean

---

## Best Practices

### 1. Structure Your Action Clearly

Organize your action logic in clear sections:

```ruby
collection.add_action('Action Name', BaseAction.new(...)) do |context, result_builder|
  # 1. Fetch records
  record = context.get_record(['id', 'field1', 'field2'])

  # 2. Get ActiveRecord model if needed
  model = ModelName.find(record['id'])

  # 3. Validate
  unless valid_condition
    next result_builder.error(message: "Validation failed")
  end

  # 4. Get form values
  value1 = context.get_form_value('field1')
  value2 = context.get_form_value('field2')

  # 5. Perform operations
  model.update!(...)

  # 6. Log the action
  Rails.logger.info("Action completed: #{details}")

  # 7. Return success
  result_builder.success(message: "Success!")
end
```

---

### 2. Early Exit for Validation Errors

Use `next` with error messages to exit early:

```ruby
# Check status
unless ['pending', 'active'].include?(record.status)
  next result_builder.error(message: "Invalid status: #{record.status}")
end

# Check permissions
unless user.can_approve?
  next result_builder.error(message: "You don't have permission to approve")
end

# ... continue with main logic
```

---

### 3. Use Clear, User-Friendly Messages

Make your success/error messages helpful:

```ruby
# ❌ Bad: Technical message
result_builder.error(message: "status != 'pending'")

# ✅ Good: Clear, actionable message
result_builder.error(
  message: "❌ Cannot approve: Company status is '#{company.status}'. " \
           "Only companies with 'pending' status can be approved."
)
```

---

### 4. Log Important Actions

Always log significant actions for audit trails:

```ruby
Rails.logger.info(
  "Company approved: #{company.company_name} (ID: #{company.id}) - " \
  "Credit limit: €#{approved_limit} - User: #{current_user.email}"
)
```

Consider creating audit log records:

```ruby
AuditLog.create!(
  action: 'approve_company',
  user_id: current_user.id,
  record_type: 'Company',
  record_id: company.id,
  changes: { credit_limit: approved_limit },
  metadata: { justification: justification }
)
```

---

### 5. Handle Errors Gracefully

Wrap risky operations in error handling:

```ruby
begin
  company.update!(status: 'active')
  ThirdPartyService.activate_account(company.id)

  result_builder.success(message: "Account activated!")
rescue ActiveRecord::RecordInvalid => e
  next result_builder.error(message: "Database error: #{e.message}")
rescue ThirdPartyService::Error => e
  next result_builder.error(message: "Service error: #{e.message}")
end
```

---

### 6. Use Form Field IDs Exactly

The field ID in `get_form_value()` must match the `id` in form definition:

```ruby
# Form definition
form: [
  {
    id: "approved_credit_limit",  # ← This ID
    type: FieldType::NUMBER,
    # ...
  }
]

# Accessing value
approved_limit = context.get_form_value('approved_credit_limit')  # ← Must match
```

---

### 7. Leverage Field Types Appropriately

Choose the right field type for your use case:

```ruby
form: [
  # Text input
  { type: FieldType::STRING, id: "notes" },

  # Long text with textarea widget
  { type: FieldType::STRING, id: "description", widget: 'TextArea' },

  # Numbers
  { type: FieldType::NUMBER, id: "amount" },

  # Booleans (checkboxes)
  { type: FieldType::BOOLEAN, id: "enabled", value: true },

  # Dates
  { type: FieldType::DATE, id: "scheduled_date" },

  # Dropdowns
  { type: FieldType::ENUM, id: "status", enum_values: ['pending', 'approved'] },

  # File uploads
  { type: FieldType::FILE, id: "document" }
]
```

---

## Complete Working Example

Here's the full "Approve Onboarding" action that demonstrates all best practices:

```ruby
module ForestAdminRails
  class CreateAgent
    include ForestAdminDatasourceCustomizer::Decorators::Action::Types
    include ForestAdminDatasourceCustomizer::Decorators::Action

    def self.customize
      @create_agent.customize_collection('Company') do |collection|
        collection.add_action(
          'Approve Onboarding',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Approve company onboarding and activate their account",
            submit_button_label: "✅ Approve & Activate",
            form: [
              {
                type: FieldType::NUMBER,
                label: "Approved Credit Limit (€)",
                id: "approved_credit_limit",
                description: "Set the credit limit for this company",
                is_required: true
              },
              {
                type: FieldType::STRING,
                label: "Justification Notes",
                id: "justification",
                description: "Explain why this credit limit was approved",
                is_required: true,
                widget: 'TextArea'
              },
              {
                type: FieldType::BOOLEAN,
                label: "Enable Factoring Service",
                id: "enable_factoring",
                description: "Allow this company to use invoice factoring",
                value: true
              },
              {
                type: FieldType::BOOLEAN,
                label: "Enable Guarantees Service",
                id: "enable_guarantees",
                description: "Allow this company to request retention guarantees",
                value: true
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the company data from Forest Admin
            company_record = context.get_record([
              'id', 'company_name', 'kyc_status', 'status',
              'credit_limit_eur', 'onboarded_at'
            ])

            # 2. Get the ActiveRecord model instance
            company = Company.find(company_record['id'])

            # 3. Validate company state
            unless ['pending', 'in_progress'].include?(company.kyc_status)
              next result_builder.error(
                message: "❌ Cannot approve: Company KYC status is '#{company.kyc_status}'. " \
                         "Only 'pending' or 'in_progress' companies can be approved."
              )
            end

            # 4. Get form values
            approved_limit = context.get_form_value('approved_credit_limit')
            justification = context.get_form_value('justification')
            enable_factoring = context.get_form_value('enable_factoring')
            enable_guarantees = context.get_form_value('enable_guarantees')

            # 5. Update company
            company.update!(
              kyc_status: 'validated',
              status: 'active',
              credit_limit_eur: approved_limit,
              onboarded_at: company.onboarded_at || Time.current
            )

            # 6. Log the action
            Rails.logger.info(
              "Company approved: #{company.company_name} (ID: #{company.id}) - " \
              "Credit limit: €#{approved_limit} - Justification: #{justification} - " \
              "Factoring: #{enable_factoring}, Guarantees: #{enable_guarantees}"
            )

            # 7. Return success message
            result_builder.success(
              message: "✅ #{company.company_name} has been approved and activated!\n\n" \
                       "Credit Limit: €#{approved_limit.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\n" \
                       "Services: #{[enable_factoring ? 'Factoring' : nil, enable_guarantees ? 'Guarantees' : nil].compact.join(', ')}\n\n" \
                       "The company can now start using Faktus services."
            )
          end
        )
      end
    end
  end
end
```

---

## Quick Reference Cheat Sheet

### ResultBuilder Methods (Always use keyword arguments!)

```ruby
# Success
result_builder.success(message: "Success!")
result_builder.success(message: "Done!", options: { invalidated: ['relationship'] })

# Error
result_builder.error(message: "Error occurred")

# File download
result_builder.file(content: data, name: "file.pdf", mime_type: "application/pdf")

# Webhook
result_builder.webhook(url: "https://...", method: "POST", body: { key: "value" })

# Redirect
result_builder.redirect_to(path: "/admin/companies/123")

# Custom header
result_builder.set_header('X-Custom', 'value')
```

---

### Context Methods

```ruby
# Get form values (use this!)
value = context.get_form_value('field_id')

# Get single record
record = context.get_record(['field1', 'field2'])

# Get multiple records
records = context.get_records(['field1', 'field2'])

# Get IDs
ids = context.record_ids  # or context.get_record_ids

# Check field changes
if context.field_changed?('field_name')
  # ...
end
```

---

### Control Flow in Blocks

```ruby
# Early exit (use 'next', NOT 'return')
do |context, result_builder|
  if invalid?
    next result_builder.error(message: "Error")  # ✅ Use 'next'
  end

  # Continue with main logic...
end
```

---

### Action Scopes

```ruby
# Single record action
scope: ActionScope::SINGLE

# Bulk action (multiple records)
scope: ActionScope::BULK

# Global action (no specific record)
scope: ActionScope::GLOBAL
```

---

### Field Types

```ruby
FieldType::STRING
FieldType::NUMBER
FieldType::BOOLEAN
FieldType::DATE
FieldType::DATETIME
FieldType::ENUM
FieldType::FILE
FieldType::JSON
```

---

## Additional Resources

- Forest Admin Ruby Agent: `~/.rbenv/versions/3.3.6/lib/ruby/gems/3.3.0/gems/forest_admin_*`
- ResultBuilder source: `forest_admin_datasource_customizer-*/lib/.../result_builder.rb`
- ActionContext source: `forest_admin_datasource_customizer-*/lib/.../action_context.rb`

---

## Summary

When creating custom actions in Forest Admin (Ruby):

1. ✅ Always use **keyword arguments** for `result_builder` methods (`message:`)
2. ✅ Use **`next`** (not `return`) to exit early from blocks
3. ✅ Use **`context.get_form_value('field_id')`** to access form values
4. ✅ Structure your code clearly with comments
5. ✅ Validate early and provide clear error messages
6. ✅ Log important actions for audit trails
7. ✅ Handle errors gracefully

Following these patterns will help you avoid common pitfalls and create robust, maintainable custom actions.
