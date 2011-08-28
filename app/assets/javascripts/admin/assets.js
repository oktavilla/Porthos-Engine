#= require "lib/jquery.smart_autocomplete"
#= require "lib/jquery.jcrop.min"
(function() {
  Porthos.Asset = (function() {
    var Cropper = function(image) {
      var $image = $(image);

      var preview = function(coords) {
        var rx = cropped.w / coords.w,
            ry = cropped.h / coords.h;
        $('#preview').css({
          width: Math.ceil(rx * original.w * factor) + 'px',
          height: Math.ceil(ry * original.h * factor) + 'px',
          marginLeft: '-' + Math.ceil(rx * coords.x) + 'px',
          marginTop: '-' + Math.ceil(ry * coords.y) + 'px'
        });
      };

      var computedCoords = function(coords) {
        return {
          w: Math.ceil(coords.w / factor),
          h: Math.ceil(coords.h / factor),
          x: Math.ceil(coords.x / factor),
          y: Math.ceil(coords.y / factor)
        };
      };

      var rendered = {
            w: $image.width(),
            h: $image.height()
          },
          original = {
            w: $image.data('original-width'),
            h: $image.data('original-height')
          },
          cropped = {
            w: $image.data('cropped-width'),
            h: $image.data('cropped-height')
          },
          cutout = {
            w: $image.data('cutout-width'),
            h: $image.data('cutout-height'),
            x: $image.data('cutout-x'),
            y: $image.data('cutout-y')
          };
      var ratio = (cropped.w / cropped.h),
          factor = (rendered.w / original.w),
          max_width, max_height, select_area;

      if (cropped.w > cropped.h) {
        max_width  = rendered.w;
        max_height = (max_width / cropped.w) * cropped.h;
      } else {
        max_width  = (cropped.w / cropped.h) * rendered.h;
        max_height = rendered.h;
      }

      if (cutout.x > 0) {
        select_area = [
          cutout.x * factor,
          cutout.y * factor,
          (cutout.x + cutout.w) * factor,
          (cutout.y + cutout.h) * factor
        ];
      } else {
        var x1 = (rendered.w/2) - (max_width/2),
            y1 = (rendered.h/2) - (max_height/2);
        select_area = [
          x1,
          y1,
          x1 + max_width,
          y1 + max_height
        ];
      }

      $image.Jcrop({
        aspectRatio: ratio,
        minSize: [Math.ceil(cropped.w * factor), Math.ceil(cropped.h * factor)],
        maxSize: [Math.ceil(max_width), Math.ceil(max_height)],
        setSelect: select_area,
        onSelect: function(coords) {
          preview(coords);
        },
        onChange: function(coords) {
          var c = computedCoords(coords)
          $('#cutout_width').val(c.w);
          $('#cutout_height').val(c.h);
          $('#cutout_x').val(c.x);
          $('#cutout_y').val(c.y);
          preview(coords);
        }
      });
    };

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

      $('#content').delegate('ul.items img', 'click', function(event) {
        if (event.target.nodeName !== 'IMG') { return; }
        event.preventDefault();
        $(event.currentTarget).parents('li').find('form').trigger('submit');
      }).delegate('ul.items img', 'hover', function(event) {
        $(event.currentTarget).parents('li').toggleClass('over');
      });

      $('#cropped_image').each(function() {
        if (this.complete === true) {
          Cropper(this);
        } else {
          $(this).bind('load', function() {
            Cropper(this);
          });
        }
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