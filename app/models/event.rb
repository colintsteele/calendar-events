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
      duration: p['event_type']['duration'],
      uuid: p['event_type']['uuid']
    }
  end
end
