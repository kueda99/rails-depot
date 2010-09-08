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


  # カートの show の URL に、存在していない id を指定した場合、ストアの
  # ページに転送されることを確認するテスト。
  test "should redirect to store url if no cart is found" do
    fault_id = 666
    assert !Cart.exists?(fault_id)
    get :show, :id => fault_id
    assert_redirected_to store_path
  end


  # リソースがネストされている URL によってカートの中身をさせたとき (そ
  # のカートに入っているラインアイテムの一覧が表示される)、ラインアイテ
  # ムの Edit および Destroy のリンクがリソースのネストになっているかの
  # 確認
  test "links for editing and destroying line items should be nested" do
    get :show, :id => @cart.to_param
    assert_response :success
    assert_select "a[href=?]", %r{/carts/#{@cart.to_param}/line_items/[0-9]+/edit}, 'Edit'
    assert_select "a[href=?]", %r{/carts/#{@cart.to_param}/line_items/[0-9]+}, 'Destroy'
  end

end
