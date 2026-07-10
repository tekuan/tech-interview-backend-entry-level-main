# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0


    scope :inactive, -> {
    where("updated_at < ?", 3.hours.ago)
  }

  scope :abandoned, -> {
    where.not(abandoned_at: nil)
  }

  scope :expired, -> {
    abandoned.where("abandoned_at < ?", 7.days.ago)
  }
  def add_product(product_id, quantity)
    product = Product.find(product_id)

    item = cart_items.find_by(product:)
    if item
      item.increment!(:quantity, quantity)
    else
      cart_items.create!(product:, quantity:)
    end
      touch

  end

  def add_item(product_id, quantity)
    item = cart_items.find_by(product_id:)

    return false unless item

    item.increment!(:quantity, quantity)
      touch

  end

  def total_price
    cart_items.sum do |item|
      item.product.price * item.quantity
    end
  end

  def remove_product(product_id)
    item = cart_items.find_by(product_id:)

    return false unless item

    item.destroy!
      touch
  end
end
