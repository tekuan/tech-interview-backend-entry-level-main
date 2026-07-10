# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartItem, type: :model do
  let(:cart) { create(:shopping_cart) }
  let(:product) { Product.create!(name: "Mouse", price: 100) }

  it "is valid with valid attributes" do
    cart_item = described_class.new(
      cart: cart,
      product: product,
      quantity: 1
    )

    expect(cart_item).to be_valid
  end

  it "is invalid without a cart" do
    cart_item = described_class.new(
      product: product,
      quantity: 1
    )

    expect(cart_item).not_to be_valid
  end

  it "is invalid without a product" do
    cart_item = described_class.new(
      cart: cart,
      quantity: 1
    )

    expect(cart_item).not_to be_valid
  end
end