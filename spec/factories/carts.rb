FactoryBot.define do
  factory :shopping_cart, class: Cart do
    total_price { 0.0 }
    last_interaction_at { Time.current }
    abandoned { false }
  end
end