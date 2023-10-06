

class User < ApplicationRecord
    has_many :hits
  
    def count_hits
      start_of_month = Time.now.beginning_of_month
      cache_key = "user_#{id}_hits_#{start_of_month.to_i}"
  
      # Fetch the hit count from cache
      cached_hits = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        hits.where('created_at > ?', start_of_month).count
      end
  
      return cached_hits
    end
  end
  