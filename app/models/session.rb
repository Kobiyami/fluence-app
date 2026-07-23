class Session < ApplicationRecord
  belongs_to :student
  belongs_to :reading_text

  attribute :aborted, :boolean, default: false

end
