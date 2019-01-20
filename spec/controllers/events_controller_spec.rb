require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:sample) { File.read(Rails.root.join('test/fixtures/files/sample.json')) }

  context 'GET index' do
    it 'renders nothing when there are no events' do
      get :index
      expect(response).to render_template("index")
    end

  end
  context 'POST events' do
    it 'saves a parsable json to params' do
      post :create, params: JSON.parse(sample)
      expect(Event.last.parsed_payload).to be_a(Hash)
    end
  end
end
