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

  validates :title, :description, :presence => true

  validate do |product|
    product.has_valid_image_path_or_nil
  end

  def has_valid_image_path_or_nil
    return true if image_url.nil?
    unless File.exist?(File.join(Rails::public_path, 'images', image_url))
      errors.add(:image_url, "is not an existing path")
    end
  end

  validates :price, :numericality => { :greater_than_or_equal_to => 0.01 }
  validates :title, :uniqueness => true

  validates :image_url, :format => {
    :with => %r{\.(gif|jpg|png)$}i,
    :message => 'msut be a URL for GIF, JPG or PNG image'
  }
end
