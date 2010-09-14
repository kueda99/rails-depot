# -*- coding: utf-8 -*-
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  setup do
    @product = products(:one)
    @product_not_in_any_cart = products(:not_in_any_cart)
  end

  test "test conditions are established" do
    assert @product.valid?, "test conditions are not established"
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?, "product with blank attributes should be invalid"

    [:title, :description].each do |attribute|
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
      assert new_product("dummies/#{url}").valid?, %{URL with a proper extension ('#{url}') should be valid}
    end

    bad_url = ['hello.pdf']
    bad_url.each do |url|
      assert new_product("dummies/#{url}").invalid?, %{URL with an improper extension ('#{url}') should not be valid}
    end
  end

  # Product.find が title についてソートされて得られるかのテスト
  test "product objects should be obtained in order of title value" do
    # まずはフィクスチャーがタイトル順に得られないことを確認する
    products = Product.unscoped.all
    sorted_products = products.sort_by { |item| item.title }
    assert_not_equal products, sorted_products,
        "Fixture is not in a good condition for this test"

    assert_equal sorted_products, Product.all
  end

  # 関連のメソッドが存在しているかテスト
  test "should have methods returning relations" do
    assert Product.method_defined?('line_items')
  end


  # 少なくても 1 つ以上のラインアイテムが参照している (製品がカートに入っ
  # ている) ときは削除することができないことのテスト
  test "should not be deleted if it has at least one associated line item" do
    assert !@product.line_items.empty?, "Fixture is not good for this test"
    assert_no_difference 'Product.count' do
      @product.destroy
    end
    assert @product.errors[:base].include? "Line items present"
  end

  # ラインアイテムが参照していない (製品がカートに入っていない) ときは
  # 削除することができることのテスト
  test "could be deleted if it does not have any associated line items" do
    assert @product_not_in_any_cart.line_items.empty?, "Fixture is not good for this test"
    assert_difference 'Product.count', -1 do
      @product_not_in_any_cart.destroy
    end
    assert !@product_not_in_any_cart.errors[:base].include?("Line items present")
  end


  # イメージに関するテスト
  test "image_url should be nil or pointing an existing file" do
    assert @product.valid?, "product with existing image url should be valid"
    assert_empty @product.errors[:image_url]

    @product.image_url = "foo/bar.jpg"
    assert !@product.valid?, "product with non-existing image url should be invalid"
    assert_equal 'is not an existing path', @product.errors[:image_url].join('; ')
  end


  # 新しい product オブジェクトを生成する。
  def new_product(image_url)
    Product.new(:title => "My Book Title",
                :description => "yyy",
                :price => 1,
                :image_url => image_url)
  end
end
