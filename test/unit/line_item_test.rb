# -*- coding: utf-8 -*-
require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  setup do
    @lineitem = line_items(:li_one)
  end

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

  # 製品の数量は自然数でなければならないことを確認する
  test "quantity must be decimal" do
    assert @lineitem.valid?

    bad_values = %w('a' 0 -1 0.8 1.8)
    bad_values.each do |value|
      @lineitem.quantity = value
      assert @lineitem.invalid?, %{line item with quantity "#{value}" should be invalid}
    end
  end

  test "should return total price" do
    assert_equal 9.99, @lineitem.total_price
    @lineitem.quantity = 2
    assert_equal 19.98, @lineitem.total_price
  end
end
