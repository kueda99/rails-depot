# -*- coding: utf-8 -*-
require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase
  setup do
    @line_item = line_items(:li_one)
    @new_line_item = line_items(:li_not_in_a_cart)
    @line_item_in_another_cart = line_items(:li_in_another_cart)
    @cart = carts(:cart_with_two_items)
    session[:cart_id] = @cart.id
  end

  test "cart_id should exist in 'session' hash" do
    get :index
    assert_not_nil session[:cart_id]
    assert_equal 2, Cart.find(session[:cart_id]).line_items.count
    assert_equal 2, @cart.line_items.count    # 駄目押し
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:line_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create line_item" do
    assert_difference('LineItem.count') do
      post :create, :line_item => @new_line_item.attributes
    end

    # ちゃんとカートの中に入ったか
    assert_equal @cart.id, @new_line_item.cart.id
    assert_redirected_to line_item_path(assigns(:line_item))
  end

  test "should show line_item" do
    get :show, :id => @line_item.to_param
    assert_response :success
  end

  # 他のカートに入っているラインアイテムを表示しようとしても、「そんな
  # のないよ」と表示される (実際にはデータベースにある)。
  test "should not show line_item in another cart" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, :id => @line_item_in_another_cart.to_param
    end
  end

  test "should get edit" do
    get :edit, :id => @line_item.to_param
    assert_response :success
  end

  # 他のカートに入っているラインアイテムを表示しようとしても、「そんな
  # のないよ」と表示される (実際にはデータベースにある)。
  test "should not get edit for line_item in another cart" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :edit, :id => @line_item_in_another_cart.to_param
    end
  end

  test "should update line_item" do
    put :update, :id => @line_item.to_param, :line_item => @line_item.attributes
    assert_redirected_to line_item_path(assigns(:line_item))
  end

  test "should not update line_item in another cart" do
    flunk(message="Test not implemented")
  end

  test "should destroy line_item" do
    assert_difference('LineItem.count', -1) do
      delete :destroy, :id => @line_item.to_param
    end

    assert_redirected_to line_items_path
  end

  test "should not destroy line_item in another cart" do
    flunk(message="Test not implemented")
  end

end
