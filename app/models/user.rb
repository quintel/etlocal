class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable
end
