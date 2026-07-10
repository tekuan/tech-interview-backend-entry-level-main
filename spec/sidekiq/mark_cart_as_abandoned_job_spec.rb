require "rails_helper"

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe "#perform" do
    let!(:inactive_cart) do 
        create(:shopping_cart, last_interaction_at: 3.hours.ago)
    end

    let!(:expired_cart) do
        create(:shopping_cart, last_interaction_at: 8.days.ago, 
            abandoned: true)
    end

    it "marks inactive carts as abandoned" do
      described_class.new.perform

      expect(inactive_cart.reload.abandoned).to be(true)
    end

    it "removes expired abandoned carts" do
      described_class.new.perform

      expect(Cart.exists?(expired_cart.id)).to be(false)
    end
  end
end