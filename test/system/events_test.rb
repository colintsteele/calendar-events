require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    sample = File.read(Rails.root.join('test/fixtures/files/sample.json')) 
    @event = Event.create(payload: sample)
  end

  test "visiting the index" do
    visit events_url
  
    assert_selector "div", text: "One-on-One"
  end
end
