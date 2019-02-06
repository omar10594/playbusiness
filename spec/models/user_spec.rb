require 'rails_helper'

RSpec.describe User, type: :model do
  it "can be created with an email and password" do
    user = User.new({
      email: 'test@email',
      password: 'secret'
    })
    saved = user.save
    
    expect(saved).to be true
  end
end
