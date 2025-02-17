# spec/lib/sliding_cache_spec.rb
require 'rails_helper'

RSpec.describe SlidingCache do
  describe '.fetch' do
    let(:original_key) { 'test_key' }
    let(:hashed_key) { "mp_#{Digest::SHA1.hexdigest(original_key)}" }
    let(:expiry) { 1.hour }
    let(:block_result) { 'computed value' }
    let(:pipeline) { double('pipeline') }

    before do
      # By default, have RedisClient.multi yield the pipeline.
      allow(RedisClient).to receive(:multi).and_yield(pipeline)
    end

    context 'when the cache is hit' do
      let(:cached_value) { block_result }

      before do
        # Simulate a cache hit by returning a Marshaled value
        allow(RedisClient).to receive(:get).with(hashed_key)
          .and_return(Marshal.dump(cached_value))
      end

      it 'returns the cached value and refreshes the expiry' do
        # Expect the pipeline to refresh the expiry on the key.
        expect(pipeline).to receive(:expire).with(hashed_key, expiry)

        block_called = false
        result = described_class.fetch(original_key, expiry: expiry) do
          block_called = true
          # If the block is called on a cache hit, that's an error.
          raise 'Block should not be executed on cache hit'
        end

        expect(result).to eq(cached_value)
        expect(block_called).to be false
      end
    end

    context 'when the cache is missed' do
      before do
        # Simulate a cache miss by returning nil
        allow(RedisClient).to receive(:get).with(hashed_key)
          .and_return(nil)
      end

      it 'executes the block, caches its result, and returns the result' do
        # Expect the pipeline to cache the result with setex.
        expect(pipeline).to receive(:setex)
          .with(hashed_key, expiry, Marshal.dump(block_result))

        result = described_class.fetch(original_key, expiry: expiry) { block_result }
        expect(result).to eq(block_result)
      end
    end

    context 'when an exception occurs during caching' do
      let(:error) { StandardError.new('redis error') }

      before do
        # Simulate an exception occurring inside RedisClient.multi.
        allow(RedisClient).to receive(:multi).and_raise(error)
        # Stub the Rails logger to expect an error message.
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and executes the block' do
        expect(Rails.logger).to receive(:error)
          .with("SlidingCache error: #{error.message}")

        # The block should be executed and its value returned.
        result = described_class.fetch(original_key, expiry: expiry) { block_result }
        expect(result).to eq(block_result)
      end
    end
  end
end
