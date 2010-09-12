# -*- coding: utf-8 -*-
module ApplicationHelper

  # 管理者である場合は true を返す
  def admin?
    !session[:user_id].nil?
  end

  # 管理者である場合は "admin" を、そうでない場合は "customer" の文字列
  # を返す
  def admin_or_customer
    admin? ? "customer" : "admin"
  end

end
