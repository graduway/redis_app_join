require "redis_app_join/version"

module RedisAppJoin

  def cache_records(records:)
    records.each do |record|
      key = [record.class.name, record.id.to_s].join(':')
      data = record.attributes.except(:_id, :id)
      REDIS_APP_JOIN.mapped_hmset(key, data)
    end
  end

  def delete_records(records:)
    records.each do |record|
      key = [record.class.name, record.id.to_s].join(':')
      REDIS_APP_JOIN.del(key)
    end
  end

  def fetch_records(record_class:, record_ids:)
    output = []
    record_ids.each do |record_id|
      key = [record_class.titleize, record_id.to_s].join(':')
      data = REDIS_APP_JOIN.hgetall(key)
      # => add the key as ID attribute
      output << OpenStruct.new(data.merge(id: record_id.to_s))
    end
    return output
  end

  def fetch_records_field(record_class:, record_ids:, field:)
    output = []
    record_ids.each do |record_id|
      key = [record_class.titleize, record_id.to_s].join(':')
      data = REDIS_APP_JOIN.hget(key, field)
      output << data
    end
    return output
  end

end
