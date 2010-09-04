require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product" do
    attributes = @product.attributes
    attributes.update({"title" => attributes["title"] + "2"})

    assert_difference('Product.count') do
      post :create, :product => attributes
    end

    assert_redirected_to product_path(assigns(:product))
  end

  test "should show product" do
    get :show, :id => @product.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @product.to_param
    assert_response :success
  end

  test "should update product" do
    put :update, :id => @product.to_param, :product => @product.attributes
    assert_redirected_to product_path(assigns(:product))
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, :id => @product.to_param
    end

    assert_redirected_to products_path
  end

  test "should get index having proper layout" do
    get :index
    assert_select %{title}, 'Pragprog Books Online Store'
    assert_select '#store' do |elements|
      elements.each do |element|
        assert_select element, '#banner'
        assert_select element, '#columns' do |elems|
          elems.each do |el|
            assert_select el, '#side'
            assert_select el, '#main'
          end
        end
      end
    end
  end

end
