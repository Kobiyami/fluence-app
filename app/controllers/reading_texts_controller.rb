class ReadingTextsController < ApplicationController
  def index
    @reading_texts = ReadingText.order(created_at: :desc)
    @reading_text = ReadingText.new
  end

  def show
    @reading_text = ReadingText.find(params[:id])
  end

  def create
    @reading_text = ReadingText.new(reading_text_params)
    @reading_text.word_count = @reading_text.content.to_s.split.size
    if @reading_text.save
      redirect_to reading_texts_path, notice: "Texte ajouté."
    else
      @reading_texts = ReadingText.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

def update
  @reading_text = ReadingText.find(params[:id])
  @reading_text.assign_attributes(reading_text_params)
  @reading_text.word_count = @reading_text.content.to_s.split.size
  if @reading_text.save
    redirect_to reading_texts_path, notice: "Texte mis à jour."
  else
    render :show, status: :unprocessable_entity
  end
end

  def destroy
    @reading_text = ReadingText.find(params[:id])
    @reading_text.destroy
    redirect_to reading_texts_path, notice: "Texte supprimé."
  end

  private

  def reading_text_params
    params.require(:reading_text).permit(:title, :content)
  end
end