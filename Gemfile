source 'https://rubygems.org'

# ruby '2.1.2'

# gem 'rails', '3.2.16'

ruby '2.5.1'
gem 'rails', '4.2.11.3'

gem 'haml'
gem 'faraday'
gem 'active_model_serializers'
gem 'puma'
gem 'dalli'
gem 'simple_form'
gem 'rack-cache'
gem 'rails_autoscale_agent'
gem 'terminal-table'
gem 'mapbox-gl-rails', '~> 1.6', '>= 1.6.1'
gem 'test-unit'
gem 'sprockets', '~>3.0'
gem 'responders', '~> 2.0'
gem 'byebug'

group :assets do
  gem 'sass-rails'#,   '~> 3.2.3'
  gem 'coffee-rails'#, '~> 3.2.1'
  gem 'bourbon'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '~> 3.2.0'
  gem 'jquery-rails'
end

group :production do
  gem 'memcachier'
  gem 'newrelic_rpm'
end

group :test do
  gem 'rspec-rails', '~> 2.14.0'
  gem 'capybara'
  gem 'poltergeist'
  gem 'timecop'
end

group :development, :test do
  gem 'foreman'
  gem 'pry-rails'
end