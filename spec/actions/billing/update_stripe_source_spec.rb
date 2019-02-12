require 'rails_helper'

RSpec.describe Billing::UpdateStripeSource do
  let(:user) { create(:user) }
  let(:stripe_mock) { StripeMock.create_test_helper }

  it 'should change the default payment method for the user' do
    token = stripe_mock.generate_card_token

    expect {
      Billing::UpdateStripeSource.call(user: user, token: token)
    }.to(change { user.stripe_customer.default_source })
  end

  context 'with an invalid stripe token' do
    it 'should not update the default payment source for the user' do
      StripeMock.prepare_card_error(:invalid_number, :update_customer)
      expect {
        Billing::UpdateStripeSource.call(user: user, token: stripe_mock.generate_card_token)
      }.not_to(change { user.reload.stripe_customer.default_source })
    end

    it 'should not create a StripeSubscription object for me' do
      StripeMock.prepare_card_error(:invalid_number, :update_customer)
      expect {
        Billing::UpdateStripeSource.call(user: user, token: stripe_mock.generate_card_token)
      }.not_to(change { user.pro_subscription })
    end

    it 'should raise a Stripe::CardError' do
      StripeMock.prepare_card_error(:invalid_number, :update_customer)
      expect {
        Billing::UpdateStripeSource.call(user: user, token: stripe_mock.generate_card_token)
      }.to raise_error(Stripe::CardError)
    end
  end
end
