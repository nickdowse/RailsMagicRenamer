# encoding: UTF-8
require 'spec_helper'

describe RailsRefactor::Renamer do

  before(:all) do
    DummyFromDoesExist = Class.new
    DummyToDoesExist = Class.new
  end

  it "creates a valid renamer object" do
    renamer = RailsRefactor::Renamer.new("DummyFromDoesExist", "DummyToDoesntExist")
    expect(renamer).to be_kind_of(RailsRefactor::Renamer)
  end

  it "raises an error if the 'from' class doesn't exist" do
    expect { RailsRefactor::Renamer.new("DummyFromDoesntExist", "DummyToDoesntExist") }.to raise_error("The object you are trying to rename from does not exist.")
  end

  it "raises an error if a 'to' class already exists" do
    expect { RailsRefactor::Renamer.new("DummyFromDoesExist", "DummyToDoesExist") }.to raise_error("The object you are trying to rename to already exists.")
  end

  # add in check for not in root directory error
end
