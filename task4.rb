
# app/models/user.rb
class User < ApplicationRecord
    has_many :hits
  
    def count_hits
      start_of_month_utc = Time.now.utc.beginning_of_month
      cache_key = "user_#{id}_hits_#{start_of_month_utc.to_i}"
  
      cached_hits = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        hits.where('created_at > ?', start_of_month_utc).count
      end
  
      return cached_hits
    end
  
    def over_quota?
      total_hits >= QUOTA_LIMIT
    end
  
    private
  
    def total_hits
      cached_hits = count_hits
      uncached_hits = hits.where('created_at >= ?', Time.now.beginning_of_month).count
      cached_hits + uncached_hits
    end
  end

  # app/controllers/application_controller.rb
class ApplicationController < ActionController::API
    before_action :check_quota
  
    QUOTA_LIMIT = 10000
  
    def check_quota
      if current_user.over_quota?
        render json: { error: 'over quota' }
      end
    end
  end
  
  