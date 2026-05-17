class NotificationsController < ApplicationController
  before_action :require_login

  def read
    @notification = current_user.notifications.find_by(id: params[:id])
    if @notification
      @notification.mark_as_read!
      redirect_to @notification.url.presence || root_path
    else
      redirect_back fallback_location: root_path
    end
  end
end
