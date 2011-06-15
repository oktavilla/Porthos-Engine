(function() {
  var Porthos = {};
  window.Porthos = Porthos;
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
      return source.replace(/[^a-zA-Z0-9 \-]/g, '').replace(/\s+/g, '-').replace(/\-+/, '-');
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

  $(document).ready(function() {
    if ($.fn.hasOwnProperty('ckeditor')) {
      $('textarea.editor').ckeditor();
    }

    Porthos.Helpers.cloneAsUrl('#node_name', '#node_url');
    if ($.fn.hasOwnProperty('sortable')) {
      $('table.sortable tbody').sortable({
        handle: 'span.drag_handle',
        items: 'tr',
        axis: 'y',
        helper: function(e, $row) {
          $row.children().each(function() {
            var $child = $(this),
                width = $child.width();
            $child.width(width);
          });
          return $row;
        }
      }).bind('sortstop', function() {
        var $sortable = $(this),
            sort_uri = $sortable.data('sort-uri');
        if (sort_uri) {
          $.ajax({
            type: 'PUT',
            url: sort_uri,
            data: $sortable.sortable('serialize'),
            dataType: 'json'
          });
        }
      }).disableSelection();
    }
    $('select#order_by').bind('change', function(event) {
      this.form.submit();
    });
    $('#flash').each(function() {
      var $flash = $(this);
      window.setTimeout(function() {
        $flash.slideUp();
      }, 5 * 1000);
    });
  });

  $.ajaxSetup({
    headers: {
      "X-CSRF-Token": $("meta[name='csrf-token']").attr('content')
    }
  });
}).call(this);