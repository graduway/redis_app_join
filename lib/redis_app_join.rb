require "redis_app_join/version"

module RedisAppJoin
  def cache_join_data record
  	key = [record.class.name, record.id.to_s].join(':')
  	data = []
  	REDIS_APP_JOIN.hmset(key, data)
  end
end
