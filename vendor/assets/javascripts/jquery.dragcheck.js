// http://www.seph.dk/jquery-dragcheck/jquery.dragcheck.js
(function(a){a.fn.dragCheck=function(){window.dragCheck_state=null;window.dragCheck_origin=null;this.mousedown(function(){window.dragCheck_state=!this.checked;window.dragCheck_origin=this}).mouseup(function(){window.dragCheck_state=null;window.dragCheck_origin=null}).mouseenter(function(b){null!==window.dragCheck_state&&a(this).add(window.dragCheck_origin).prop("checked",window.dragCheck_state).trigger("change",b)});a(document.body).mouseup(function(){window.dragCheck_state=null;window.dragCheck_origin=
null})}})(jQuery);
