require_relative '../services/ai_service'

class LearnController < ApplicationController
  before_action :require_login
  before_action :check_role_by_path

  def index
    @question = params[:question]
    @answer = nil

    if @question.present?
      @answer = AiService.call(current_user, @question)
    end
  end

  private

  def check_role_by_path
    if request.path == '/learn'
      require_student
    elsif request.path == '/plan'
      require_teacher
    end
  end
end
