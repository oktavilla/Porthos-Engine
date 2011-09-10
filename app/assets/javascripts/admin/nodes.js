(function() {
  $(document).ready(function() {
    var $navigation = $('#navigation');
    Porthos.Helpers.cloneAsUrl('#node_name', '#node_slug');

    $navigation.sortables = function() {
      if($navigation.hasClass('sortable')){
        return $navigation.find('ul');
      } else {
        return $([]);
      }
    }

    $navigation.setupSortables = function() {
      this.sortables().each(function() {
        var $list = $(this);
        $list.sortable({
          items: 'li',
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
    }

    $navigation.teardownSortables = function() {
      this.sortables().each(function() {
        $(this).sortable('destroy');
      });
    }

    $navigation.setupSortables();

    $navigation.find('a.toggle_handle').live('click', function(event) {
      event.preventDefault();

      $handle = $(this);
      $parent = $($handle.parents('li')[0]);
      $children = $($parent.children('ul')[0]);

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
                $navigation.teardownSortables();
                $navigation.setupSortables();
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
