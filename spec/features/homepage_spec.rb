require "spec_helper"
require File.expand_path("../features_helper.rb", __FILE__)

describe "pages#index" do
  describe "Top National Questions" do
    it "displays total number of answers" do
      3.times do
        FactoryGirl.create(:answer)
      end
      visit "/"
      expect(find(".leftCol")).to have_content("3 Answers")
    end

    it "displays total number of signatures" do
      3.times do
        FactoryGirl.create(:signature)
      end
      visit "/"
      expect(find(".leftCol")).to have_content("3 Supporters")
    end

    it "displays top questions by number of signatures" do
      first_question = FactoryGirl.create(:question)
      2.times do
        FactoryGirl.create(:signature, question: first_question)
      end

      second_question = FactoryGirl.create(:question)
      FactoryGirl.create(:signature, question: second_question)

      visit "/"
      questions_on_page = all(".leftCol .popular_questions li")
      expect(questions_on_page.first).to have_content("2 Supporters")
      expect(questions_on_page.last).to have_content("1 Supporter")
    end
  end

  describe "Top Questions Near", vcr: true do
    before do
      # need to create questions by user that is near same location
      @user = FactoryGirl.create(:user)
      @metadatum = FactoryGirl.create(:metadatum, abbreviation: @user.region)
      @person = FactoryGirl.create(:person_ny_sheldon_silver)
      3.times do
        FactoryGirl.create(:question,
                           person: @person,
                           user: @user,
                           state: @metadatum.abbreviation)
      end

      # create some content that is not "near" our user
      california = FactoryGirl.create(:metadatum, abbreviation: "ca")
      cali_user = FactoryGirl.create(:user,
                                     region: california.abbreviation,
                                     coordinates: [-118.290474, 34.100535])
      cali_person = FactoryGirl.create(:person,
                                       state: california.abbreviation)
      3.times do
        FactoryGirl.create(:question,
                           person: cali_person,
                           user: cali_user,
                           state: california.abbreviation)
      end

      # set our ip address for something we know is in ny, nyc.gov
      page.driver.options[:headers] = { "REMOTE_ADDR" => "161.185.30.156" }
    end

    it "displays number of answers near a user's location" do
      pending "implementation"

      visit "/"
      expect(find(".rightCol")).to have_content("3 Answers")
    end

    it "displays number of signatures near a user's location" do
      pending "implementation"

      Question.connected_to(@metadatum.abbreviation).each do |question|
        FactoryGirl.create(:signature, question: question)
      end

      visit "/"
      expect(find(".rightCol")).to have_content("3 Supporters")
    end
  end
end