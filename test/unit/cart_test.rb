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
    ruby_id = products(:ruby).id
    assert_nil cart.line_items.detect { |item| item.product_id == ruby_id }
    new_line_item = cart.add_product(products(:ruby).id)
    assert_equal 1, new_line_item.quantity
    assert_not_nil cart.line_items.detect { |item| item.product_id == ruby_id }
  end

  # Cart#add_product(product_id) のテスト その2: 引数 product_id の製品
  # がすでにカートにある場合、既存の LineItem インスタンスの quantity
  # が 1 つ増える。
  test "should increment quantity of a line item if a given product is in the cart" do
    cart = carts(:cart_with_two_items)
    product_one_id = products(:one).id

    item_in_the_cart = cart.line_items.detect { |item| item.product_id == product_one_id }
    assert_not_nil item_in_the_cart

    # add_product() によって LineItem インスタンスの quantity の値が 1
    # つ増えることの確認
    assert_difference 'item_in_the_cart.quantity' do
      new_line_item = cart.add_product(product_one_id)
      assert_equal item_in_the_cart, new_line_item
    end

    assert_not_nil cart.line_items.detect { |item| item.product_id == product_one_id }
  end
end
