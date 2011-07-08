#= require "lib/jquery.smart_autocomplete"
#= require "lib/jquery.jcrop.min"
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

      $('#cropped_image').load(function(){
        var image = $(this);

        var rendered_width = image.width();
        var rendered_height = image.height();
        var cropped_width = image.data('cropped-width');
        var cropped_height = image.data('cropped-height');
        var cutout_width = image.data('cutout-width');
        var cutout_height = image.data('cutout-height');
        var cutout_x = image.data('cutout-x');
        var cutout_y = image.data('cutout-y');

        var factor = (rendered_width/image.data('original-width'));

        if(cropped_width > cropped_height){
          var max_width = rendered_width;
          var max_height  = (max_width/cropped_width)*cropped_height;
        }else{
          var max_width  = (cropped_width/cropped_height)*rendered_height;
          var max_height = rendered_height;
        }

        var select_area;
        if(cutout_x > 0){
          select_area = [
            cutout_x*factor, cutout_y*factor,
            (cutout_x+cutout_width)*factor, (cutout_y+cutout_height)*factor ]
        }else{
          var x1 = (rendered_width/2)-(max_width/2);
          var y1 = (rendered_height/2)-(max_height/2);
          select_area = [
            x1, y1,
            x1+max_width, y1+max_height ];
        }

        image.Jcrop({
          'aspectRatio': cropped_width/cropped_height,
          'minSize' : [Math.ceil(cropped_width*factor),Math.ceil(cropped_height*factor)],
          'maxSize' : [Math.ceil(max_width),Math.ceil(max_height)],
          'setSelect' : select_area,
          'onChange' : function(c){
            $('#cutout_width').val(Math.ceil(c['w']/factor));
            $('#cutout_height').val(Math.ceil(c['h']/factor));
            $('#cutout_x').val(Math.ceil(c['x']/factor));
            $('#cutout_y').val(Math.ceil(c['y']/factor));
          }
        });
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
