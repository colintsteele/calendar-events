class Event < ActiveRecord::Base
  after_initialize :set_canceled

  def set_canceled
    self.canceled = true if payload.match?(/canceled\".true/)
    self.save
  end

  def parsed_payload
    JSON.parse(payload)['payload']
  end

  def details
    p = parsed_payload
    {
      type: p['event_type']['kind'],
      invitee: p['invitee']['name'],
      event_time: p['event']['start_time_pretty'],
      duration: p['event_type']['name']
    }
  end
end
