# -*- coding: utf-8 -*-
class CombineItemsInCart < ActiveRecord::Migration
  def self.up
    Cart.all.each do |cart|
      line_item_for = Hash.new
      cart.line_items.each do |i|
        i.quantity = 1 if i.quantity.nil?  # 数量が nil のときは 1 とみなす
        if line_item_for[i.product_id].nil?
          line_item_for[i.product_id] = i
        else
          # すでに同じ製品のラインアイテムがある
          item = line_item_for[i.product_id]
          item.quantity += i.quantity
          i.destroy
        end
      end

      # 更新したラインアイテムをデータベースに保存する
      line_item_for.each do |key, value|
        value.save
      end
    end
  end

  def self.down
  end
end
