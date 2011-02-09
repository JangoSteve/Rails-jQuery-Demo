// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document)
  .delegate('#new-comment-link', 'ajax:success', function(e, data, status, xhr){
    $(this).replaceWith(xhr.responseText);
  });

