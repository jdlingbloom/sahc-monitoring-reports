namespace :refile do
  desc "Clean temporary cached upload files older than 24 hours"
  task :clean_cached_files => :environment do
    older_than = Time.now.utc - 1.day

    # Cleanup orphaned uploads from if the user uploads a file, but never
    # creates a report using that upload.
    orphaned_uploads = Upload.where("created_at < ?", older_than)
    orphaned_uploads.destroy_all

    # Cleanup orphaned cached files that refile uses internally if a user never
    # completes a save.
    orphaned_cache_rows = ActiveRecord::Base.connection.execute("SELECT oid FROM refile_attachments WHERE namespace = 'cache' AND created_at < #{ActiveRecord::Base.connection.quote(older_than)}")
    orphaned_cache_rows.each do |row|
      puts row.inspect
      Refile.cache.delete(row["oid"])
    end
  end
end
