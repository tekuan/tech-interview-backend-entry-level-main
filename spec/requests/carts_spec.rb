# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/carts', type: :request do
  let(:cart) { create(:shopping_cart) }

  # Reuse the test cart instead of creating a new one from the session.
  before(:each) do
    allow_any_instance_of(CartsController)
      .to receive(:find_or_create_cart)
      .and_return(cart)
  end

  describe "GET /cart" do
    it "returns an empty cart" do
      get "/cart"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["products"]).to eq([])
      expect(body["total_price"]).to eq(0)
    end
  end  

  describe "POST /cart" do
    let!(:product) do
      Product.create!(name: "Mouse", price: 100)
    end

    context 'when add a existing product to the cart' do
      it "returns success" do
        post "/cart",
            params: {
              product_id: product.id,
              quantity: 2
            },
            as: :json

        expect(response).to have_http_status(:created)

        body = JSON.parse(response.body)

        expect(body["products"].size).to eq(1)
        expect(body["products"][0]["quantity"]).to eq(2)
      end
    end 

    context 'when try to add a non-existent product' do
      it "returns not found" do
        post "/cart",
            params: {
              product_id: 999,
              quantity: 1
            },
            as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /add_item' do
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }
    
    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context 'when the product does not exists in the cart' do
      let(:product_out_of_cart) { Product.create(name: 'Test Product', price: 10.0) }

      it "returns not found" do
        post "/cart/add_item",
            params: {
              product_id: product_out_of_cart.id,
              quantity: 1
            },
            as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /:product_id' do
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }
    context 'when try to remove a product' do

      it "returns sucess" do
        delete "/cart/#{product.id}"

        expect(response).to have_http_status(:ok)

        expect(cart.reload.cart_items.count).to eq(0)
      end
    end
  
    context 'when try to remove a non-existent product' do
      it "returns not found" do
        delete "/cart/999"

         expect(response).to have_http_status(:not_found)
      end
    end
  end
end
