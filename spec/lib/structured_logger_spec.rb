# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StructuredLogger do
  let(:dummy_class) { Class.new { extend StructuredLogger } } # Include module dynamically

  describe "#log_error" do
    it "logs structured error messages" do
      error = StandardError.new("Test error")
      parameters = { user_id: 123 }

      expect(Rails.logger).to receive(:error) do |log_message|
        parsed_log = JSON.parse(log_message, symbolize_names: true)
        expect(parsed_log[:context]).to eq("TestContext")
        expect(parsed_log[:error]).to eq("Test error")
        expect(parsed_log[:parameters]).to eq(parameters)
        expect(parsed_log).to have_key(:timestamp) # Ensure timestamp exists
      end

      dummy_class.log_error("TestContext", error, parameters)
    end
  end

  describe "#log_info" do
    it "logs structured info messages" do
      message = "This is an info log"
      parameters = { action: "create" }

      expect(Rails.logger).to receive(:info) do |log_message|
        parsed_log = JSON.parse(log_message, symbolize_names: true)
        expect(parsed_log[:context]).to eq("TestContext")
        expect(parsed_log[:message]).to eq(message)
        expect(parsed_log[:parameters]).to eq(parameters)
        expect(parsed_log).to have_key(:timestamp) # Ensure timestamp exists
      end

      dummy_class.log_info("TestContext", message, parameters)
    end
  end
end
