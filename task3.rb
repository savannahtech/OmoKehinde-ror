# It can be possible when users make request that bypasses the cache



class ApplicationController < ActionController::API
    before_filter :user_quota
  
    def user_quota
      cached_count = current_user.count_hits
      uncached_count = current_user.hits.where('created_at >= ?', 
            Time.now.beginning_of_month).count
      total_count = cached_count + uncached_count
  
      if total_count >= 10000
        render json: { error: 'over quota' }
      end
    end
  end
  