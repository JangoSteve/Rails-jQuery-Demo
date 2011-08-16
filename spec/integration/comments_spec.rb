require 'spec_helper'

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
    # Form should disappear
    page.should have_no_field('comment_subject')
    page.should have_no_field('comment_body')
    # ...and be replaced by link again
    page.should have_link('New Comment')
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

  it "uploads a file", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    page.should have_field('comment_subject')
    page.should have_field('comment_body')
    page.should have_field('comment_attachment')
    page.should have_field('comment_other_attachment')

    comment_subject = 'Newby'
    comment_body = 'Woot, a file!'
    fill_in 'comment_subject', with: comment_subject
    fill_in 'comment_body', with: comment_body

    # Attach file
    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    other_file_path = File.join(Rails.root, 'spec/fixtures/hi.txt')
    attach_file 'comment_attachment', file_path
    attach_file 'comment_other_attachment', other_file_path

    page_should_not_redirect do
      click_button 'Create Comment'
    end

    within '#comments' do
      page.should have_content(comment_subject)
      page.should have_content(comment_body)
      page.should have_content(File.basename(file_path))
      page.should have_content(File.basename(other_file_path))
    end
  end

  it "triggers ajax:remotipartSubmit event hook", js: true do
    visit root_path
    page.execute_script("$('form').live('ajax:remotipartSubmit', function() { $('#comments').after('remotipart!'); });")

    click_link 'New Comment with Attachment'

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', File.join(Rails.root, 'spec/fixtures/qr.jpg')
    click_button 'Create Comment'

    page.should have_content('remotipart!')
  end

  it "allows remotipart submission to be cancelable via event hook", js: true do
    visit root_path
    page.execute_script("$('form').live('ajax:remotipartSubmit', function() { $('#comments').after('remotipart!'); return false; });")

    click_link 'New Comment with Attachment'

    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_content('remotipart!')

    within '#comments' do
      page.should have_no_content('Hi')
      page.should have_no_content('there')
      page.should have_no_content(File.basename(file_path))
    end
  end

  it "allows custom data-type on form", js: true do
    visit root_path
    page.execute_script("$('form').live('ajax:success', function(evt, data, status, xhr) { $('#comments').after(xhr.responseText); });")

    click_link 'New Comment with Attachment'
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_content('HTML response')
  end

  it "does not submit via remotipart unless file is present", js: true do
    visit root_path
    page.execute_script("$('form').live('ajax:remotipartSubmit', function() { $('#comments').after('remotipart!'); });")

    click_link 'New Comment with Attachment'

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    click_button 'Create Comment'

    page.should have_no_content('remotipart!')
  end

  it "fires all the ajax callbacks on the form", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    page.execute_script("$('form').bind('ajax:beforeSend', function() { $('#comments').after('thebefore'); });")
    page.execute_script("$('form').live('ajax:success', function() { $('#comments').after('success'); });")
    page.execute_script("$('form').live('ajax:complete', function() { $('#comments').after('complete'); });")

    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_content('before')
    page.should have_content('success')
    page.should have_content('complete')
  end

  it "only fires the beforeSend hook once", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    page.execute_script("$('form').bind('ajax:beforeSend', function() { $('#comments').after('<div class=\"ajax\">ajax!</div>'); });")

    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_css("div.ajax", :count => 1)
  end

  it "cleans up after itself when uploading files", js: true do
    visit root_path
    page.execute_script("$('form').live('ajax:remotipartSubmit', function(evt, xhr, data) { if ($(this).data('remotipartSubmitted')) { $('#comments').after('remotipart before!'); } });")

    click_link 'New Comment with Attachment'
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_content('remotipart before!')

    page.execute_script("if (!$('form').data('remotipartSubmitted')) { $('#comments').after('no remotipart after!'); } ")
    page.should have_content('no remotipart after!')
  end

  it "only submits via remotipart when a file upload is present", js: true do
    visit root_path
    page.execute_script("$('form').live('ajax:remotipartSubmit', function(evt, xhr, data) { $('#comments').after('<div class=\"remotipart\">remotipart!</div>'); });")

    click_link 'New Comment with Attachment'
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(Rails.root, 'spec/fixtures/qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_css("div.remotipart", :count => 1)

    # replace form html, in order clear out the file field (couldn't think of a better way)
    page.execute_script("inputs = $('form').find(':file'); inputs.remove();")
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    click_button 'Create Comment'

    page.should have_css("div.remotipart", :count => 1)

    page.execute_script("$('form').append(inputs);")
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    page.should have_css("div.remotipart", :count => 2)
  end
end
