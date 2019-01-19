require 'rails_helper'

RSpec.describe S3EventChecker, type: :model do
  let(:objects) { [double(key: 'event1'), double(key: 'event2')] }
  let(:s3_client_stub) { double(list_objects: {contents: objects}) }
  before do
    S3EventChecker.stub(:s3_client).and_return(s3_client_stub)
  end

  context '#events' do
    it 'lists objects and retreives their contents' do
      expect(s3_client_stub).to receive(:get_object)
        .with({bucket: S3EventChecker::S3_BUCKET, key: 'event1'})
        .and_return('')
      expect(s3_client_stub).to receive(:get_object)
        .with({bucket: S3EventChecker::S3_BUCKET, key: 'event2'})
        .and_return('')

      S3EventChecker.events
    end
  end

  context '#take_events' do
    before do
      sample = File.read('test/fixtures/files/sample.json')
      S3EventChecker.stub(:events).and_return([payload: sample, key: 'event1'])
    end

    it 'should create a new event if none exists' do
      expect(s3_client_stub).to receive(:delete_object)
        .with({bucket: S3EventChecker::S3_BUCKET, key: 'event1'})
      S3EventChecker.take_events
    end

    it 'should not create a new event if one already exists' do
    end

    it 'should not delete the S3 object if a corresponding event is not saved' do
      Event.stub(:create).and_return(false)
      expect(s3_client_stub).not_to receive(:delete_object)
      S3EventChecker.take_events
    end
  end
end

