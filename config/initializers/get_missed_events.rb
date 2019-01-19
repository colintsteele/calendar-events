require 'aws-sdk-s3'
require 'pry'

class S3EventChecker < Rails::Application
  S3_BUCKET = 'colinscalendlybucket'
  ACCESS = Rails.application.secrets['access']
  SECRET = Rails.application.secrets['secret']
  ENV['AWS_REGION'] = 'us-east-1'

  config.before_initialize do
    Aws.config[:credentials] = Aws::Credentials.new(ACCESS, SECRET)
    s3 = Aws::S3::Client.new

    object_keys = s3.list_objects(bucket: S3_BUCKET)[:contents].map(&:key)

    object_keys.each do |key|
      event = s3.get_object(bucket: S3_BUCKET, key: key).body.read
      event_created = Event.create(payload: event)
      s3.delete_object(bucket: S3_BUCKET, key: key) if event_created
    end
  end
end
