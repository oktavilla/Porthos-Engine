(function() {
  Porthos.DatumTemplates = (function() {
    var Ready = function() {
      $('#datum_templates').bind('sortstop', function() {
        var $datum_template = $(this);
        console.log($datum_template);
        $.ajax({
          type: 'PUT',
          url: $datum_template.data('sort-uri'),
          data: $datum_template.sortable('serialize'),
          dataType: 'json'
        });
      });

      $('#datum_template').bind('sortstop', function() {
        var $datum_template = $(this)
        $.ajax({
          type: 'PUT',
          url: $datum_template.data('sort-uri'),
          data: $datum_template.sortable('serialize'),
          dataType: 'json'
        });
      });
    };

    return {
      init: function() {
        $(document).ready(Ready);
      }
    };
  })();
  Porthos.DatumTemplates.init();
}).call(this);