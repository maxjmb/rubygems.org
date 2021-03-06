class SessionsController < Clearance::SessionsController
  ssl_required

  def create
    @user = User.authenticate(params[:session][:who],
                              params[:session][:password])
    sign_in(@user) do |status|
      if status.success?
        Librato.increment 'login.success'
        cookies[:ssl] = true
        redirect_back_or(url_after_create)
      else
        Librato.increment 'login.failure'
        flash.now.notice = status.failure_message
        render :template => 'sessions/new', :status => :unauthorized
      end
    end
  end

  def destroy
    cookies.delete(:ssl)
    super
  end

  private

  def url_after_create
    dashboard_url
  end
end
