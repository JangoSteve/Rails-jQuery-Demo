require 'spec_helper'
require 'tempfile'

describe 'comments' do
  it 'creates a new comment', js: true do
    visit root_path
    click_link 'New Comment'

    # New Comment link should disappear
    page.should have_no_link('New Comment')
    # Comment form should appear
    page.should have_field('comment_subject')
    page.should have_field('comment_body')
    page.should have_no_field('comment_file')

    # Filling in form and submitting
    comment_subject = 'A new comment!'
    comment_body = 'Woo, this is my comment, dude.'
    fill_in 'comment_subject', with: comment_subject
    fill_in 'comment_body', with: comment_body
    click_button 'Create Comment'

    # Comment should appear in the comments table
    within '#comments' do
      page.should have_content(comment_subject)
      page.should have_content(comment_body)
    end
    # Form should clear
    page.should have_field('comment_subject', with: '')
    page.should have_field('comment_body', with: '')
    # ...and be replaced by link again
    page.should have_link('Cancel')
  end

  it "cancels creating a comment", js: true do
    visit root_path
    click_link 'New Comment'

    page.should have_field('comment_subject')
    page.should have_link('Cancel')
    click_link 'Cancel'

    # Form should disappear
    page.should have_no_field('comment_subject')
    page.should have_link('New Comment')
  end

  it "deletes a comment", js: true do
    Comment.create(subject: 'The Great Yogurt', body: 'The Schwarz is strong with this one.')

    visit root_path
    within '#comments' do
      page.should have_content('The Great Yogurt')
      accept_js_confirm do
        click_link 'Destroy'
      end

      page.should have_no_content('The Great Yogurt')
    end
  end

  it "aborts ajax file upload and submits normally", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    page.execute_script("$(document).delegate('form', 'ajax:aborted:file', function() { $('#comments').after('aborted: file'); return false; });")

    # Filling in form and submitting
    comment_subject = 'A new comment!'
    comment_body = 'Woo, this is my comment, dude.'
    fill_in 'comment_subject', with: comment_subject
    fill_in 'comment_body', with: comment_body
    # Attach file
    file = Tempfile.new('foo')
    attach_file 'comment_attachment', file.path
    click_button 'Create Comment'

    # Comment should appear in the comments table
    page.should have_content('aborted: file')

    page.execute_script("$(document).delegate('form', 'ajax:aborted:file', function() { return true; });")
    click_button 'Create Comment'

    # Comment should appear in the comments table
    within '.comment' do
      page.should have_content(comment_subject)
      page.should have_content(comment_body)
    end
  end
end
