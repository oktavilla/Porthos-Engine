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

    $('a.toggle_handle').click(function(event) {
      event.preventDefault();

      $handle = $(this);
      $parent = $($handle.parents('li'));
      $children = $($parent.children('ul'));

      switch($handle.text()){
        case '+':
          if($children.size() > 0){
            $children.show();
          } else {
            $.ajax({
              type: 'GET',
              url: $handle.attr('href'),
              data: { 'partial': true },
              dataType: 'html',
              success: function(response){
                $parent.append(response);
              }
            });
          }
          $handle.text('-');
          break;
        case '-':
          $handle.text('+');
          $children.hide();
          break;
      }
    });
  });
}).call(this);
