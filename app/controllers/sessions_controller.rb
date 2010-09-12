class SessionsController < ApplicationController
  def switch_to_customer
    session[:user_id] = nil
    redirect_to :back
  end

  def switch_to_admin
    session[:user_id] = 1234
    redirect_to :back
  end

end
