require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_selector "h1", text: "Events"
  end

  test "should create event" do
    visit events_url
    click_on "New event"

    fill_in "Category", with: @event.category
    fill_in "End date", with: @event.end_date
    fill_in "Highlight", with: @event.highlight
    fill_in "Location", with: @event.location
    fill_in "Remarks", with: @event.remarks
    fill_in "Start date", with: @event.start_date
    fill_in "Subtitle", with: @event.subtitle
    fill_in "Title", with: @event.title
    click_on "Create Event"

    assert_text "Event was successfully created"
    click_on "Back"
  end

  test "should update Event" do
    visit event_url(@event)
    click_on "Edit this event", match: :first

    fill_in "Category", with: @event.category
    fill_in "End date", with: @event.end_date
    fill_in "Highlight", with: @event.highlight
    fill_in "Location", with: @event.location
    fill_in "Remarks", with: @event.remarks
    fill_in "Start date", with: @event.start_date
    fill_in "Subtitle", with: @event.subtitle
    fill_in "Title", with: @event.title
    click_on "Update Event"

    assert_text "Event was successfully updated"
    click_on "Back"
  end

  test "should destroy Event" do
    visit event_url(@event)
    click_on "Destroy this event", match: :first

    assert_text "Event was successfully destroyed"
  end
end
