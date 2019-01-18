class EventsController < ActionController::Base 
  skip_before_action :verify_authenticity_token 
  def index
    @event = Event.first
  end

  def create
    Event.create(payload: params.to_json)
  end
end
