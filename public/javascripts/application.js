;(function($) {
  if (typeof Porthos == "undefined") {
    var Porthos = {};
  }
  Porthos.Helpers = {
    extract_id: new RegExp(/^\d/i),

    extractId: function(string) {
      return string.replace(Porthos.Helpers.extract_id,'');
    },

    parameterize: function(string) {
      var source = $.trim(string.toLowerCase()),
          from = "åäöàáäâèéëêìíïîòóöôùúüûÑñÇç·/_,:;",
          to   = "aaoaaaaeeeeiiiioooouuuunncc------",
          l    = from.length;
      for (var i = 0, l; i < l; i++) {
        source = source.replace(new RegExp(from[i], 'g'), to[i]);
      }
      return source.replace(/[^a-zA-Z0-9 -]/g, '').replace(/\s+/g, '-');
    },

    cloneAsUrl: function(source, target) {
      var $source = $(source),
          $target = $(target);
      if (!$source || !$target) { return; }
      $target.data('clone_from_title', $target.val() == '');
      $source.bind('keyup', function(event) {
        if ($target.data('clone_from_title')) {
          $target.val(Porthos.Helpers.parameterize($source.val()));
        }
      });
      $target.bind('blur', function(event) {
        var value = $target.val();
        if (value != '') {
          if (value != Porthos.Helpers.parameterize($source.val())) {
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
      })
      $('#field_form').find('div.'+field_type).each(function() {
        $('#field_customizations').append(this);
      });
    };

    var Ready = function() {
      var $container = $('#field_types');
      $('#field_type').bind('change', function(event) {
        Switch($(this).val(), $container);
      });
      Switch($('#field_type').val(), $container);
    };

    return {
      init: function() {
        $(document).ready(function() {
          $('#field_form').each(function() {
            Ready(this);
          });
        });
      }
    }
  }());

  Porthos.Page = (function() {
    var Ready = function(container) {
      var $container = $(container),
          $columns_container = $container.find('div.page_layout'),
          page_id = Porthos.Helpers.extractId($columns_container.attr('id')),
          columns = $columns_container.find('div.column').map(function() {
            var $column = $(this);
            $column.delegate('a.add', 'click', function(event) {
              event.preventDefault();
              $(this).toggleClass('active');
              $column.find('div.sub_controls').toggle();
            });

            return {
              container: $column,
              position : Porthos.Helpers.extractId($column.attr('id')),
              element  : $column.find('ul.contents').get(0)
            };
          });

      $container.delegate('div.header a.toggler', 'click', function(event) {
        event.preventDefault();
        $container.find('div.header').toggle();
      });

      Porthos.Helpers.cloneAsUrl('#page_title', '#page_slug');

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
  Porthos.Page.init();

})(jQuery);