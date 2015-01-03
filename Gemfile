source 'http://rubygems.org'

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "default"
  "~> 3.2.0"
else
  "~> #{rails_version}"
end

version = ENV["RAILS_VERSION"] || "3.2"

eval_gemfile File.expand_path("../gemfiles/#{version}.gemfile", __FILE__)