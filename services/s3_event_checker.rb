class S3EventChecker
  S3_BUCKET = 'colinscalendlybucket'
  ACCESS = Rails.application.secrets['access']
  SECRET = Rails.application.secrets['secret']
  ENV['AWS_REGION'] = Rails.application.secrets['region']

  class << self
    def s3_client
      Aws.config[:credentials] = Aws::Credentials.new(ACCESS, SECRET)
      Aws::S3::Client.new
    end

    def take_events
      begin
        events.each do |event|
          delete_event(event[:key]) if save_event(event[:payload])
        end
      rescue 
        puts 'failed to get events from S3, aborting'
      end
    end

    def events 
      contents = s3_client.list_objects(bucket: S3_BUCKET)[:contents]
      object_keys = contents.map(&:key)

      object_keys.each_with_object([]) do |key, acc|
        acc << 
        { payload: s3_client.get_object(bucket: S3_BUCKET, key: key),
          key: key }
      end
    end

    def delete_event(key)
      s3_client.delete_object(bucket: S3_BUCKET, key: key)
    end

    def save_event(payload)
      Event.create(payload: payload)
    end
  end
end
