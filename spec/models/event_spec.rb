require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) do
    sample = File.read(Rails.root.join('test/fixtures/files/sample.json')) 

    Event.create(payload: sample)
  end

  context '#parsed_payload' do
    it 'should return a hash of the event' do
      expect(event.parsed_payload).to be_a(Hash)
    end
  end

  context 'details' do
    it 'should return only a few elements' do
      expect(event.parsed_payload).not_to be_empty 
    end
  end
end
