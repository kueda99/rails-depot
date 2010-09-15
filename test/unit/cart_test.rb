# -*- coding: utf-8 -*-
require 'test_helper'

class CartTest < ActiveSupport::TestCase
  test "should have methods returning relations" do
    assert Cart.method_defined?('line_items')
  end

  test "associated line items should be deleted if a cart is deleted" do
    cart = carts(:cart_with_two_items)
    assert_not_equal 0, cart.line_items.count    # テスト条件成立の確認

    cart.destroy
    assert_equal 0, cart.line_items.count
  end

  # Cart#add_product(product_id) のテスト その1: 引数 product_id の製
  # 品がカートにない場合、新規に LineItem インスタンスを作成して返す。
  test "should create a line item if a given product is NOT in the cart" do
    cart = carts(:cart_with_two_items)
    ruby_book = products(:ruby)
    # カートに製品が入っていないことの確認
    assert !cart.line_items.exists?(:product_id => ruby_book.id)

    item = cart.add_product(ruby_book.id)

    # LineItem オブジェクトがカートに入っており、製品および数量が 1 で
    # あることの確認
    assert_equal cart, item.cart
    assert_equal ruby_book, item.product
    assert_equal 1, item.quantity
  end

  # Cart#add_product(product_id) のテスト その2: 引数 product_id の製品
  # がすでにカートにある場合、既存の LineItem インスタンスの quantity
  # が 1 つ増える。
  test "should increment quantity of a line item if a given product is in the cart" do
    cart = carts(:cart_with_two_items)
    product = products(:one)
    item = cart.line_items.find(:first, :conditions => ['product_id = ?', product.id])

    item = cart.add_product(product.id)

    # LineItem オブジェクトがカートに入っており、製品および数量が 2 で
    # あることの確認
    assert_equal cart, item.cart
    assert_equal product, item.product
    assert_equal 2, item.quantity
  end

  test "should return total price of line items" do
    cart = carts(:cart_with_two_items)
    assert_equal 19.98, cart.total_price
    cart.line_items.first.quantity += 1
    assert_equal 29.97, cart.total_price
  end

  test "#total_items should return number of items in it" do
    assert_equal 2, carts(:cart_with_two_items).total_items

    cart = Cart.new
    assert_equal 0, cart.total_items

    cart.line_items.build(:product => products(:one))
    assert_equal 1, cart.total_items
  end

end
