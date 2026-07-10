# frozen_string_literal: true

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.find_each do |cart|
      cart.mark_as_abandoned
      cart.remove_if_abandoned
    end
  end
end
