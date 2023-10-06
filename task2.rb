
# The "over quota" issue experience by users in Australia is likely caused by the time 
# zone difference when resetting the quota at the beginning of each month. The fix to it is 
# to UTC time by calling .utc on Time.now in line 10

class User < ApplicationRecord
    has_many :hits
  
    def count_hits
      start_of_month = Time.now.utc.beginning_of_month
      cache_key = "user_#{id}_hits_#{start_of_month_utc.to_i}"
  
      cached_hits = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        hits.where('created_at > ?', start_of_month).count
      end
  
      return cached_hits
    end
  end
  