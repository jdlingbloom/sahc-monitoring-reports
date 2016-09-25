CarrierWave.configure do |config|
  config.storage = :postgresql_table
  config.cache_storage = :postgresql_table
  config.move_to_store = true
end
