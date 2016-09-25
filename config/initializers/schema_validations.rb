SchemaValidations.setup do |config|
  # Don't enable schema_validations globally, so it doesn't impact models from
  # other gems.
  config.auto_create = false

  # Don't add uniqueness validations by default. This lets us defer error
  # handling to the database and catching the ActiveRecord::RecordNotUnique
  # error.
  config.except_type = [:unique]
end
