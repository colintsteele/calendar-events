require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @sample = File.read(Rails.root.join('test/fixtures/files/sample.json')) 
    @event = Event.create(payload: @sample)
  end

  test 'visiting the index' do
    visit events_url
  
    assert_selector "div", text: "One-on-One"
  end

  test 'renders the newest events at the top' do
    Event.create(payload: @sample.gsub('One-on-One', 'old_event'))
    Event.create(payload: @sample.gsub('One-on-One', 'new_event'))

    visit events_url
    new_event_text = page.all('div', class: 'event').first.text
    assert_match(/new_event/, new_event_text)
  end

  test 'renders events in real time' do
    visit events_url
    assert_no_match(/new_event/, page.all('div', class: 'event').map(&:text).join)
    EventsController.new.notify(Event.create(payload: @sample.gsub('One-on-One', 'new_event')))
    assert_match(/new_event/, page.find('div', text: 'new_event', class: 'event').text)
  end
end
