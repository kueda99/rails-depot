# -*- coding: utf-8 -*-
require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  setup do
    @cart = carts(:cart_with_two_items)
    @another_cart = carts(:another_cart)
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
    switch_to_customer_mode

    @request.session[:cart_id] = @cart.to_param
    get :show, :id => @cart.to_param
    assert_response :success
    # カートに入っているラインアイテムの個数 + ヘッダ
    assert_select 'table > tr', @cart.line_items.count + 1
  end

  test "should get edit" do
    switch_to_customer_mode

    @request.session[:cart_id] = @cart.to_param
    get :edit, :id => @cart.to_param
    assert_response :success
  end

  test "should update cart in customer mode" do
    params_arg = {:id => @cart.to_param, :cart => @cart.attributes}

    # カート id について params[] と session[] が同じ
    put :update, params_arg, {:cart_id => @cart.to_param}
    assert_redirected_to cart_path(assigns(:cart))

    # カート id について params[] には値が入っているが、session[] には
    # ない。顧客モードでは、ストアページにリダイレクトされる。
    put :update, params_arg, {:cart_id => nil}
    assert_redirected_to store_path

    # カート id について params[] と session[] が一致しない。すなわち顧
    # 客モードで他のカートをアップデートしようとする。その場合はストア
    # ページにリダイレクトされる。
    put :update, params_arg, {:cart_id => @another_cart.to_param}
    assert_redirected_to store_path
  end

#  test "should update cart in admin mode" do
#    switch_to_admin_mode
#    put :update, :id => @cart.to_param, :cart => @cart.attributes
#    assert_redirected_to cart_path(assigns(:cart))
#  end

  test "should destroy cart" do
    switch_to_customer_mode

    @request.session[:cart_id] = @cart.to_param
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
    switch_to_customer_mode

    @request.session[:cart_id] = @cart.to_param
    get :show, :id => @cart.to_param
    assert_response :success
    assert_select "a[href=?]", %r{/carts/#{@cart.to_param}/line_items/[0-9]+/edit}, 'Edit'
    assert_select "a[href=?]", %r{/carts/#{@cart.to_param}/line_items/[0-9]+}, 'Destroy'
  end


  # セッションに記録された cart_id と、URL で指定した cart_id が一致し
  # ない場合、セッションに記録された cart の内容一覧ページに移動する。
  # ただし、管理者でない場合のみ。
  test "discrepancy of cart ids should redirect to store page" do
    # 「顧客モード」
    session = {:user_id => nil}

    # カート id について params[] と session[] が同じ
    get :show, {:id => @cart}, session.merge(:cart_id => @cart.id)
    assert_response :success

    # カート id について params[] と session[] が違う。おまけに
    # params[] で指定した id を持つカートは存在していない。
    get :show, {:id => 666}, session.merge(:cart_id => @cart.id)
    assert_redirected_to store_url

    # カート id について params[] には値が入っているが、session[] にはない。
    get :show, {:id => @cart}, session.merge(:cart_id => nil)
    assert_redirected_to store_path
  end

  # 管理者は、セッションに記録された cart_id と、URL で指定した
  # cart_id が一致しない場合、セッションに記録された cart の内容一覧ペー
  # ジに移動されない。
  test "being in admin mode, discrepancy of cart ids should not redirect to store page" do
    # 「管理者モード」にする
    session = {:user_id => 1234}

    # カート id が params[] と session[] とで同じ
    get :show, {:id => @cart}, session.merge(:cart_id => @cart.id)
    assert_response :success

    # カートが存在していないときは、管理者モードの場合でもストアページ
    # にリダイレクトされる
    #    @request.session[:cart_id] = @cart.id
    get :show, {:id => 666}, session.merge(:cart_id => @cart.id)
    assert_redirected_to store_path

    # session[] にカート id が入っていなくても、params[] で指定されてい
    # れば、カートのページを表示させる。
    get :show, {:id => @cart}, session.merge(:cart_id => nil)
    assert_response :success
  end

end
