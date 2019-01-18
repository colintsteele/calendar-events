class EventsController < ActionController::Base 
  skip_before_action :verify_authenticity_token 
  def index
    @events = Event.last(20)
  end

  def create
    Event.create(payload: params.to_json)
  end
end
