# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def current_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create    # new ではなくて create
    session[:cart_id] = cart.id

    logger.warn "Cart not found and created one with id #{session[:cart_id]}"

    cart
  end

  def set_cart
    @cart = current_cart
  end

  # 管理者かどうかを返すメソッド。コントローラで session の中身を直接参
  # 照しないようにするため。
  def admin?
    !session[:user_id].nil?
  end
end
