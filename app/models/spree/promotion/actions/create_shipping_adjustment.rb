module Spree
  class Promotion
    module Actions
      class CreateShippingAdjustement < PromotionAction
        include Spree::CalculatedAdjustments
        include Spree::AdjustmentSource

        before_validation -> { self.calculator ||= Calculator::PercentOnLineItem.new }

        def perform(options = {})
          order, promotion = options[:order], options[:promotion]
          create_unique_adjustments(order, order.shipments)
        end

        def compute_amount(shipment)
          #return 0 unless promotion.line_item_actionable?(line_item.order, line_item)
          [shipment.cost, compute(shipment)].min * -1
        end
      end
    end
  end
end
