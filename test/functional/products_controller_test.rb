# -*- coding: utf-8 -*-
require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = products(:one)
    @product_not_in_any_cart = products(:not_in_any_cart)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product" do
    attributes = @product.attributes
    attributes.update({"title" => attributes["title"] + "2"})

    assert_difference('Product.count') do
      post :create, :product => attributes
    end

    assert_redirected_to product_url(assigns(:product))
  end

  test "should show product" do
    get :show, :id => @product.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @product.to_param
    assert_response :success
  end

  test "should update product" do
    put :update, :id => @product.to_param, :product => @product.attributes
    assert_redirected_to product_url(assigns(:product))
  end

  test "should destroy product which is not associated with any line items" do
    assert_difference('Product.count', -1) do
      delete :destroy, :id => @product_not_in_any_cart.to_param
    end

    assert_redirected_to products_url
  end

  test "should not destroy product which is associated with any line items" do
    assert_no_difference('Product.count') do
      delete :destroy, :id => @product.to_param
    end

    assert_redirected_to products_url
  end

  test "should get index having proper layout" do
    get_args = [[:index], [:new],
                [:show, {:id => @product.to_param}],
                [:edit, {:id => @product.to_param}]]

    get_args.each do |args|
      get *args
      assert_application_layout
    end

    # post, put, delete を実行したときにレイアウトが表示されるテストは
    # 行う意味がない。すなわち、これらを実行したときは /products または
    # /products/:id にリダイレクトされることを上記テストで確認している
    # ので、:index および :show にてレイアウトが表示されることを確認す
    # るだけで十分である。
  end

  test "should show price with denomination" do
    get :show, :id => @product.to_param
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
