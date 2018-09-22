source 'https://rubygems.org'


group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem "vagrant", :git => "https://github.com/mitchellh/vagrant.git"
  gem 'ruby-debug-ide'
  gem 'debase'
end

gem 'rake'

group :plugins do
  gem 'vagrant-omnibus'
  gem 'vagrant-haipa', :path => '.'
end

#gemspec
