#= require "lib/jquery.smart_autocomplete"
(function() {
  Porthos.Item = (function() {
    var Ready = function(container) {
      var $container = $(container),
          $content = $('#content'),
          $sortables = $content.find('ul.sortable');

      $content.find('.datum .controls').not('.datum.asset_association .controls').append('<div class="edit"><a href="#" class="change">Ändra</a></div>');
      $content.find('div.editable').hide().find('div.submit').append('eller <a href="#" class="cancel">avbryt</a>');
      $content.delegate('a.change, a.cancel', 'click', function(event) {
        event.preventDefault();
        $(this).parents('.datum, div.asset_association').find('.content > div.editable, .content > div.viewable, div.edit').toggle();
      });
      if (window.location.hash.match(/\_edit/)) {
        $(window.location.hash.replace(/\_edit/, '') + ' a.change').click();
      }

      $content.find('form.datum_edit').submit(function(event) {

        var updateView = function(datum) {
          var $datum = $('#datum_'+datum.id+' div.viewable');

          if (datum['_type'].match(/Association/)) {
            $('#datum_'+datum.id+' div.title').html($form.find('select option:selected').text());
          } else {
            switch(datum['_type']) {
              case 'StringField':
                if (datum.multiline && !datum.allow_rich_text) {
                  $datum.html(Porthos.Helpers.simpleFormat(datum.value));
                } else {
                  $datum.html(datum.value);
                }
                break;
              case 'Field':
                switch(datum.input_type) {
                  case 'date':
                    var date = new Date(Date.parse(datum.value));
                    $datum.html(Porthos.Helpers.strftime(date, "%Y-%m-%d"));
                    break;
                  case 'boolean':
                    $datum.html(!!datum.value ? 'Ja' : 'Nej');
                    break;
                }
                break;
              case 'FieldSet':
                var i = 0,
                    j = datum.data.length;
                for (i=0; i<j; i++) {
                  updateView(datum.data[i]);
                }
                break;
            }
          }
        };

        var disableForm = function(form) {
          form.find('input, textarea, select, checkbox, radio').attr('disabled', 'disabled');
        };

        var enableForm = function(form) {
          form.find('input, textarea, select, checkbox, radio').removeAttr('disabled');
        };

        event.preventDefault();
        var $form = $(this);
        $.ajax($form.attr('action'), {
          context: $form.parents('.datum'),
          dataType: 'json',
          data: $form.serialize(),
          type: 'PUT',
          success: function(datum, status) {
            updateView(datum);
            $(this).find('a.cancel').trigger('click');
            enableForm($form);
          }
        });
        disableForm($form);
      });

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
      $sortables.find('li .controls').prepend('<span class="draghandle"></span>');
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
      $('#page_tags').delegate('a.edit, a.cancel', 'click', function(event) {
        event.preventDefault();
        $('#page_tags_list, #page_tags_form').toggle();
      }).find('#page_tags_list').append('<p><a href="#" class="edit">Ändra</a></p>');
      $('#item_tag_names').smartAutoComplete({minCharLimit: 3, source: '/admin/tags/autocomplete.json?taggable=Page'});
      $('#item_tag_names').bind({
        keyIn: function(ev) {
          var tag_list = ev.smartAutocompleteData.query.split(" ");
          ev.smartAutocompleteData.query = $.trim(tag_list[tag_list.length - 1]);
        },
        itemSelect: function(ev, selected_item) {
          var options = $(this).smartAutoComplete();
          var selected_value = $(selected_item).text();
          var cur_list = $(this).val().split(" ");

          cur_list[cur_list.length - 1] = selected_value;
          $(this).val(cur_list.join(" ") + " ");
          options.setItemSelected(true);
          $(this).trigger('lostFocus');
          ev.preventDefault();
        }
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

      $link_fields = $content.find('div.link_field_form');
      if ($link_fields.size() > 0) {
        var selects = [],
            $master_select = $('<select style="width:450px"></select>');
        $link_fields.each(function() {
          var $container = $(this),
              $resource_id = $container.find('input.resource_id'),
              $resource_type = $container.find('input.resource_type'),
              $select = $master_select.clone().appendTo($container).chosen().bind('change', function(event) {
                var $selected = $(this).find(':selected');
                $resource_id.val($selected.val());
                $resource_type.val($selected.data('resource-type'));
              });
          $container.find('div.link_field_resource').hide();
          selects.push($select);
        });
        $.getJSON('/admin/nodes', function(data) {
          var options = '<optgroup label="Nodes">',
              page_types = ['Page', 'Section', 'CustomPage'];
          $.each(data, function(i, node) {
            if ($.inArray(node['resource_type'], page_types) === -1) {
              options += '<option data-resource-type="Node" value="'+node['id']+'">'+node['name']+'</option>';
            }
          });
          options += '</optgroup>';
          $.each(selects, function(i, $select) {
            $select.append(options).trigger('liszt:updated');
          });
        });

        $.getJSON('/admin/page_templates', function(data) {
          var types = {
            'none': {
              title: 'Anpassade sidor',
              options: ''
            }
          };
          $.each(data, function(i, type) {
            types[type.id] = {
              title: type.label,
              options: ''
            };
          });
          $.getJSON('/admin/items', function(data) {
            $.each(data, function(i, item) {
              var option = '<option data-resource-type="'+item['_type']+'" value="'+item['id']+'">'+item['title']+'</option>';
              if (item['_type'] === 'Page') {
                types[item.page_template_id].options += option
              } else if (item['_type'] === 'CustomPage') {
                types['none'].options += option;
              }
            });
            var optgroups = '';
            $.each(types, function(i, type) {
              optgroups += '<optgroup label="'+type.title+'">'+type.options+'</optgroup>';
            });

            $.each(selects, function(i, $select) {
              $select.append(optgroups).trigger('liszt:updated');
            });
          });
        });
      }
    };

    return {
      init: function() {
        $(document).ready(function() {
          $('#items_view.show #workspace').each(function() {
            Ready(this);
          });
          Porthos.Helpers.cloneAsUrl('#item_title', '#item_uri');
        });
      }
    };
  })();

  Porthos.Item.init();
}).call(this);