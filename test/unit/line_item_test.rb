# -*- coding: utf-8 -*-
require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  test "should have methods returning relations" do
    assert LineItem.method_defined?('cart')
    assert LineItem.method_defined?('product')
  end

  # 明示的に製品の数量が指定されなかったときは 1 となることの確認 (マイ
  # グレーションでの設定による機能)
  test "should have decimal quantity" do
    line_item = LineItem.create do |item|
      item.cart = Cart.first
      item.product = Product.first
    end
    assert_equal 1, line_item.quantity
  end
end
