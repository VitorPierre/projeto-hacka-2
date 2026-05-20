class HomeController < ApplicationController
  def index
    if logged_in?
      redirect_to current_user.student? ? student_path(current_user) : teacher_path(current_user)
      return
    end
    
    @teachers = User.teacher.public_view.includes(:subjects).limit(3)
    @students = User.student.public_view.includes(:subjects).limit(3)
  end

  def terms
  end

  def privacy
  end
end
