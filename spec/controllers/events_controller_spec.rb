require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  context 'GET index' do
    it 'renders nothing when there are no events' do
      get :index
      expect(response).to render_template("index")
    end
  end
end
