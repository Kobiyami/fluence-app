class MotOutilsController < ApplicationController
  def index
    @mot_outils = MotOutil.order(:text)
    @mot_outil = MotOutil.new
  end

  def create
    @mot_outil = MotOutil.new(mot_outil_params)
    if @mot_outil.save
      redirect_to mot_outils_path, notice: "Mot ajouté."
    else
      @mot_outils = MotOutil.order(:text)
      render :index, status: :unprocessable_entity
    end
  end
  
def destroy
  @mot_outil = MotOutil.find(params[:id])
  @mot_outil.destroy
  redirect_to mot_outils_path, notice: "Mot supprimé."
end

  private

  def mot_outil_params
    params.require(:mot_outil).permit(:text)
  end
end