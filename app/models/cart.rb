# -*- coding: utf-8 -*-
class Cart < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy

  # Cart#add_product(product_id) は、関連するラインアイテム
  # (line_items) を 1 つ増やすか、またはすでにその製品がカートにあった
  # 場合は、その製品のためのラインアイテムの属性 quantity を 1 つ増やす。
  #
  # 返り値はラインアイテムであり、それは新規に作成されたか、または数量
  # がアップデートされたものである。データベースには反映されていないの
  # で注意すること。
  def add_product(product_id)
    current_item = line_items.detect { |item| item.product_id == product_id }
    if current_item.nil?
      current_item = self.line_items.build(:product_id => product_id)
    else
      current_item.quantity += 1
    end
    current_item
  end

end
