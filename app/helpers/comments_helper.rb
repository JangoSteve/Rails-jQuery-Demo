module CommentsHelper
  def new_comment_link
    link_to 'New Comment', new_comment_path, :remote => true, :'data-type' => 'html', :id => 'new-comment-link'
  end
end
