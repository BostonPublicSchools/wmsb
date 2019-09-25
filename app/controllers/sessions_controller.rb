class SessionsController < ApplicationController
  before_filter :redirect_to_buses, only: :new

  def new
    @session = ContactId.new
  end

  def create
    @session = ContactId.new(params[:contact_id])
    if @session.valid? && @session.authenticate!
      session[:contact_id]   = @session.contact_id
      session[:signed_in_at] = Time.zone.now.to_s
      session[:current_assignment] = Digest::SHA512.hexdigest(@session.studentNo).first(20)
      session[:parentLastName] = @session.parentLastName
      session[:studentNo] = @session.studentNo
      cookies[:parentLastName] = {
          value: @session.parentLastName,
          expires: expire_cookie
      }
      cookies[:studentNo] = {
          value: @session.studentNo,
          expires: expire_cookie
      }
      cookies[:month] = {
          value: @session.studentDob.month,
          expires: expire_cookie
      }
      cookies[:date] = {
          value: @session.studentDob.day,
          expires: expire_cookie
      }
      cookies[:year] = {
          value: @session.studentDob.year,
          expires: expire_cookie
      }
      redirect_to buses_path(anchor: session[:current_assignment])

    else
      flash.now.alert = 'There was a problem signing you in.'
      render :new
    end
  end

  def destroy
    session.delete(:current_assignment)
    session.delete(:contact_id)
    session.delete(:signed_in_at)

    redirect_to root_path, notice: 'You have been logged out'
  end

  def expire_cookie
    9.months.from_now
  end

  private

  def redirect_to_buses
    if session_exists? && !session_expired?
      redirect_to buses_path(anchor: session[:current_assignment])
    end
  end
end
