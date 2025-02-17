# frozen_string_literal: true

require "redis"

RedisClient = Redis.new(url: ENV.fetch("REDIS_URL", "redis://redis:6379/1"))
