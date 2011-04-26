(function() {
	Porthos.Field = (function() {
	  var Switch = function(field_type, $container) {
	    $('#field_customizations div.type').each(function() {
	      $container.append(this);
	    });
	    $('#field_form').find('div.'+field_type).each(function() {
	      $('#field_customizations').append(this);
	    });
	  };

	  var Ready = function() {
	    var $container = $('#field_types'),
	        $type = $('#field_type').bind('change', function(event) {
	          Switch($(this).val(), $container);
	        });
	    Switch($type.val(), $container);
	  };

	  return {
	    init: function() {
	      $(document).ready(function() {
	        $('#field_form').each(function() {
	          Ready(this);
	        });
	      });
	    }
	  };
	})();
	Porthos.Field.init();
}).call(this);