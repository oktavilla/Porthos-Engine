#= require "lib/jquery.smart_autocomplete"
(function() {
  Porthos.Asset = (function() {
    var Ready = function(container) {
      $('#asset_tag_names').smartAutoComplete({
        minCharLimit: 3,
        source: '/admin/tags/autocomplete.json?taggable=ImageAsset'
      });
      $('#asset_tag_names').bind({
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

      $('#search_query').smartAutoComplete({
        minCharLimit: 3,
        source: '/admin/tags/autocomplete.json?taggable=Asset'
      });

      $('#content').delegate('ul.items img', 'click', function(event) {
        if (event.target.nodeName !== 'IMG') { return; }
        event.preventDefault();
        $(event.currentTarget).parents('li').find('form').trigger('submit');
      }).delegate('ul.items img', 'hover', function(event) {
        $(event.currentTarget).parents('li').toggleClass('over');
      });
    };
    return {
      init: function() {
        $(document).ready(function() {
          $('#assets_view #workspace').each(function() {
            Ready(this);
          });
        });
      }
    };
  })();
  Porthos.Asset.init();
}).call(this);