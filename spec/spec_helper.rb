$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'redis_app_join'
require 'rspec/active_model/mocks'
require 'byebug'
require 'mock_redis'
require 'net/http'

REDIS_APP_JOIN = Redis::Namespace.new(:appjoin, redis: MockRedis.new )
#REDIS_APP_JOIN = Redis::Namespace.new(:appjoin, redis: Redis.new )
REDIS_APP_JOIN_BATCH = 1
