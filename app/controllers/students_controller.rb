class StudentsController < ApplicationController
  def index
    @students = Student.all
  end

  def show
    @student = Student.find(params[:id])
  end

  def login_form
  end

  def login_check
    @student = Student.find_by(code: params[:code])

    if @student
      redirect_to student_path(@student)
    else
      flash[:alert] = "Code incorrect"
      render :login_form, status: :unprocessable_entity
    end
  end
end