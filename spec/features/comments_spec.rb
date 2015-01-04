require 'spec_helper'
require 'tempfile'

describe 'comments' do
  it 'creates a new comment', js: true do
    visit root_path
    click_link 'New Comment'

    # New Comment link should disappear
    expect(page).to have_no_link('New Comment')
    # Comment form should appear
    expect(page).to have_field('comment_subject')
    expect(page).to have_field('comment_body')
    expect(page).to have_no_field('comment_file')

    # Filling in form and submitting
    comment_subject = 'A new comment!'
    comment_body = 'Woo, this is my comment, dude.'
    fill_in 'comment_subject', with: comment_subject
    fill_in 'comment_body', with: comment_body
    click_button 'Create Comment'

    # Comment should appear in the comments table
    within '#comments' do
      expect(page).to have_content(comment_subject)
      expect(page).to have_content(comment_body)
    end
    # Form should clear
    expect(page).to have_field('comment_subject', with: '')
    expect(page).to have_field('comment_body', with: '')
    # ...and be replaced by link again
    expect(page).to have_link('Cancel')
  end

  it "cancels creating a comment", js: true do
    visit root_path
    click_link 'New Comment'

    expect(page).to have_field('comment_subject')
    expect(page).to have_link('Cancel')
    click_link 'Cancel'

    # Form should disappear
    expect(page).to have_no_field('comment_subject')
    expect(page).to have_link('New Comment')
  end

  it "deletes a comment", js: true do
    Comment.create(subject: 'The Great Yogurt', body: 'The Schwarz is strong with this one.')

    visit root_path
    within '#comments' do
      expect(page).to have_content('The Great Yogurt')
      accept_js_confirm do
        click_link 'Destroy'
      end

      expect(page).to have_no_content('The Great Yogurt')
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
    expect(page).to have_content('aborted: file')

    page.execute_script("$(document).delegate('form', 'ajax:aborted:file', function() { return true; });")
    click_button 'Create Comment'

    # Comment should appear in the comments table
    within '.comment' do
      expect(page).to have_content(comment_subject)
      expect(page).to have_content(comment_body)
    end
  end

  it "Disables submit button while submitting", js: true do
    visit root_path

    click_link 'New Comment'
    # Needed to make test wait for above to finish
    form = find('form')

    page.execute_script(%q{$('form').append('<input name="pause" type="hidden" value=1 />');})

    button = find_button('Create Comment')

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    click_button 'Create Comment'

    expect(%w(true disabled)).to include(button[:disabled])
    expect(button.value).to eq "Submitting..."

    sleep 1.5

    expect(button[:disabled]).to_not be
    expect(button.value).to eq "Create Comment"
  end
end
