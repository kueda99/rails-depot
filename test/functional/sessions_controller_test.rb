require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @request.env["HTTP_REFERER"] = "http://localhost:3000/line_items/30"
  end

  test "should get switch_to_customer" do
    @request.session[:user_id] = 1234
    get :switch_to_customer
    assert_nil @request.session[:user_id]
  end

  test "should get switch_to_admin" do
    @request.session[:user_id] = nil
    get :switch_to_admin
    assert_not_nil @request.session[:user_id]
  end

end
