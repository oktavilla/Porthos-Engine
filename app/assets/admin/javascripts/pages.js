(function() {
	Porthos.Page = (function() {
	  var Ready = function(container) {
	    var $container = $(container),
	        $columns_container = $container.find('div.page_layout'),
	        // page_id = Porthos.Helpers.extractId($columns_container.attr('id')),
	        $sortables = $columns_container.find('ul.sortable');

	    $container.delegate('div.header a.toggler', 'click', function(event) {
	      event.preventDefault();
	      $container.find('div.header').toggle();
	    });

	    $columns_container.delegate('a.add', 'click', function(event) {
	      event.preventDefault();
	      $(this).toggleClass('active').parents('div.column').find('div.sub_controls').toggle();
	    });

	    // TODO: Rewrite with nested containments when we have content collections
	    $sortables.sortable({
	      handle: 'span.draghandle',
	      connectWith: $sortables,
	      stop: function() {
	        $sortables.each(function() {
	          var $sortable = $(this),
	              params = '&column_position=' + $sortable.data('column'),
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

	    $('#content').delegate('div.edit a.change, div.edit a.add, a.cancel', 'click', function(event) {
	      event.preventDefault();
	      var $element = $(this),
	          $parent  = $element.closest('div.page_content'),
	          query    = 'form';
	      if (!$parent.hasClass('one_to_many')) {
	        query += ', div.container';
	      }
	      $parent.find(query).toggle();
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