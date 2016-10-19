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

Create config/initializers/redis_app_join.rb or place this in environment specific config file.  You can use a different namespace, DB, driver, etc.  

```ruby
redis_conn = Redis.new(host: 'localhost', port: 6379, db: 0)
REDIS_APP_JOIN = Redis::Namespace.new(:appjoin, redis: redis_conn)
```

In the Ruby class where you need to implement application-side join add `include RedisAppJoin`.  Here is a sample report generator that will produce a report of comments created since yesterday and include associated article title and name of user who wrote the article.

```ruby
class ReportGen
  include RedisAppJoin
  def perform
    comments = Comment.gte(created_at: Date.yesterday).only(:body, :article_id)
    cache_records(records: comments)
    comment_ids = comments.pluck(:id)
    # =>
    # => we also could have done  comments.pluck(:article_id)
    article_ids = fetch_records_field(record_class: 'Comment', record_ids: comment_ids, field: 'article_id')
    articles = Article.in(id: article_ids).only(:title, :user_id)
    cache_records(records: articles)
    # =>
    user_ids = fetch_records_field(record_class: 'Article', record_ids: article_ids, field: 'user_id')
    users = User.in(id: user_ids).only(:name)
    cache_records(records: users)
    # => instead of using cached comments we could query DB again
    cached_comments = fetch_records(record_class: 'Comment', record_ids: comment_ids)
    cached_comments.each do |comment|
      article = fetch_records(record_class: 'Article', record_ids: [comment.article_id]).first
      user = fetch_records(record_class: 'User', record_ids: [article.user_id]).first
      puts [comment.body, article.title, user.name].join(',')
    end
    delete_records(records: comments + articles + users)
  end
end
```

Data in Redis will be stored like this:

```ruby
{"db":0,"key":"appjoin:Comment:id1","ttl":-1,"type":"hash","value":{"body":"body 1","article_id":"id1"},...}
{"db":0,"key":"appjoin:Comment:id2","ttl":-1,"type":"hash","value":{"body":"body 2","article_id":"id2"},...}
...
{"db":0,"key":"appjoin:Article:id1","ttl":-1,"type":"hash","value":{"title":"title 1","user_id":"id1"},...}
{"db":0,"key":"appjoin:Article:id2","ttl":-1,"type":"hash","value":{"title":"title 2","user_id":"id2"},...}
...
{"db":0,"key":"appjoin:User:id1","ttl":-1,"type":"hash","value":{"name":"user 1"}, ...}
{"db":0,"key":"appjoin:User:id2","ttl":-1,"type":"hash","value":{"name":"user 2"}, ...}
```

Comment, Article and User records will be returned like this.  

```ruby
# comment
<OpenStruct article_id="id1", body="body 1", id="id1">
# article
<OpenStruct user_id="id1", title="title 1", id="id1">
# user
<OpenStruct name="user 1", id="id1">
```

You can do `article.title` and `user = fetch_records(record_class: 'User', record_ids: [article.user_id]).first`.

### TODO:

Write tests

Default TTL of 1.week

Support JSON structures in caching (getting data from API), not just ActiveModels

Support non-string fields.  For example, if your DB supports array fields you cannot store those attributes in Redis hash values.  

Methods to fetch associated records so we can do `article.user.name` from Redis cache.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dmitrypol/redis_app_join.
