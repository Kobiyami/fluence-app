class ReadingTextsController < ApplicationController
  def index
    @texts = ReadingText.all
  end

  def show
    @text = ReadingText.find(params[:id])
  end
end