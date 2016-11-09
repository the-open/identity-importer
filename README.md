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

## Extending the Gem

### Database
To add support for a new database, you need to do the following steps:

1. Update `Gemfile` with the required dependencies.
1. Edit `lib/identity/importer/connection.rb` and do the following:
  * Add a new case for the name of the database adapter (example "postgresql" or "sqlite")
  * Create a `@client` object with the established connection
  * Update the `run_query` method if required
1. If the new adapter requires more or less configuration:
  * Update `lib/identity/importer/configuration.rb` to support the new variables
  * Update `valid_database_config?` method in the same class to support the new variables

Update the configuration in the identity app with the required configuration changes.

### Task Run List

To modify the task run list edit the rake file in the identity app (not this gem). You can find the file at `identity-app/tasks/identity_importer.rake`

### New source database schemas

To add support for a new type of database schema you need to create task files that inherit from the base task files. For example look at the various files in `lib/identity/importer/tasks/civicrm/`

1. Maintain the current structure of the gem and create a new folder in `lib/identity/importer/tasks/`
1. Create a new class that inherits from the base class. The base classes can be found in `lib/identity/importer/tasks/`
1. Add a `self.sql` method that returns the sql to be run by the base class
1. If you want to update the way the data is imported, or the sql is run, add a `self.run` method 
1. Update the task run list pointing to your newly created class

Note: We use `activerecord-import` to do import in batches for faster performance. Look at the base classes if you plan to add your own runner

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/the-open/identity-importer.
