# frozen_string_literal: true

module StructuredLogger
  def log_error(context, error, parameters = {})
    log_data = {
      context: context,
      error: error.message,
      parameters: parameters,
      timestamp: Time.now.utc.iso8601
    }
    Rails.logger.error(log_data.to_json)
  end

  def log_info(context, message, parameters = {})
    log_data = {
      context: context,
      message: message,
      parameters: parameters,
      timestamp: Time.now.utc.iso8601
    }
    Rails.logger.info(log_data.to_json)
  end
end
