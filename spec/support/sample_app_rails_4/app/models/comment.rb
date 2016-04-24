class Comment < ActiveRecord::Base

  has_many :user_comments
  has_many :users, through: :user_comments
end
