# encoding: UTF-8
require 'rails_helper'

describe RailsMagicRenamer::Renamer do

  it "creates a valid renamer object" do
    renamer = RailsMagicRenamer::Renamer.new("Micropost", "Macropost")
    expect(renamer).to be_kind_of(RailsMagicRenamer::Renamer)
  end

  it "raises an error if the 'from' class doesn't exist" do
    expect { RailsMagicRenamer::Renamer.new("DummyFromDoesntExist", "DummyToDoesntExist") }.to raise_error("The object you are trying to rename from does not exist.")
  end

  it "raises an error if a 'to' class already exists" do
    expect { RailsMagicRenamer::Renamer.new("Micropost", "User") }.to raise_error("The object you are trying to rename to already exists.")
  end

  it "Should be able to access microposts!" do
    expect(Micropost).to respond_to(:from_users_followed_by)
  end
end
