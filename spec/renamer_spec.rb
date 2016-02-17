# encoding: UTF-8
require 'spec_helper'

describe RailsRefactor::Renamer do

 it "creates a valid renamer object" do
   renamer = RailsRefactor::Renamer.new("from_model", "to_model")
   expect(renamer.class).to eql(RailsRefactor::Renamer)
 end
end
