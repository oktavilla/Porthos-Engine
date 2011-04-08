;(function($) {
  $.ajaxSetup({
    headers: {
      "X-CSRF-Token": $("meta[name='csrf-token']").attr('content')
    }
  });

  // $.fn.reverse = [].reverse;

  var Porthos = {};
  Porthos.Helpers = {
    extractId: function(string) {
      return string.replace(/[^0-9]+/, '');
    },

    parameterize: function(string) {
      var source = $.trim(string.toLowerCase()),
          from = "åäöàáäâèéëêìíïîòóöôùúüûÑñÇç·/_,:;",
          to   = "aaoaaaaeeeeiiiioooouuuunncc------",
          l    = from.length,
          i    = 0;
      for (i, l; i < l; i++) {
        source = source.replace(new RegExp(from[i], 'g'), to[i]);
      }
      return source.replace(/[^a-zA-Z0-9 \-]/g, '').replace(/\s+/g, '-');
    },

    cloneAsUrl: function(source, target) {
      var $source = $(source),
          $target = $(target);
      if ($source.size() === 0 || $target.size() === 0) { return; }
      $target.data('clone_from_title', $target.val() === '' || $target.val() === Porthos.Helpers.parameterize($source.val()));
      $source.bind('keyup', function(event) {
        if ($target.data('clone_from_title')) {
          $target.val(Porthos.Helpers.parameterize($source.val()));
        }
      });
      $target.bind('blur', function(event) {
        var value = $target.val();
        if (value !== '') {
          if (value !== Porthos.Helpers.parameterize($source.val())) {
            $target.data('clone_from_title', false);
          }
        } else {
          $target.data('clone_from_title', true);
        }
      });
    }
  };

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
  }());

  Porthos.FieldSet = function() {
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
  }();

  Porthos.Page = (function() {
    var Ready = function(container) {
      var $container = $(container),
          $columns_container = $container.find('div.page_layout'),
          page_id = Porthos.Helpers.extractId($columns_container.attr('id')),
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

      $('#page_tags a').click(function(event) {
        event.preventDefault();
        $('#page_tags_list, #page_tags_form').toggle();
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
        });
      }
    };
  }());

  Porthos.Field.init();
  Porthos.FieldSet.init();
  Porthos.Page.init();
  $(document).ready(function() {
    if ($.fn.hasOwnProperty('ckeditor')) {
      $('textarea.editor').ckeditor();
    }
    Porthos.Helpers.cloneAsUrl('#page_title', '#page_slug');
    Porthos.Helpers.cloneAsUrl('#node_name', '#node_url');
    if ($.fn.hasOwnProperty('sortable')) {
      $('table.sortable tbody').sortable({
        handle: 'span.drag_handle',
        items: 'tr',
        axis: 'y'
      });
    }
    $('select#order_by').bind('change', function(event) {
      this.form.submit();
    });
  });

}(jQuery));