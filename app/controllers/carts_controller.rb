# frozen_string_literal: true

class CartsController < ApplicationController
before_action :set_cart, only: %i[show create add_item destroy]
  def show
    render_cart
  end

  def create
    @cart.add_product(
      cart_params[:product_id],
      cart_params[:quantity]
    )
    render_cart(:created)
  end

  def add_item

 def add_item
  unless @cart.add_item(
    cart_params[:product_id],
    cart_params[:quantity]
  )
    return render json: {
      error: "Produto não encontrado no carrinho"
    }, status: :not_found
  end

  render_cart
end

  def destroy
    unless @cart.remove_product(params[:product_id])
      return render json: {
        error: 'Produto não encontrado no carrinho'
      }, status: :not_found
    end

    render_cart
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def find_or_create_cart
    return Cart.find(session[:cart_id]) if session[:cart_id]

    cart = Cart.create!
    session[:cart_id] = @cart.id
    cart
  end

  def render_cart(status = :ok)
    render json: {
      id: @cart.id,
      products: @cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.product.price * item.quantity
        }
      end,
      total_price: @cart.total_price
    }, status: status
  end

  def set_cart
    @cart = find_or_create_cart
  end
end
