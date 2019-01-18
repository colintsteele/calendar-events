class Event < ActiveRecord::Base
  def parsed_payload
    JSON.parse(payload)['payload']
  end

  def details
    p = parsed_payload
    {
      type: p['event_type']['kind'],
      duration: p['event_type']['duration']
    }
  end
end
