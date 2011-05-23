#= require "lib/jquery.smart_autocomplete"
(function() {
  Porthos.Page = (function() {
    var Ready = function(container) {
      var $container = $(container),
          $content = $('#content'),
          $sortables = $content.find('ul.sortable');

      $content.find('form.datum_edit').not('.image_form').append('<div class="edit"><a href="#" class="change">Ändra</a></div>');
      $content.find('div.editable').hide().find('div.submit').append('eller <a href="#" class="cancel">avbryt</a>');
      $content.delegate('a.change, a.cancel', 'click', function(event) {
        event.preventDefault();
        $(this).parents('form, div.image').find('div.editable, div.viewable, div.edit').toggle();
      });
      if (window.location.hash.match(/\_edit/)) {
        $(window.location.hash).each(function() {
          $(this).find('a.change').click();
        });
      }

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

      $('#page_tags_form').hide().find('div.submit').append('eller <a href="#" class="cancel">avbryt</a>');
      $('#page_tags').delegate('a.edit, a.cancel', 'click', function() {
        $('#page_tags_list, #page_tags_form').toggle();
      }).find('#page_tags_list').append('<p><a href="#" class="edit">Ändra</a></p>');
      $('#page_tag_names').smartAutoComplete({minCharLimit: 3, source: '/admin/tags.json?taggable=Page'});
      $('#page_tag_names').bind({
        keyIn: function(ev){
                 var tag_list = ev.smartAutocompleteData.query.split(" "); 
                 ev.smartAutocompleteData.query = $.trim(tag_list[tag_list.length - 1]);
               },
        itemSelect: function(ev, selected_item){ 
                      var options = $(this).smartAutoComplete();
                      var selected_value = $(selected_item).text();
                      var cur_list = $(this).val().split(" "); 

                      cur_list[cur_list.length - 1] = selected_value;
                      $(this).val(cur_list.join(" ") + " "); 
                      options.setItemSelected(true);
                      $(this).trigger('lostFocus');
                      ev.preventDefault();
                    },

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
