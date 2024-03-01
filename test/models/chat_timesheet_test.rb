require "test_helper"

class ChatTimesheetTest < ActiveSupport::TestCase
  test "start_time is nil when client start is blank" do
    ts = ChatTimesheet.new(pro_start: Time.current, client_start: nil)
    assert_nil ts.start_time
  end

  test "start_time is nil when pro start is blank" do
    ts = ChatTimesheet.new(client_start: Time.current, pro_start: nil)
    assert_nil ts.start_time
  end

  test "start_time is the greater of pro and client starts" do
    ts = ChatTimesheet.new(client_start: 3.second.ago, pro_start: 2.seconds.ago)
    assert_equal ts.pro_start, ts.start_time

    ts = ChatTimesheet.new(client_start: 2.second.ago, pro_start: 3.seconds.ago)
    assert_equal ts.client_start, ts.start_time
  end
end
