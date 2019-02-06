require 'rails_helper'

RSpec.describe Investment, type: :model do
  fixtures :startups, :users

  it "cannot be created without user and a startup" do
    investment = Investment.new;
    expect{
      investment.save!
    }.to raise_error(ActiveRecord::RecordInvalid, /(?=.*\bStartup can't be blank\b)(?=.*\bUser can't be blank\b)/)
  end

  it "can be created with an user and startup" do
    investment = Investment.new({
      startup: startups(:one),
      user: users(:one),
      amount: 10000
    })
    expect{ investment.save! }.not_to raise_error
  end
end
