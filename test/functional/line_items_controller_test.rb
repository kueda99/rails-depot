# -*- coding: utf-8 -*-
require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase
  setup do
    @line_item = line_items(:li_one)
    @line_item_in_another_cart = line_items(:li_in_another_cart)
    @cart = carts(:cart_with_two_items)    # このカートに @line_item は入っている
    session[:cart_id] = @cart.id
    @product = products(:ruby)
  end

  # カートの中に 2 つの製品が入っていることの確認 (フィクスチャーのチェック)
  test "cart_id should exist in 'session' hash" do
    get :index
    assert_not_nil session[:cart_id]
    assert_equal 2, Cart.find(session[:cart_id]).line_items.count
    assert_equal 2, @cart.line_items.count    # 駄目押し
  end

  # 顧客モードでは自分のカートに入っている製品しかリストされない
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:line_items)
    assert_select "tr", 3    # テーブルのヘッダ (1) + フィクスチャーの個数 (2)
  end

  # 顧客モードでは、ラインアイテムがカートの下位にネストされている場合、
  # 自分のカートに入っている製品しかリストされない
  test "should get index of scoped line items" do
    get :index, :cart_id => @cart
    assert_response :success
    assert_not_nil assigns(:line_items)
    assert_select "tr", 3    # テーブルのヘッダ (1) + フィクスチャーの個数 (2)
  end

  # 管理者モードでは、ラインアイテムがカートの下位にネストされていない
  # 場合、すべての顧客がカートに入れている製品がリストされる
  test "should get index in admin mode" do
    get :index, nil, {:user_id => 1234}
    assert_response :success
    assert_not_nil assigns(:line_items)
    assert_select "tr", 4
  end

  # 管理者モードでは、ラインアイテムがカートの下位にネストがされている
  # 場合、そのカートに入っている製品がリストされる
  test "should get index of scoped line items in admni mode" do
    get :index, {:cart_id => @cart}, {:user_id => 1234}
    assert_response :success
    assert_select "tr", 3
  end

  test "should get new" do
    get :new
    assert_redirected_to store_url
  end

  test "should get new only if params[:product_id] is supplied" do
    get :new, :product_id => @product
    assert_response :success

    # フィールドのチェック (1 つしかフィールドがないということは、おそ
    # らく数量しか変更できなくなっている。それを確認する。
    assert_select "form > div.field", 1

    # リンクのチェック
    assert_select "form[action=?]", %r{/line_items}
    assert_select "input#line_item_product_id[value=?]", @product.id
    assert_select "a[href=?]", %r{/line_items}, 'Back'
  end

  test "should get redirected if invalid :product_id is supplied" do
    get :new, :product_id => 'foobar'
    assert_redirected_to store_url
  end

  # ラインアイテムを新規に作成した場合、自動的にカートに入ることの確認
  test "should create line_item" do
    cart_items_count = @cart.line_items.count
    product_items_count = products(:ruby).line_items.count

    assert_difference('LineItem.count') do
      post :create, :product_id => products(:ruby).id
    end

    # ちゃんとカートの中に入ったかの確認
    assert_equal cart_items_count + 1, @cart.line_items.count
    assert_equal product_items_count + 1, products(:ruby).line_items.count
    assert_redirected_to cart_url(@cart)
  end


  test "should show line_item" do
    get :show, :id => @line_item.to_param
    assert_response :success
    assert_select "a[href=?]", %r{/line_items/#{@line_item.to_param}/edit}, 'Edit'
    assert_select "a[href=?]", %r{/line_items}, 'Back'
  end


  # 他のカートに入っているラインアイテムを表示しようとしても、「そんな
  # のないよ」と表示される (実際にはデータベースにある)。
  test "should not show line_item in another cart" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, :id => @line_item_in_another_cart.to_param
    end
  end


  # ラインアイテムについて :edit した場合、もし自分のカートに入っている
  # 場合は情報を表示する。そうでないときは「そんなもの存在していない」
  # ように取り扱われる
  test "should get edit" do
    get :edit, :id => @line_item.to_param
    assert_response :success

    # フィールドのチェック (1 つしかフィールドがないということは、おそ
    # らく数量しか変更できなくなっている。それを確認する。
    assert_select "form > div.field", 1

    # リンクのチェック
    assert_select "form[action=?]", %r{/line_items/#{@line_item.to_param}}
    assert_select "input#line_item_product_id[value=?]", @line_item.product_id
    assert_select "a[href=?]", %r{/line_items/#{@line_item.to_param}}, 'Show'
    assert_select "a[href=?]", "/line_items", 'Back'
  end


  # 他のカートに入っているラインアイテムを表示しようとしても、「そんな
  # のないよ」と表示される (実際にはデータベースにある)。
  test "should not get edit for line_item in another cart" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :edit, :id => @line_item_in_another_cart.to_param
    end
  end


  # ラインアイテムについて :update した場合、もし自分のカートに入ってい
  # る場合は情報を表示する。そうでないときは「そんなもの存在していない」
  # ように取り扱われる

  test "should update line_item" do
    put :update, :id => @line_item.to_param, :line_item => @line_item.attributes
    assert_redirected_to cart_url(assigns(:line_item).cart)
  end

  test "should not update line_item in another cart" do
    assert_raise(ActiveRecord::RecordNotFound) do
      put :update, :id => @line_item_in_another_cart.to_param,
        :line_item => @line_item_in_another_cart.attributes
    end
  end

  # ラインアイテムについて、quantity が数字以外のものが入れられ
  # :update した場合、edit 画面に転送されることを確認する。
  test "should render edit if updated with bad value for quantity" do
    attributes = @line_item.attributes.update("quantity" => "666x")
    put :update, :id => @line_item.to_param, :line_item => attributes
    assert_response :success
    assert_template :edit, "should render edit template, given bad value for quantity"
    assert_select "#error_explanation li", 'Quantity is not a number'
  end



  # ラインアイテムについて :destroy した場合、もし自分のカートに入って
  # いる場合は情報を表示する。そうでないときは「そんなもの存在していな
  # い」ように取り扱われる

  test "should destroy line_item" do
    cart_id = @line_item.cart
    assert_difference('LineItem.count', -1) do
      delete :destroy, :id => @line_item.to_param
    end

    # LineItem インスタンス削除で 'GET /carts/:id' (show アクション) へ
    # リダイレクトされる (そこでは LineItem の一覧が表示される)。
    assert_redirected_to cart_url(cart_id)
  end

  test "should not destroy line_item in another cart" do
    assert_raise(ActiveRecord::RecordNotFound) do
      delete :destroy, :id => @line_item_in_another_cart.to_param
    end
  end


  # ラインアイテムの show 画面には Edit と Back のリンクがあり、それぞ
  # れネストしている。
  test "show for nested resource should have links to nested Edit and Back" do
    get :show, :id => @line_item.to_param, :cart_id => @line_item.cart.id
    assert_response :success
    assert_select "a[href=?]", %r{/carts/#{@line_item.cart.id}/line_items/#{@line_item.to_param}/edit}, 'Edit'
    assert_select "a[href=?]", %r{/carts/#{@line_item.cart.id}}, 'Back'
  end


  # ラインアイテムの編集画面には更新のボタンがあり、それのリンクは
  # /carts/3/lineitems/20 のようになっている
  test "edit form should submit to url in the form of nested resource" do
    get :edit, :id => @line_item.to_param, :cart_id => @line_item.cart.id
    assert_response :success

    # フィールドのチェック (1 つしかフィールドがないということは、おそ
    # らく数量しか変更できなくなっている。それを確認する。
    assert_select "form > div.field", 1

    # リンクのチェック
    assert_select "form[action=?]", %r{/carts/#{@line_item.cart.id}/line_items/#{@line_item.to_param}}
    assert_select "input#line_item_product_id[value=?]", @line_item.product_id
    assert_select "a[href=?]", %r{/carts/#{@line_item.cart.id}/line_items/#{@line_item.to_param}}, 'Show'
    assert_select "a[href=?]", %r{/carts/#{@line_item.cart.id}}, 'Back'
  end


  # ラインアイテムの編集画面で更新のボタンを押すと、カートの show にリ
  # ダイレクトされることを確かめるテスト。
  test "putting line item nested in cart should be redirected to 'show' page of the cart" do
    put :update, :id => @line_item.to_param, :cart_id => @line_item.cart.id
    assert_redirected_to cart_url(@line_item.cart.id)
  end

  # cart でネストされたラインアイテムを削除すると、cart の :show の画面
  # にリダイレクトされる。
  test "deleting line item nested in cart should be redirected to 'show' page of the cart" do
    delete :destroy, :id => @line_item.to_param, :cart_id => @cart.id
    assert_redirected_to cart_url(@line_item.cart.id)
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
