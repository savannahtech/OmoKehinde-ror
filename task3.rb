
# Enforce the check for quota to ensure quota isn't exceeded by each user
class ApplicationController < ActionController::API
  before_action :user_quota

  QUOTA_LIMIT = 10_000

  def user_quota
    if current_user.exceeds_quota?
      render json: { error: 'over quota' }
    end
  end
end

# Modify the User object to contains a property to check if quota is exceeded 

class User < ApplicationRecord
  has_many :hits

  def exceeds_quota?
    total_hits >= QUOTA_LIMIT
  end

  private

  def total_hits
    start_of_month = Time.now.utc.beginning_of_month
    hits.where('created_at >= ?', start_of_month).count
  end
end

  