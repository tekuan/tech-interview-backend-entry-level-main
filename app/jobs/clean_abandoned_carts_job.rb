class CleanAbandonedCartsJob < ApplicationJob
  queue_as :default

def perform
  Cart.inactive.where(abandoned_at: nil).find_each do |cart|
    cart.update!(abandoned_at: Time.current)
  end

  Cart.expired.find_each(&:destroy!)
end
end
