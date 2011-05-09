(function() {
  $(document).ready(function() {
    var $navigation = $('#navigation');
    $navigation.find('ul').each(function() {
      var $list = $(this);
      $list.sortable({
        axis: 'y',
        stop: function() {
          $.ajax({
            type: 'PUT',
            url: $navigation.data('sort-uri'),
            data: $list.sortable('serialize'),
            dataType: 'json'
          });
        }
      });
    });
  });
}).call(this);