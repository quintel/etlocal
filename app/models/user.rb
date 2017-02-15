class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable

  has_many :dataset_edits
  has_many :sources, through: :dataset_edits
end
