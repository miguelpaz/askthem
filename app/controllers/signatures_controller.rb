class SignaturesController < ApplicationController
  before_filter :force_http

  respond_to :json
  before_filter :authenticate_user!

  def create
    @signature = current_user.signatures.new(question_id: params[:question_id])

    if @signature.save
      question = Question.find(params[:question_id])
      QuestionMailer.signed_on(current_user, question).deliver

      if question.signature_count == question.person.signature_threshold
        QuestionMailer.email_person(question).deliver
        QuestionMailer.notify_staff_question_at_threshold(question).deliver
      end

      render json: @signature, status: :created
    else
      render json: @signature.errors, status: :unprocessable_entity
    end
  end
end
