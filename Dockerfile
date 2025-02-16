# Use an official Ruby runtime as a parent image
FROM ruby:3.4.2

# Install dependencies:
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set environment variables
ENV RAILS_ENV=development
ENV RACK_ENV=development

# Create and set working directory
WORKDIR /around_home

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy the rest of the application code
COPY . .

# Precompile assets (optional for API–only apps, but leave for future expansion)
# RUN bundle exec rake assets:precompile

# Expose port 3000 to the Docker host
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
