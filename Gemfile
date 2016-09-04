source "https://rubygems.org"

ruby "2.3.1"

gem "rails", "~> 4.2.7.1"

# For deploying to Heroku.
gem "rails_12factor", :groups => [:production]
gem "heroku-deflater", :groups => [:production]

# For ENV based configuration in development.
gem "dotenv-rails", "~> 2.1.1", :groups => [:development, :test]

# Server
gem "puma", "~> 3.6.0"

# PostgreSQL
gem "pg", "~> 0.18.4"

# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

# Use jquery as the JavaScript library
gem "jquery-rails"

# Bootstrap styles
gem "bootstrap-sass", "~> 3.3.7"

# Error logging
gem "rollbar", "~> 2.12.0"

# EXIF extraction from JPEGs
gem "exifr", "~> 1.2.5"

# Unzip KMZ files
gem "rubyzip", "~> 1.2.0", :require => "zip"

# HTML encoding
gem "htmlentities", "~> 4.3.4"

# File Uploads
gem "refile", "~> 0.6.2", :require => "refile/rails"
gem "refile-postgres", "~> 1.4.0"
gem "refile-mini_magick", "~> 0.2.0"

# Caching for refile's uploads
gem "rack-cache", "~> 1.6.1"

# Soft deletes
gem "paranoia", "~> 2.1.5"

# Userstamping
gem "activerecord-userstamp", "~> 3.0.4"

# PDF generation
gem "prawn", "~> 2.1.0"

# Automatic model validations based on database constraints
gem "schema_validations", "~> 2.1.1"

# Form layouts
gem "simple_form", "~> 3.3.1"

# Vendor asset management
gem "torba-rails", "~> 1.0.1", :git => "https://github.com/torba-rb/torba-rails.git", :branch => "heroku-broken-deploy"

# Authentication
gem "devise", "~> 4.2.0"
gem "omniauth", "~> 1.3.1"
gem "omniauth-google-oauth2", "~> 0.4.1"

# Breadcrumbs
gem "gretel", "~> 3.0.9"

group :development, :test do
  # Add comments to models describing the available columns
  gem "annotate", "~> 2.7.1"

  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"
end
