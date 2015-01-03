module IntegrationHelper
  # If you do something that triggers a confirm, do it inside an accept_js_confirm or reject_js_confirm block
  def accept_js_confirm
    page.evaluate_script 'window.original_confirm_function = window.confirm;'
    page.evaluate_script 'window.confirm = function(msg) { return true; }'
    yield
    page.evaluate_script 'window.confirm = window.original_confirm_function;'
  end

  # If you do something that triggers a confirm, do it inside an accept_js_confirm or reject_js_confirm block
  def reject_js_confirm
    page.evaluate_script 'window.original_confirm_function = window.confirm;'
    page.evaluate_script 'window.confirm = function(msg) { return false; }'
    yield
    page.evaluate_script 'window.confirm = window.original_confirm_function;'
  end
end

RSpec.configure do |config|
  config.include IntegrationHelper
end