require 'spec_helper'

describe User do
  %w(given_name family_name street_address locality region postal_code country).each do |attribute|
    it {should validate_presence_of attribute}
  end

  it {should validate_inclusion_of(:region).to_allow(*OpenGovernment::STATES.values)}
  it {should validate_inclusion_of(:country).to_allow('US')}

  context 'with a persisted user' do
    let :user do
      FactoryGirl.create(:user)
    end

    describe '#name' do
      it "should return the user's formatted name" do
        user.name.should == 'John Public'
      end
    end

    describe '#alternate_name' do
      it "should return the user's persisted given name" do
        user.alternate_name.should == 'John'
        user.given_name = 'Bob'
        user.alternate_name.should == 'John'
      end
    end

    describe '#questions_signed' do
      it "should return the questions signed by the user" do
        @questions = FactoryGirl.create_list(:question, 4)
        @questions.first(2).each do |question|
          FactoryGirl.create(:signature, user: user, question: question)
        end
        user.questions_signed.should == @questions.first(2)
      end
    end

    describe 'address_for_geocoding' do
      it "should return the user's address for geocoding" do
        user.address_for_geocoding.should == '148 Lafayette St, New York, ny, US, 10013'
      end
    end

    describe '#perform' do
      it "should geocode the user's address" do
        User.perform(user.id, 'geocode')
        user.reload.to_coordinates.should == [40.7189099, -74.0002784]
      end
    end
  end
end