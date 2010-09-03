require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  setup do
    @product = products(:one)
  end

  test "test conditions are established" do
    assert @product.valid?, "test conditions are not established"
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?, "product with blank attributes should be invalid"

    [:title, :description, :image_url].each do |attribute|
      assert product.errors[attribute].include?("can't be blank"),
      %{#{attribute} of product should not be blank}
    end
  end

  test "price of product should be greater than 0" do
    @product.price = 10.0
    assert @product.valid?, "product price greater than 0 should be valid"

    bad = %w{0.0 -1.0}
    bad.each do |price|
      @product.price = price
      assert @product.invalid?, "product price should be invalid if it is #{price}"
      assert_equal "must be greater than or equal to 0.01", @product.errors[:price].join('; ')
    end
  end

  test "product with non-unique title should be invalid" do
    assert @product.save
    new_product = Product.new(@product.attributes)
    assert new_product.invalid?, "product with duplicate title should be invalid"
  end

  test "image_url without a proper extension invalid" do
    good = %w{hello.gif hello.GIF hello.jpg hello.JPG hello.png hello.PNG}
    good.each do |url|
      @product.image_url = url
      assert @product.valid?, %{URL with a proper extension ('#{url}') should be valid}
    end

    bad_url = ['hello.pdf']
    bad_url.each do |url|
      @product.image_url = url
      assert @product.invalid?, %{URL with an improper extension ('#{url}') should not be valid}
    end
  end
end
