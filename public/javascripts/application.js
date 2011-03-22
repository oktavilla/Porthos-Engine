;(function($) {
  if (typeof Porthos == "undefined") {
    var Porthos = {};
  }
  Porthos.Helpers = {
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
})(jQuery);