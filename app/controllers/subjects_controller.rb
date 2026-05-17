class SubjectsController < ApplicationController
  before_action :set_subject, only: [:update, :destroy]

  def create
    @subject = Subject.new(subject_params)
    if @subject.save
      redirect_to params[:redirect_to] || root_path, notice: "Especialidade '#{@subject.name}' adicionada com sucesso!"
    else
      error_msg = @subject.errors.full_messages.to_sentence
      redirect_to params[:redirect_to] || root_path, alert: "Erro ao adicionar especialidade: #{error_msg}"
    end
  end

  def update
    if @subject.update(subject_params)
      redirect_to params[:redirect_to] || root_path, notice: "Especialidade atualizada para '#{@subject.name}'!"
    else
      error_msg = @subject.errors.full_messages.to_sentence
      redirect_to params[:redirect_to] || root_path, alert: "Erro ao atualizar especialidade: #{error_msg}"
    end
  end

  def destroy
    name = @subject.name
    if @subject.destroy
      redirect_to params[:redirect_to] || root_path, notice: "Especialidade '#{name}' removida com sucesso!"
    else
      error_msg = @subject.errors.full_messages.to_sentence
      redirect_to params[:redirect_to] || root_path, alert: "Erro ao remover especialidade: #{error_msg}"
    end
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name)
  end
end
