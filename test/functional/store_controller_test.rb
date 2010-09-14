# -*- coding: utf-8 -*-
require 'test_helper'

class StoreControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  # すべての製品 (タグが entry クラス) について、price_line クラスのタ
  # グがあり、画像へのソースタグを持っていることをテストする。
  test "should get index contains 3 entries with expected tags" do
    get :index
    assert_select 'div.entry' do |elements|
      elements.each do |element|
        assert_select element, 'div.price_line'
        assert_select element, %{img[src=?]}, /.*\.(gif|jpg|png).*/i
      end
    end
  end

  test "should get index having proper layout" do
    get :index
    assert_application_layout
  end

  test "should show price with denomination" do
    get :index
    assert_select '.price', /\$[,\d]+\.\d\d/
  end


  #
  # 管理者モードか顧客モードかによって layouts/application.html.erb の
  # 内容が変わることを確認する
  #
  test "columns tag should have the value of class which depends on the mode" do
    # 管理者モードでアクセス
    get :index, nil, {:user_id => 1234}
    assert_response :success
    assert_select "#columns[class=?]", 'admin'
    assert_select "#side[class=?]", 'admin'

    # 顧客モードでアクセス
    get :index, nil, {:user_id => nil}
    assert_response :success
    assert_select "#columns[class=?]", 'customer'
    assert_select "#side[class=?]", 'customer'
  end

  test "should be able to switch between admin and customer mode" do
    # 管理者モードでアクセス
    get :index, nil, {:user_id => 1234}
    assert_response :success
    assert_select "#side a[href=?]", '/sessions/switch_to_customer'

    # 顧客モードでアクセス
    get :index, nil, {:user_id => nil}
    assert_response :success
    assert_select "#side a[href=?]", '/sessions/switch_to_admin'
  end
end
