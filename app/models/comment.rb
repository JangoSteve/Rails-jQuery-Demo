class Comment < ActiveRecord::Base
  has_attached_file :attachment
  validates :subject, :body, :presence => true
end
