require 'mechanize'

module ATND
  EVENT_USERS_URI = "http://api.atnd.org/events/users/"
  def self.event_members(event_id)
    agent = Mechanize.new
    res = agent.get(EVENT_USERS_URI + "?event_id=#{event_id}")
    res.search("user/twitter_id").map do |tw_id|
      yield(tw_id.text) if block_given?
      tw_id.text
    end
  end
end

