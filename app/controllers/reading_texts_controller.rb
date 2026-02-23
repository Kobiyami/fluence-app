class ReadingTextsController < ApplicationController
  def index
    @reading_texts = ReadingText.all
  end

  def show
    @reading_text = ReadingText.find(params[:id])
  end
end