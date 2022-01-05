# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  before_action :check_registrations_open_or_valid_invite!, except: :registrations_closed
  before_action :configure_sign_up_params, only: [:create]
  layout -> { request.format == :mobile ? "application" : "with_header_with_footer" }

  def create
    build_resource(sign_up_params)
    raise unless resource.check_and_verify_captcha?
    super
    if resource.persisted?
      resource.process_invite_acceptence(invite) if invite.present?
      resource.seed_aspects
    end
  rescue
    resource.errors.delete(:person)
    flash.now[:error] = resource.errors.full_messages.join(" - ")
    logger.info "event=registration status=failure errors='#{resource.errors.full_messages.join(', ')}'"
    render action: "new"
  end

  def registrations_closed
    render "registrations/registrations_closed"
  end

  protected

  def build_resource(hash = nil)
    super(hash)
    return if hash.nil? # return for 'new'
    resource.language = hash[:language]
    resource.language ||= I18n.locale.to_s
    resource.color_theme = hash[:color_theme]
    resource.color_theme ||= AppConfig.settings.default_color_theme
    resource.set_person(Person.new((hash[:person] || {}).except(:id)))
    resource.generate_keys
    resource.valid?
    errors = resource.errors
    errors.delete :person
    return if errors.size > 0
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :getting_started, :password, :password_confirmation, :language, :disable_mail, :show_community_spotlight_in_stream, :auto_follow_back, :auto_follow_back_aspect_id, :remember_me, :captcha, :captcha_key])
  end

  def after_inactive_sign_up_path_for(_resource)
    login_path
  end

  private

  def check_registrations_open_or_valid_invite!
    return true if AppConfig.settings.enable_registrations? || invite.try(:can_be_used?)

    flash[:error] = t("registrations.invalid_invite") if params[:invite]
    redirect_to registrations_closed_path
  end

  def invite
    @invite ||= InvitationCode.find_by_token(params[:invite][:token]) if params[:invite].present?
  end

  helper_method :invite

end
