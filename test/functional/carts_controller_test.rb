# -*- coding: utf-8 -*-
require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  setup do
    @cart = carts(:cart_with_two_items)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:carts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cart" do
    assert_difference('Cart.count') do
      post :create, :cart => @cart.attributes
    end

    assert_redirected_to cart_path(assigns(:cart))
  end

  test "should show cart" do
    get :show, :id => @cart.to_param
    assert_response :success
    # カートに入っているラインアイテムの個数 + ヘッダ
    assert_select 'table > tr', @cart.line_items.count + 1
  end

  test "should get edit" do
    get :edit, :id => @cart.to_param
    assert_response :success
  end

  test "should update cart" do
    put :update, :id => @cart.to_param, :cart => @cart.attributes
    assert_redirected_to cart_path(assigns(:cart))
  end

  test "should destroy cart" do
    assert_difference('Cart.count', -1) do
      delete :destroy, :id => @cart.to_param
    end

    assert_redirected_to carts_path
  end
end
