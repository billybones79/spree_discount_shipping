require_dependency 'spree/shipping_calculator'

Spree::Calculator::Shipping::FlatRate.class_eval do

  def compute_package_with_discount_promotion_action(package)

    discount = apply_discount_charge?(package)

    if discount > 0
      min = [discount, self.preferred_amount].min * -1
      price = self.preferred_amount + min

      return price
    else
      compute_package_without_discount_promotion_action(package)
    end
  end

  alias_method_chain :compute_package, :discount_promotion_action

  protected

  def apply_discount_charge?(package)
    # Check if an eligible promotion exists, and that it has the "MakeShippingMethodFree" action.
    # If so, check that the shipping method for the package in in the list of the ones
    # targeted by the promotion action.
    package.order.promotions.any? do |p|
      p.eligible?(package.order) &&
          p.promotion_actions.any? do |action|
            if action.is_a?(Spree::Promotion::Actions::CreateShippingAdjustment)
              return action.calculator.compute(package.order)
            else
              return 0
            end
          end
    end
  end

end
