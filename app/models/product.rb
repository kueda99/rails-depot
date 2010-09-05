# -*- coding: utf-8 -*-
class Product < ActiveRecord::Base
  default_scope :order => 'title'

  has_many :line_items

  # before_destroy は、引数のメソッドが true を返さなければ product オ
  # ブジェクトは削除できないようにするものである
  before_destroy :ensure_not_referenced_by_any_line_item

  # 関連しているラインアイテムが存在していなかったら true を返す。もし
  # 存在していたら自身にエラーメッセージを設定する。
  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      return true
    else
      errors[:base] << "Line items present"
      return false
    end
  end

  validates :title, :description, :image_url, :presence => true
  validates :price, :numericality => { :greater_than_or_equal_to => 0.01 }
  validates :title, :uniqueness => true

  validates :image_url, :format => {
    :with => %r{\.(gif|jpg|png)$}i,
    :message => 'msut be a URL for GIF, JPG or PNG image'
  }
end
