require 'spec_helper'

describe RedisAppJoin do

  include RedisAppJoin

  before(:each) do
    REDIS_APP_JOIN.flushdb
    @hash_records = [{id:1, name:'one'}, {id:2, name:'two'}]
    @hash_record_ids = @hash_records.map{ |r| r[:id] }
  end

  it 'has a version number' do
    expect(RedisAppJoin::VERSION).not_to be nil
  end

  context 'cache_records' do
    context 'valid' do
      after(:each) do
        expect(REDIS_APP_JOIN.dbsize).to eq 2
      end
      xit 'ActiveModel records' do
        records = [
          mock_model('User', id: 1, name: "Fred"),
          mock_model('User', id: 2, name: "Mary")
        ]
        cache_records(records: records)
      end
      it 'Hash records' do
        cache_records(records: @hash_records, record_class: 'User')
        expect(REDIS_APP_JOIN.dbsize).to eq 2
      end
    end
    context 'invalid' do
      after(:each) do
        expect(REDIS_APP_JOIN.dbsize).to eq 0
      end
      it 'Hash records, missing record_class' do
        expect{ cache_records(records: @hash_records) }.to raise_error(RuntimeError, 'missing record_class')
      end
      it 'missing ID' do
        expect{ cache_records(records: [{name:'one'}], record_class: 'User') }.to raise_error(RuntimeError, 'missing record_id')
      end
      it 'blank array' do
        cache_records(records: [])
      end
    end
    xit 'both valid and invalid records'
  end

  context 'delete_records' do
    before(:each) do
      cache_records(records: @hash_records, record_class: 'User')
    end
    it 'records found' do
      delete_records(records: @hash_records, record_class: 'User')
      expect(REDIS_APP_JOIN.dbsize).to eq 0
    end
    it 'records not found' do
      delete_records(records: @hash_records, record_class: 'User1')
      expect(REDIS_APP_JOIN.dbsize).to eq 2
    end
    it 'blank array' do
      delete_records(records: [])
      expect(REDIS_APP_JOIN.dbsize).to eq 2
    end
  end

  context 'fetch_records' do
    before(:each) do
      cache_records(records: @hash_records, record_class: 'User')
    end
    it 'records found' do
      test = fetch_records(record_class: 'User', record_ids: @hash_record_ids)
      expect(test.count).to eq 2
    end
    it 'records not found' do
      test = fetch_records(record_class: 'User', record_ids: [3, 4])
      expect(test.count).to eq 0
    end
    it 'blank array of record_ids' do
      test = fetch_records(record_class: nil, record_ids: [])
      expect(test.count).to eq 0
    end
  end

  context 'fetch_records_field' do
    before(:each) do
      cache_records(records: @hash_records, record_class: 'User')
    end
    it 'records found with field' do
      test = fetch_records_field(record_class: 'User', record_ids: @hash_record_ids, field: 'name')
      expect(test.count).to eq 2
    end
    xit 'field is found in some of the records' do
    end
    it 'records not found' do
      test = fetch_records_field(record_class: 'User', record_ids: [3, 4], field: 'name')
      expect(test.count).to eq 0
    end
    it 'field not found' do
      test = fetch_records_field(record_class: 'User', record_ids: @hash_record_ids, field: 'foo')
      expect(test.count).to eq 0
    end
    it 'blank input' do
      test = fetch_records_field(record_class: nil, record_ids: [], field: nil)
      expect(test.count).to eq 0
    end
  end

end
