class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable

  has_many :commits
  has_many :dataset_edits, through: :commits
  has_many :sources, through: :commits
end
