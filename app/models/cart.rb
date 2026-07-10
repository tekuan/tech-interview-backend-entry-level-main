# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  scope :inactive, lambda {
    where('last_interaction_at <= ?', 3.hours.ago)
  }

  scope :abandoned, lambda {
    where(abandoned: true)
  }

  scope :expired, lambda {
    abandoned.where('last_interaction_at <= ?', 7.days.ago)
  }

  def inactive?
    last_interaction_at.present? &&
      last_interaction_at <= 3.hours.ago
  end

  def mark_as_abandoned
    update!(abandoned: true) if inactive?
  end

  def remove_if_abandoned
    destroy! if abandoned? && last_interaction_at <= 7.days.ago
  end

  def add_product(product_id, quantity)
    product = Product.find_by(id: product_id)

    return false unless product

    cart_item = cart_items.find_by(product:)

    if cart_item
      cart_item.increment!(:quantity, quantity)
    else
      cart_items.create!(product:, quantity:)
    end
    touch(:last_interaction_at)
    true
  end

  def add_item(product_id, quantity)
    cart_item = cart_items.find_by(product_id:)

    return false unless cart_item

    cart_item.increment!(:quantity, quantity)
    touch(:last_interaction_at)
    true
  end

  def total_price
    cart_items.sum do |cart_item|
      cart_item.product.price * cart_item.quantity
    end
  end

  def remove_product(product_id)
    cart_item = cart_items.find_by(product_id:)

    return false unless cart_item

    cart_item.destroy!
    touch(:last_interaction_at)
  end
end
