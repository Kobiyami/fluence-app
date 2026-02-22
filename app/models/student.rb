class Student < ApplicationRecord
  has_many :sessions, dependent: :destroy

  validates :first_name, :last_name, :code, presence: true
end