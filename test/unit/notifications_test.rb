require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  test "quote" do
    @expected.subject = 'Notifications#quote'
    @expected.body    = read_fixture('quote')
    @expected.date    = Time.now

    #assert_equal @expected.encoded, Notifications.create_quote(@expected.date).encoded
  end

end
