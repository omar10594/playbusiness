require 'rails_helper'

RSpec.describe JanuaryPromotionHelper, type: :helper do
  fixtures :users, :startups

  def round(bonus)
    bonus.map do |bonus|
      bonus[:lower_limit] = bonus[:lower_limit].round(2)
      if bonus[:upper_limit] != nil
        bonus[:upper_limit] = bonus[:upper_limit].round(2)
      end
      bonus
    end
  end

  def create_investments(user, investments)
    startup = startups(:one)
    investments = investments.map do |investment| 
      investment[:startup] = startup
      investment
    end
    user.investments.create(investments)
  end

  context "user with four two investments to consider and low coefficient of variation" do
    it "should return the correct data" do
      user = users(:one)
      create_investments(user, [
        { :amount => 100000, :wallet_amount => 0 },
        { :amount => 90000, :wallet_amount => 10000 }
      ])
      expected_result = [
        { :lower_limit => 9633.10, :upper_limit => 19266.20, :bonus => 20 },
        { :lower_limit => 19266.21, :upper_limit => 77064.81, :bonus => 30 },
        { :lower_limit => 77064.82, :bonus => 35 }
      ]

      result = round helper.january_promotion_table(user)

      expect(result).to eql(expected_result)
    end
  end

  context "user with four two investments to consider and coefficient of variation above the minimum" do
    it "should return the correct data" do
      user = users(:one)
      create_investments(user, [
        { :amount => 100000, :wallet_amount => 0 },
        { :amount => 80000, :wallet_amount => 10000 }
      ])
      expected_result = [
        { :lower_limit => 19500.0, :upper_limit => 58499.99, :bonus => 25 },
        { :lower_limit => 58500.0, :upper_limit => 175499.99, :bonus => 30 },
        { :lower_limit => 175500.0, :bonus => 40 }
      ]

      result = round helper.january_promotion_table(user)

      expect(result).to eql(expected_result)
    end
  end

  context "user with four one investment to consider" do
    it "should return the correct data" do
      user = users(:one)
      create_investments(user, [
        { :amount => 100000, :wallet_amount => 0 }
      ])
      expected_result = [
        { :lower_limit => 9633.10, :upper_limit => 19266.20, :bonus => 20 },
        { :lower_limit => 19266.21, :upper_limit => 77064.81, :bonus => 30 },
        { :lower_limit => 77064.82, :bonus => 35 }
      ]

      result = round helper.january_promotion_table(user)

      expect(result).to eql(expected_result)
    end
  end

  context "user without investments" do
    it "should return the correct data" do
      user = users(:one)
      expected_result = [
        { :lower_limit => 463.14, :upper_limit => 926.27, :bonus => 30 },
        { :lower_limit => 926.28, :upper_limit => 4631.41, :bonus => 35 },
        { :lower_limit => 4631.42, :bonus => 40 }
      ]

      result = round helper.january_promotion_table(user)

      expect(result).to eql(expected_result)
    end
  end
end
