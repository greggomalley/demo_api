module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_token
  end

  def find_session_by_token
    token = request.headers['Authorization']&.split(' ')&.last
    Session.find_by(token: token) if token
  end

  def request_authentication
    render json: { error: 'Authentication required' }, status: :unauthorized
  end

  def start_new_session_for(user)
    token = SecureRandom.hex(32)
    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      token: token
    ).tap do |session|
      Current.session = session
    end
  end

  def terminate_session
    Current.session&.destroy
  end
end