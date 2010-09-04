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
end
