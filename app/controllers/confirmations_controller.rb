# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  before_action :require_unconfirmed!

  def new
    super

    resource.email = current_user.unconfirmed_email || current_user.email if user_signed_in?
  end

  private

  def require_unconfirmed!
    if user_signed_in? && current_user.confirmed? && current_user.unconfirmed_email.blank?
      redirect_to getting_started_path
    end
  end

  def after_confirmation_path_for(_resource_name, resource)
    sign_in(resource)
    getting_started_path
  end

  def after_resending_confirmation_instructions_path_for(_resource_name)
    login_path
  end

end
