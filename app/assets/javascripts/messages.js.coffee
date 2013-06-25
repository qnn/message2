# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ($) ->
  on_checkbox_change = ->
    if ($("input[name='visible_to[]']:checked").length==0)
      $("#make_public").hide();
    else
      $("#make_public").show();
  if $("#make_public").length > 0 && $("input[name='visible_to[]']").length > 0
    $("#make_public").click ->
      $("input[name='visible_to[]']").prop("checked", false);
      on_checkbox_change();
    $("input[name='visible_to[]']").change(on_checkbox_change).trigger('change');
  $("#notice, #alert").delay(5000).fadeOut 200, ->
    $(this).remove();
