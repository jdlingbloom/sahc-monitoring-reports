Refile.configure do |config|
  connection = lambda { |&blk| ActiveRecord::Base.connection_pool.with_connection { |con| blk.call(con.raw_connection) } }
  config.store = Refile::Postgres::Backend.new(connection)
  config.cache = Refile::Postgres::Backend.new(connection, :namespace => "cache")
end

Refile::App.before do
  halt 403 unless(env["warden"].authenticated?)
end
