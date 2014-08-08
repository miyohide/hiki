source 'https://rubygems.org'

gem 'rake'
gem 'rack'
gem 'docdiff'
gem 'hikidoc'

group :development do
  gem 'pry'
  gem 'foreman'
end

group :development, :test do
  gem 'capybara', '< 2'
  gem 'test-unit'
  gem 'test-unit-rr'
  gem 'test-unit-notify'
  gem 'test-unit-capybara'
end

group :production do
  gem 'thin'
  gem 'sequel'
  gem 'mysql2'
end
