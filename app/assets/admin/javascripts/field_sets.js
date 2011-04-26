(function() {
	Porthos.FieldSet = (function() {
	  var Ready = function() {
	    $('#field_sets').bind('sortstop', function() {
	      $.ajax({
	        type: 'PUT',
	        url: '/admin/field_sets/sort',
	        data: $(this).sortable('serialize'),
	        dataType: 'json'
	      });
	    });

	    $('#fields').bind('sortstop', function() {
	      var $list = $(this),
	          field_set_id = Porthos.Helpers.extractId($list.parent('table').attr('id'));
	      $.ajax({
	        type: 'PUT',
	        url: '/admin/field_sets/'+field_set_id+'/fields/sort',
	        data: $(this).sortable('serialize'),
	        dataType: 'json'
	      });
	    });

	    $('#pages.sortable').sortable({
	      axis: 'y',
	      handle: 'span.drag_handle',
	      stop: function() {
	        $.ajax({
	          type: 'PUT',
	          url: '/admin/pages/sort',
	          data: $(this).sortable('serialize'),
	          dataType: 'json'
	        });
	      }
	    });
	  };

	  return {
	    init: function() {
	      $(document).ready(Ready);
	    }
	  };
	})();
	Porthos.FieldSet.init();
}).call(this);