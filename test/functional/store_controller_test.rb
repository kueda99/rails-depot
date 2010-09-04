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
end
