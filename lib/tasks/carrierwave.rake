namespace :carrierwave do
  desc "Clean temporary cached upload files older than 24 hours"
  task :clean_cached_files => :environment do
    older_than = Time.now.utc - 1.day

    # Cleanup orphaned uploads from if the user uploads a file, but never
    # creates a report using that upload.
    orphaned_uploads = Upload.where("created_at < ?", older_than)
    orphaned_uploads.destroy_all

    # Cleanup orphaned cached files that carrierwave uses internally if a user
    # never completes a save.
    CarrierWave.clean_cached_files!(1.day.seconds)
  end
end
