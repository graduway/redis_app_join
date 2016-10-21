require "redis_app_join/version"
require "redis"
require "redis-namespace"
require "readthis"
#require "active_support/concern"

module RedisAppJoin

  # => default of 1 week
  REDIS_APP_JOIN_TTL = 60*60*24*7
  # => default batch size for Redis pipelining when caching records
  REDIS_APP_JOIN_BATCH = 100

  # will loop through records creating keys using combination of class and ID.
  # can combine different record types (Users and Articles) in the same method call unless passing hashes
  # record's attributes will be hash fields
  #
  # @see https://github.com/dmitrypol/redis_app_join
  # @param records [Array] ActiveModels to cache
  # @param record_class [String] name of class, used when records are NOT ActiveModel
  # @raise [RuntimeError] if record is missing ID
  def cache_records(records:, record_class: nil)
    records.each_slice(REDIS_APP_JOIN_BATCH) do |batch|
      REDIS_APP_JOIN.pipelined do
        batch.each do |record|
          key = get_key_for_record(record: record, record_class: record_class)
          if record.is_a?(Hash)
            data = record
          else
            data = record.attributes
          end
          REDIS_APP_JOIN.mapped_hmset(key, data.except(:_id, :id))
          REDIS_APP_JOIN.expire(key, REDIS_APP_JOIN_TTL) unless REDIS_APP_JOIN_TTL == -1
        end
      end
    end
  end

  # used to delete cached records after the process is done
  # can combine different record types (Users and Articles) in the same method call unless passing hashes
  #
  # @param records [Array] ActiveModels to delete
  # @param record_class [String] name of class, used when records are NOT ActiveModel
  def delete_records(records:, record_class: nil)
    records.each do |record|
      key = get_key_for_record(record: record, record_class: record_class)
      REDIS_APP_JOIN.del(key)
    end
  end

  # fetch records from cache,
  # cannot combine different record types (Users and Articles) in the same method call
  #
  # @param record_class [String] name of class, used in lookup
  # @param record_ids [Array] array of IDs to lookup
  # @return [Array] array of objects and include the original record ID as one of the attributes for each object.
  def fetch_records(record_class:, record_ids:)
    output = []
    record_ids.each do |record_id|
      key = get_key_for_record_id(record_id: record_id, record_class: record_class)
      data = REDIS_APP_JOIN.hgetall(key)
      # => add the key as ID attribute if there is data hash
      output << OpenStruct.new(data.merge(id: record_id.to_s)) if data.size > 0
    end
    return output
  end

  # retrieves specific field for an array or records (all user_ids for articles)
  # only returns the field if it's present
  # cannot combine different record types in the same method call
  #
  # @param record_class [String] name of class, used in lookup
  # @param record_ids [Array] array of IDs to lookup
  # @param field [String] name of field/attribute to retrieve
  # @return [Array] array of unique strings
  def fetch_records_field(record_class:, record_ids:, field:)
    output = []
    record_ids.each do |record_id|
      key = get_key_for_record_id(record_id: record_id, record_class: record_class)
      data = REDIS_APP_JOIN.hget(key, field)
      output << data if data # checks if nil
    end
    return output.uniq
  end

private

  # creates a key for specific record id and class
  #
  # @param record [Object]
  # @param record_class [String]
  # @return [String]
  def get_key_for_record (record:, record_class:)
    if record.is_a?(Hash)
      record_id = record[:id] || record[:_id]
    else
      record_id = record.id
    end
    raise RuntimeError, 'missing record_id' if record_id == nil
    record_class ||= record.class.name
    raise RuntimeError, 'missing record_class' if ['', nil, 'Hash'].include?(record_class)
    key = [record_class, record_id.to_s].join(':')
    return key
  end

  # @param record_id [String]
  # @param record_class [String]
  # @return [String]
  def get_key_for_record_id (record_id:, record_class:)
    raise RuntimeError, 'missing record_id' if record_id == nil
    raise RuntimeError, 'missing record_class' if ['', nil, 'Hash'].include?(record_class)
    key = [record_class, record_id.to_s].join(':')
    return key
  end

end
