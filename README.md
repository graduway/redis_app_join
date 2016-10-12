# RedisAppJoin

Sometimes we need to implement application level joins.  It is easy to query User table and get list of user_ids and then query the child record table for records that belong to those users.  But what if we need to combine data attributes from both tables?  This can also be a use case when querying mutliple databases or 3rd party APIs.  

You can use Redis Hashes as a place to cache data needed as you are looping through records.  Warning - this is ALPHA quality software, be careful before running it in production.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redis_app_join'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis_app_join

## Usage

Create config/initializers/redis_app_join.rb or place this in environment specific config file

```ruby
redis_conn = Redis.new(host: 'localhost', port: 6379, db: 0)
REDIS_APP_JOIN = Redis::Namespace.new(:codecov, redis: redis_conn)
```

In the Ruby class where you need to implement application-side join add this:

```ruby
include RedisAppJoin
# as you are looping through records call 
cache_join_data(record)
```

### TODO:

implment methods to cache, fetch and delete records

write tests

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/redis_app_join.

