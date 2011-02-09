// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document)
  .delegate('#new-comment-link, #new-comment-attachment-link', 'ajax:success', function(e, data, status, xhr){
    var $this = $(this),
        $container = $('#new-comment-links'),
        $responseText = $(xhr.responseText),
        $cancelButton = $responseText.find('#cancel-button');
    $container.replaceWith($responseText)
    $cancelButton.click(function(e){
      $cancelButton.parent().replaceWith($container);
      e.preventDefault();
    });
  });

