require 'minitest_helper'
require "redis"
    
describe Oboe::Inst::Redis, :keys do
  attr_reader :entry_kvs, :exit_kvs, :redis

  def min_server_version(version)
    #unless (@redis.info["redis_version"] =~ /#{version}/) == 0
    unless Gem::Version.new(@redis.info["redis_version"]) >= Gem::Version.new(version.to_s)
      skip "supported only redis-server #{version}" 
    end
  end

  before do
    clear_all_traces 
    
    @redis ||= Redis.new

    @redis.info["redis_version"]

    # These are standard entry/exit KVs that are passed up with all moped operations
    @entry_kvs ||= { 'Layer' => 'redis_test', 'Label' => 'entry' }
    @exit_kvs  ||= { 'Layer' => 'redis_test', 'Label' => 'exit' }
  end

  it 'Stock Redis should be loaded, defined and ready' do
    defined?(::Redis).wont_match nil 
  end
  
  it "should trace hdel" do
    min_server_version(2.0)

    @redis.hset("whale", "color", "blue")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hdel("whale", "color")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hdel"
    traces[1]['KVKey'].must_equal "whale"
    traces[1]['field'].must_equal "color"
  end
  
  it "should trace hdel multiple fields" do
    min_server_version(2.4)

    @redis.hset("whale", "color", "blue")
    @redis.hset("whale", "size", "big")
    @redis.hset("whale", "eyes", "green")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hdel("whale", ["color", "eyes"])
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hdel"
    traces[1]['KVKey'].must_equal "whale"
    traces[1]['field'].must_equal "color"
  end
  
  it "should trace hexists" do
    min_server_version(2.0)

    @redis.hset("whale", "color", "blue")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hexists("whale", "color")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hexists"
    traces[1]['KVKey'].must_equal "whale"
    traces[1]['field'].must_equal "color"
  end
  
  it "should trace hget" do
    min_server_version(2.0)

    @redis.hset("whale", "color", "blue")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hget("whale", "color")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hget"
    traces[1]['KVKey'].must_equal "whale"
    traces[1]['field'].must_equal "color"
  end
  
  it "should trace hgetall" do
    min_server_version(2.0)

    @redis.hset("whale", "color", "blue")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hgetall("whale")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hgetall"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hincrby" do
    min_server_version(2.0)

    @redis.hset("whale", "age", 32)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hincrby("whale", "age", 1)
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hincrby"
    traces[1]['KVKey'].must_equal "whale"
    traces[1]['field'].must_equal "age"
    traces[1]['increment'].must_equal "1"
  end
  
  it "should trace hincrbyfloat" do
    min_server_version(2.6)

    @redis.hset("whale", "age", 32)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hincrbyfloat("whale", "age", 1.3)
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hincrbyfloat"
    traces[1]['KVKey'].must_equal "whale"
    traces[1]['field'].must_equal "age"
    traces[1]['increment'].must_equal "1"
  end
  
  it "should trace hkeys" do
    min_server_version(2.0)

    @redis.hset("whale", "age", 32)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hkeys("whale")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hkeys"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hlen" do
    min_server_version(2.0)

    @redis.hset("whale", "age", 32)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hlen("whale")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hlen"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hmget" do
    min_server_version(2.0)

    @redis.hset("whale", "color", "blue")
    @redis.hset("whale", "size", "big")
    @redis.hset("whale", "eyes", "green")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hmget("whale", "color", "size")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hmget"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hmset" do
    min_server_version(2.0)

    @redis.hset("whale", "color", "blue")
    @redis.hset("whale", "size", "big")
    @redis.hset("whale", "eyes", "green")

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hmset("whale", ["color", "red", "size", "very big"])
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hmset"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hset" do
    min_server_version(2.0)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hset("whale", "eyes", "green")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hset"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hsetnx" do
    min_server_version(2.0)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hsetnx("whale", "eyes", "green")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hsetnx"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hvals" do
    min_server_version(2.0)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hvals("whale")
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hvals"
    traces[1]['KVKey'].must_equal "whale"
  end
  
  it "should trace hscan" do
    min_server_version(2.8)

    Oboe::API.start_trace('redis_test', '', {}) do
      @redis.hscan("whale", 0)
    end

    traces = get_all_traces
    traces.count.must_equal 4
    traces[1]['KVOp'].must_equal "hscan"
    traces[1]['KVKey'].must_equal "whale"
  end
end

