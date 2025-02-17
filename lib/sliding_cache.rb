# frozen_string_literal: true

module SlidingCache
  EXPIRY_TIME = 1.hour
  def self.fetch(key, expiry: EXPIRY_TIME, &block)
    key = "mp_#{Digest::SHA1.hexdigest(key)}"
    begin
      RedisClient.multi do |pipeline|
        data = RedisClient.get(key)
        if data
          pipeline.expire(key, expiry)
          return Marshal.load(data)
        end

        result = yield
        pipeline.setex(key, expiry, Marshal.dump(result))
        return result
      end
    rescue => e
      Rails.logger.error("SlidingCache error: #{e.message}")
      yield
    end
  end
end
