require 'rails_helper'

RSpec.describe Startup, type: :model do
  it "cannot be created without a name or with a short name" do
    expect { Startup.create! }.to raise_error(ActiveRecord::RecordInvalid, /Name can't be blank, Name is too short/)
  end

  it "cannot be created with a short name" do
    expect {
      Startup.create!({ name: 'short' })
    }.to raise_error(ActiveRecord::RecordInvalid, /((?!Name can't be blank).)Name is too short/)
  end

  it "can be created with a name and description" do
    expect {
      Startup.create!({ name: 'normal name', description: 'some description' })
    }.not_to raise_error
  end
end
