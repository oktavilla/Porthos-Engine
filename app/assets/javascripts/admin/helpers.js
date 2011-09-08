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
          to   = "aaoaaaaeeeeiiiioooouuuunncc--    ",
          l    = from.length,
          i    = 0;
      for (i, l; i < l; i++) {
        source = source.replace(new RegExp(from[i], 'g'), to[i]);
      }
      return source.replace(/[^a-zA-Z0-9 \-]/g, '')
                   .replace(/\s+/g, '-')
                   .replace(/\-+/, '-');
    },

    cloneAsUrl: function(source, target) {
      var $source = $(source),
          $target = $(target);
      if ($source.size() === 0 || $target.size() === 0) { return; }
      if($source.val().length > 0 && $target.val().length == 0) { $target.val(Porthos.Helpers.parameterize($source.val())); }
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
    },

    simpleFormat: function(str) {
        fstr = str.replace(/\r\n?/g, "\n")
                  .replace(/\n\n+/g, "</p>\n\n<p>")
                  .replace(/([^\n]\n)(?=[^\n])/g, "$1<br/>");
        return '<p>' + fstr + '</p>';
    }
  };

  Porthos.Helpers.strftime = function(date, format) {
    var options = {
      "day_names": ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],
      "abbr_day_names": ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],
      "month_names": [null,"January","February","March","April","May","June","July","August","September","October","November","December"],
      "abbr_month_names": [null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    }

    if (!options) {
      return date.toString();
    }

    options.meridian = options.meridian || ["AM", "PM"];

    var weekDay = date.getDay(),
        day = date.getDate(),
        year = date.getFullYear(),
        month = date.getMonth() + 1,
        hour = date.getHours(),
        hour12 = hour,
        meridian = hour > 11 ? 1 : 0,
        secs = date.getSeconds(),
        mins = date.getMinutes(),
        offset = date.getTimezoneOffset(),
        absOffsetHours = Math.floor(Math.abs(offset / 60)),
        absOffsetMinutes = Math.abs(offset) - (absOffsetHours * 60),
        timezoneoffset = (offset > 0 ? "-" : "+") + (absOffsetHours.toString().length < 2 ? "0" + absOffsetHours : absOffsetHours) + (absOffsetMinutes.toString().length < 2 ? "0" + absOffsetMinutes : absOffsetMinutes);

    if (hour12 > 12) {
      hour12 = hour12 - 12;
    } else if (hour12 === 0) {
      hour12 = 12;
    }

    var padding = function(n) {
      var s = "0" + n.toString();
      return s.substr(s.length - 2);
    };

    var f = format;
    f = f.replace("%a", options.abbr_day_names[weekDay]);
    f = f.replace("%A", options.day_names[weekDay]);
    f = f.replace("%b", options.abbr_month_names[month]);
    f = f.replace("%B", options.month_names[month]);
    f = f.replace("%d", padding(day));
    f = f.replace("%-d", day);
    f = f.replace("%H", padding(hour));
    f = f.replace("%-H", hour);
    f = f.replace("%I", padding(hour12));
    f = f.replace("%-I", hour12);
    f = f.replace("%m", padding(month));
    f = f.replace("%-m", month);
    f = f.replace("%M", padding(mins));
    f = f.replace("%-M", mins);
    f = f.replace("%p", options.meridian[meridian]);
    f = f.replace("%S", padding(secs));
    f = f.replace("%-S", secs);
    f = f.replace("%w", weekDay);
    f = f.replace("%y", padding(year));
    f = f.replace("%-y", padding(year).replace(/^0+/, ""));
    f = f.replace("%Y", year);
    f = f.replace("%z", timezoneoffset);

    return f;
  };

  $(document).ready(function() {
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

    if ($.fn.hasOwnProperty('chosen')) {
      $('select.choose_me').chosen();
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
