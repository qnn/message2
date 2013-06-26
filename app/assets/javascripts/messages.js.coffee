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
  $("input[type=submit]").prop("disabled", true);
  $("a[data-method=delete]").addClass("disabled");
  setTimeout ->
    $("input[type=submit]").prop("disabled", false);
    $("a[data-method=delete]").removeClass("disabled");
  , 2000
  if $("input[name='messages[]']").length>0
    $("a[data-form2submit]").addClass("disabled");
    $("a[data-form2submit]").click ->
      if !$(this).hasClass("disabled")&&confirm($(this).data("fconfirm"))
        $($(this).data("form2submit")).submit();
    $("input[name='messages[]']").change ->
      if ($(this).prop("checked"))
        $(this).closest("tr").addClass("checked")
      else
        $(this).closest("tr").removeClass("checked")
      checked = $("input[name='messages[]']:checked").length
      if (checked==0)
        $("a[data-form2submit]").addClass("disabled");
        $("#msgs_select").prop('checked', false)
      else
        $("a[data-form2submit]").removeClass("disabled");
        if checked == $("input[name='messages[]']").length
          $("#msgs_select").prop('checked', true)
    .click ->
      $(this).prop("checked", !$(this).prop("checked"))
    .dragCheck();
    $("tr.msgcb").click ->
      cb = $(this).find("input[name='messages[]']")
      cb.prop("checked", !cb.prop("checked")).trigger('change');
    $("#msgs_select").change ->
      $("input[name='messages[]']").prop("checked", $(this).prop("checked")).trigger('change');
