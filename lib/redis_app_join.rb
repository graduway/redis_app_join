require "redis_app_join/version"

module RedisAppJoin

  # will loop through records creating keys using combination of class and ID.
  # can combine different record types (Users and Articles) in the same method call
  # record's attributes will be hash fields
  #
  # @see https://github.com/dmitrypol/redis_app_join
  # @param records [Array] ActiveModels to cache
  def cache_records(records:)
    records.each do |record|
      key = [record.class.name, record.id.to_s].join(':')
      data = record.attributes.except(:_id, :id)
      REDIS_APP_JOIN.mapped_hmset(key, data)
    end
  end

  # used to delete cached records after the process is done
  # can combine different record types (Users and Articles) in the same method call
  #
  # @param records [Array] ActiveModels to delete
  def delete_records(records:)
    records.each do |record|
      key = [record.class.name, record.id.to_s].join(':')
      REDIS_APP_JOIN.del(key)
    end
  end

  # fetch recors from cache,
  # cannot combine different record types (Users and Articles) in the same method call
  #
  # @param record_class [String] - name of class, used in lookup
  # @param record_ids [Array] array of IDs to lookup
  # @return [Array] array of objects and include the original record ID as one of the attributes for each object.
  def fetch_records(record_class:, record_ids:)
    output = []
    record_ids.each do |record_id|
      key = [record_class, record_id.to_s].join(':')
      data = REDIS_APP_JOIN.hgetall(key)
      # => add the key as ID attribute
      output << OpenStruct.new(data.merge(id: record_id.to_s))
    end
    return output
  end

  # retrieves specific field for an array or records (all user_ids for articles)
  # only returns the field if it's present
  # cannot combine different record types in the same method call
  #
  # @param record_class [String] - name of class, used in lookup
  # @param record_ids [Array] array of IDs to lookup
  # @param field [String] name of field/attribute to retrieve
  # @return [Array] array of unique strings
  def fetch_records_field(record_class:, record_ids:, field:)
    output = []
    record_ids.each do |record_id|
      key = [record_class, record_id.to_s].join(':')
      data = REDIS_APP_JOIN.hget(key, field)
      output << data
    end
    return output.uniq
  end

end
