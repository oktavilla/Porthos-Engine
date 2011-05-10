(function() {
	Porthos.Page = (function() {
	  var Ready = function(container) {
	    var $container = $(container),
	        $content = $('#content'),
	        $sortables = $content.find('ul.sortable');

      $content.find('div.viewable').append('<div class="edit"><a href="#" class="change">Ändra</a></div>');
      $content.find('div.editable').hide().find('div.submit').append('eller <a href="#" class="cancel">avbryt</a>');

      if ($.fn.hasOwnProperty('ckeditor')) {
        $('textarea.editor').ckeditor();
      }

      $('input.date').datepicker({
        dateFormat: 'yy-mm-dd'
      });

      $content.find('div.controls ul').hide();

	    $content.delegate('h3.new', 'click', function(event) {
	      event.preventDefault();
	      $(this).toggleClass('active').parents('div.controls').find('ul').toggle();
	    });


	    $container.delegate('div.header a.toggler', 'click', function(event) {
	      event.preventDefault();
	      $container.find('div.header').toggle();
	    });

	    // TODO: Rewrite with nested containments when we have content collections
	    $sortables.find('li').prepend('<span class="draghandle"></span>');
	    $sortables.sortable({
	      handle: 'span.draghandle',
	      connectWith: $sortables,
	      axis: 'y',
	      stop: function() {
	        $sortables.each(function() {
	          var $sortable = $(this),
	              contents = $sortable.sortable('serialize');
	          if (contents === '') {
	            return;
	          }
	          $.ajax({
	            type: 'PUT',
	            url: $sortable.data('sort-uri'),
	            data: contents,
	            dataType: 'json'
	          });
	        });
	      }
	    });

	    $content.delegate('a.change, a.add, a.cancel', 'click', function(event) {
	      event.preventDefault();
	      var $element = $(this)
        $element.closest('div.datum').find('div.editable, div.viewable').toggle();
	    });

      $('#page_tags_form').hide().find('div.submit').append('eller <a href="#" class="cancel">avbryt</a>');
      $('#page_tags').delegate('a.edit, a.cancel', 'click', function() {
        $('#page_tags_list, #page_tags_form').toggle();
      }).find('#page_tags_list').append('<p><a href="#" class="edit">Ändra</a></p>');

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