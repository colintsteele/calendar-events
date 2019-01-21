class EventsController < ActionController::Base 
  skip_before_action :verify_authenticity_token 

  def index
    @events = Event.last(20).reverse
  end

  def create
    event = Event.create(payload: params.to_json)
    notify(event) if event
  end

  def notify(event)
    ActionCable.server.broadcast "event_notifications", {
      event: EventsController.render(
        partial: 'event',
        locals: { event: event }
      ).squish 
    }
  end
end
