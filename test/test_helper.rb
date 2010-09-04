# -*- coding: utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # ページがアプリケーションレイアウトを使っているかチェックする
  def assert_application_layout
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
