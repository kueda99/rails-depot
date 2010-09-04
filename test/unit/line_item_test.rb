require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  test "should have methods returning relations" do
    assert LineItem.method_defined?('cart')
    assert LineItem.method_defined?('product')
  end
end
