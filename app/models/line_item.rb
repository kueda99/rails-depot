class LineItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  validates :quantity, :numericality => {:greater_than => 0, :only_integer => true}
end
