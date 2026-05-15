class HomeController < ApplicationController
  def index
    if logged_in?
      redirect_to current_user.student? ? student_path(current_user) : teacher_path(current_user)
      return
    end
    
    @teachers = User.where(role: 'teacher').includes(:subjects).limit(3)
    @students = User.where(role: 'student').includes(:subjects).limit(3)
  end
end
