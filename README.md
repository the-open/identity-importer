# Identity::Importer

Import actions, mailing, and other information from CiviCRM and other sources into Identity

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'identity-importer', :path => "/path/to/identity-importer"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install identity-importer

## Usage

To use the gem you need to configure the database to use. Create a file called `importer.rb` in your application intializers folder `config/initalizers` with following content

```ruby
Identity::Importer.configure do |config|
  config.database_adapter = "MySQL" # Currently only MySQL is supported, case insensitive
  config.database_host = "127.0.0.1" # Database Host
  config.database_name = "civicrm" # Database Name
  config.database_user = "root" # Database User
  config.database_password = "root" # Database Password
  config.campaign_types = ['campaign_type1', 'campaign_type2'] # Different Campaign Types
  config.action_types = ['Petition Signature', 'Share', 'Email'] # Different Action Types
end
```

NOTE: The above only works for CiviCRM.

## Running the sync tasks

Use `rake` to the run the tasks from the `identity` home folder

```
bundle exec rake identity_importer:run
```

This rake task can be found at `identity-app/tasks/identity_importer.rake`. The order in the rake task is the suggested order. You can enable and disable tasks by editing the file.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/the-open/identity-importer.
