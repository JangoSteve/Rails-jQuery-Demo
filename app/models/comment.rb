class Comment < ActiveRecord::Base
  has_attached_file :attachment
  has_attached_file :other_attachment
  validates :subject, :body, :presence => true
  do_not_validate_attachment_file_type :attachment
  do_not_validate_attachment_file_type :other_attachment
end
