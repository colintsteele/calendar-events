require 'aws-sdk-s3'
require 'pry'
require Rails.root.join('services/s3_event_checker.rb')

Rails.application.config.before_initialize do
  S3EventChecker.take_events
end
