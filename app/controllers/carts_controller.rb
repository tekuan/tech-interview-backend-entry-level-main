# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :set_cart, only: %i[show create add_item destroy]

  def show
    render_cart
  end

  def create
    unless @cart.add_product(
      cart_params[:product_id],
      cart_params[:quantity]
    )
      return render_not_found('Produto não encontrado')
    end

    render_cart(:created)
  end

  def add_item
    unless @cart.add_item(
      cart_params[:product_id],
      cart_params[:quantity]
    )
      return render_not_found
    end

    render_cart
  end

  def destroy
    return render_not_found unless @cart.remove_product(params[:product_id])

    render_cart
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def find_or_create_cart
    if session[:cart_id]
      cart = Cart.find_by(id: session[:cart_id])
      return cart if cart

      session.delete(:cart_id)
    end

    cart = Cart.create!(
      last_interaction_at: Time.current
    )
    session[:cart_id] = cart.id
    cart
  end

  def render_cart(status = :ok)
    render json: {
      id: @cart.id,
      products: serialized_products,
      total_price: @cart.total_price
    }, status: status
  end

  def serialized_products
    @cart.cart_items.map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.product.price,
        total_price: item.product.price * item.quantity
      }
    end
  end

  def render_not_found(error = 'Produto não encontrado no carrinho')
    render json: {
      error:
    }, status: :not_found
  end

  def set_cart
    @cart = find_or_create_cart
  end
end
