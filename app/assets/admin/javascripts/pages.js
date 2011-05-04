(function() {
	Porthos.Page = (function() {
	  var Ready = function(container) {
	    var $container = $(container),
	        $content = $('#content'),
	        // page_id = Porthos.Helpers.extractId($columns_container.attr('id')),
	        $sortables = $content.find('ul.sortable');

	    $container.delegate('div.header a.toggler', 'click', function(event) {
	      event.preventDefault();
	      $container.find('div.header').toggle();
	    });

	    $content.delegate('a.new', 'click', function(event) {
	      event.preventDefault();
	      $(this).toggleClass('active').parents('div.content_block').find('div.sub_controls').toggle();
	    });

	    // TODO: Rewrite with nested containments when we have content collections
	    $sortables.find('li').prepend('<span class="draghandle"></span>');
	    $sortables.sortable({
	      handle: 'span.draghandle',
	      connectWith: $sortables,
	      stop: function() {
	        $sortables.each(function() {
	          var $sortable = $(this),
	              params = '&content_block=' + $sortable.data('content-block'),
	              contents = $sortable.sortable('serialize');
	          if (contents === '') {
	            return;
	          }
	          $.ajax({
	            type: 'PUT',
	            url: '/admin/contents/sort',
	            data: contents + params,
	            dataType: 'json'
	          });
	        });
	      }
	    });

      $content.find('div.editable').hide();
	    $content.delegate('div.edit a.change, div.edit a.add, a.cancel', 'click', function(event) {
	      event.preventDefault();
	      var $element = $(this)
        $element.closest('div.datum').find('div.editable, div.viewable').toggle();
	    });

	    $('#page_publish_on_date a.toggle_publish_date, #page_published_on_form a').click(function(event) {
	      event.preventDefault();
	      $('#page_current_publish_on_date, #page_published_on_form').toggle();
	    });

	    $('#page_category').delegate('a.change, a.cancel', 'click', function(event) {
	      event.preventDefault();
	      $('#category_view, #choose_page_category_form').toggle();
	    });

	    $('#new_category, #page_categories_form a').click(function(event) {
	      event.preventDefault();
	      $('#choose_page_category_form, #page_categories_form').toggle();
	    });
	  };

	  return {
	    init: function() {
	      $(document).ready(function() {
	        $('#pages_view.show #workspace').each(function() {
	          Ready(this);
	        });
				  Porthos.Helpers.cloneAsUrl('#page_title', '#page_uri');
	      });
	    }
	  };
	})();

	Porthos.Page.init();
}).call(this);