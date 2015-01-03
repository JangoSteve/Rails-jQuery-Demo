class Comment < ActiveRecord::Base
  has_attached_file :attachment
  validates :subject, :body, :presence => true
  do_not_validate_attachment_file_type :attachment
end
