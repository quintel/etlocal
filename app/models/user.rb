class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable

  belongs_to :group, optional: true

  has_many :commits
  has_many :dataset_edits, through: :commits

  validates_presence_of :email
  validates_email_format_of :email
  validates_uniqueness_of :email
  validates_presence_of :name
  validates :password, presence: true, confirmation: true

  def self.robot
    @robot ||= find_by_email("robot@quintel.com")
  end
end
