class Comment < ActiveRecord::Base
  has_attached_file :attachment
  has_attached_file :other_attachment
  validates :subject, :body, :presence => true
end
