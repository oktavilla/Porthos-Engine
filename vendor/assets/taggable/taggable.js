(function() {
  var $, Taggable, methods, root;
  var __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  root = this;
  $ = jQuery;
  $.taggable = {
    instances: new Array(),
    destroyAll: function() {
      var element, _i, _len, _ref, _results;
      _ref = $.taggable.instances;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        _results.push(element.taggable('destroy'));
      }
      return _results;
    }
  };
  methods = {
    init: function(options) {
      var settings;
      settings = {
        delimiter: ',',
        string_wrap: null
      };
      settings = $.extend(settings, options);
      return this.each(function() {
        var element, taggable;
        element = $(this);
        taggable = element.data('taggable');
        if (!taggable) {
          element.data('taggable', new Taggable(element, settings));
          return $.taggable.instances.push(element);
        }
      });
    },
    destroy: function() {
      return this.each(function() {
        var element, index, instances, taggable;
        element = $(this);
        taggable = element.data('taggable');
        instances = $.taggable.instances.map(function(thing) {
          return thing.get(0);
        });
        index = $.inArray(this, instances);
        if (index !== -1) {
          taggable.destroy();
          delete $.taggable.instances[index];
          delete taggable;
          return element.removeData('taggable');
        }
      });
    }
  };
  $.fn.taggable = function() {
    var method, options;
    method = arguments[0], options = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (typeof methods[method] === 'function') {
      return methods[method].apply(this, options);
    } else if (typeof method === 'object' || !(method != null)) {
      return methods.init.apply(this, arguments);
    } else {
      return $.error('Method ' + method + ' does not exist on jQuery.taggable');
    }
  };
  Taggable = (function() {
    function Taggable(field, options) {
      this.original = $(field);
      this.options = $.extend({
        delimiter: this.original.data('delimiter') || ',',
        onChange: function() {}
      }, options || {});
      this._id = this.generate_random_id();
      this._tags = [];
      this.setup();
      this.setup_observers();
    }
    Taggable.prototype.setup = function() {
      var computed_styles, existing_tags, style, styles, tag, _i, _j, _len, _len2;
      this.original.data('original-position', {
        position: this.original.css('position'),
        left: this.original.css('left'),
        top: this.original.css('top'),
        visibility: this.original.css('visibility')
      });
      this.original.css({
        position: 'absolute',
        left: '-100000px',
        top: '0px',
        visibility: 'hidden'
      });
      styles = ['font-size', 'font-style', 'font-weight', 'font-family', 'line-height', 'text-transform', 'letter-spacing', 'box-sizing'];
      computed_styles = {};
      for (_i = 0, _len = styles.length; _i < _len; _i++) {
        style = styles[_i];
        computed_styles[style] = this.original.css(style);
      }
      this.container = $('<div />', {
        id: this._id,
        "class": "taggable_container"
      }).css({
        'max-width': "" + (this.original.width()) + "px",
        'min-height': "" + (this.original.height()) + "px",
        position: 'relative'
      });
      this.input = $('<input />', {
        type: 'text',
        name: 'taggable',
        autocomplete: 'off'
      }).css(computed_styles).css({
        width: "" + (this.original.width()) + "px",
        background: 'transparent',
        position: 'absolute',
        top: this.container.css('paddingTop'),
        left: this.container.css('paddingLeft'),
        border: 'none',
        outline: 'none'
      }).appendTo(this.container);
      this.container.insertAfter(this.original);
      existing_tags = $.trim(this.original.val()).split(this.options.delimiter).map(function(value) {
        return $.trim(value);
      });
      if (existing_tags.length !== 0) {
        for (_j = 0, _len2 = existing_tags.length; _j < _len2; _j++) {
          tag = existing_tags[_j];
          this.add_tag(tag);
        }
      }
      return 'done';
    };
    Taggable.prototype.setup_observers = function() {
      this.input.keydown(__bind(function(event) {
        return this.keydown_checker(event);
      }, this));
      this.input.keyup(__bind(function(event) {
        return this.keyup_checker(event);
      }, this));
      this.input.keypress(__bind(function(event) {
        return this.keypress_checker(event);
      }, this));
      this.input.blur(__bind(function(event) {
        return this.add_tag(this.input.val());
      }, this));
      return this.container.delegate('a', 'click.taggable', __bind(function(event) {
        var matched_tags, tag_id;
        event.preventDefault();
        tag_id = $(event.currentTarget).parent('span').attr('id');
        matched_tags = this._tags.filter(function(tag) {
          return tag.id === tag_id;
        });
        if (matched_tags.length > 0) {
          return this.remove_tag(matched_tags[0]);
        }
      }, this)).bind('click.taggable', __bind(function(event) {
        event.preventDefault();
        return this.input.focus();
      }, this));
    };
    Taggable.prototype.scale = function() {
      var left, position, tag_element, top;
      if (this._tags.length > 0) {
        tag_element = this.last_tag().element();
        position = tag_element.position();
        left = position.left + tag_element.outerWidth() + parseInt(tag_element.css('margin-right'), 10);
        top = position.top;
        if (left >= (this.container.innerWidth() - 30)) {
          left = parseInt(this.container.css('paddingLeft'), 10);
          top += tag_element.outerHeight() + parseInt(tag_element.css('marginBottom'), 10);
        }
      } else {
        top = 0;
        left = 0;
      }
      return this.input.css({
        top: "" + top + "px",
        left: "" + left + "px"
      });
    };
    Taggable.prototype.keydown_checker = function(event) {
      var added_height, available_width, stroke, tmp_tag, width, _ref;
      stroke = (_ref = event.which) != null ? _ref : event.keyCode;
      switch (stroke) {
        case 8:
          this.backstroke_length = this.input.val().length;
          break;
        case 9:
          break;
        case 13:
        case 27:
          event.preventDefault();
          this.add_tag(this.input.val());
          break;
        case 38:
          event.preventDefault();
          break;
        case 40:
          break;
        default:
          available_width = this.available_width();
          if (this._tags.length !== 0) {
            tmp_tag = $('<span />', {
              "class": 'tag'
            }).css({
              visibility: 'hidden',
              position: 'absolute',
              left: '-100000px'
            }).text(this.input.val()).append($('<a href="#">x</a>'));
            tmp_tag.appendTo(this.container);
            width = tmp_tag.outerWidth();
            if (width >= available_width) {
              added_height = this.input.position().top + tmp_tag.outerHeight();
              this.container.css({
                'height': this.container.innerHeight() + added_height
              });
              this.input.css({
                left: this.container.css('paddingLeft'),
                top: "" + added_height + "px"
              });
            } else {
              this.input.css({
                width: "" + available_width + "px"
              });
            }
            return tmp_tag.remove();
          }
      }
    };
    Taggable.prototype.keyup_checker = function(event) {
      var stroke, value, _ref;
      stroke = (_ref = event.which) != null ? _ref : event.keyCode;
      if (stroke !== 8) {
        this.clear_backstroke();
      }
      switch (stroke) {
        case 8:
          if (this.backstroke_length < 1 && this._tags.length > 0) {
            return this.backstroke();
          }
          break;
        default:
          if (this.options.delimiter_inserted) {
            value = this.input.val().replace(new RegExp(this.options.delimiter, 'g'), '');
            this.input.val(value);
            if (value !== '') {
              return this.add_tag(this.input.val());
            }
          }
      }
    };
    Taggable.prototype.keypress_checker = function(event) {
      if (String.fromCharCode(event.charCode) === this.options.delimiter) {
        this.options.delimiter_inserted = true;
      } else {
        this.options.delimiter_inserted = false;
      }
      return true;
    };
    Taggable.prototype.backstroke = function() {
      if (this.pending_removal) {
        this.clear_backstroke();
        return this.remove_tag(this._tags[this._tags.length - 1]);
      } else {
        this.pending_removal = true;
        return this.last_tag().element().addClass('focused');
      }
    };
    Taggable.prototype.clear_backstroke = function() {
      var last_tag;
      if (last_tag = this.last_tag()) {
        last_tag.element().removeClass('focused');
      }
      return this.pending_removal = null;
    };
    Taggable.prototype.add_tag = function(value) {
      var tag;
      if (value !== '') {
        tag = {
          id: "" + this._id + "_tag_" + this._tags.length,
          value: value,
          element: function() {
            return $("#" + this.id);
          }
        };
        this._tags.push(tag);
        this.container.append($('<span />', {
          "class": 'tag',
          id: tag.id
        }).text(value).append($('<a href="#">x</a>')));
        this.input.val('');
        this.scale();
        this.input.focus();
        this.write();
        return this.options.onChange.call(this);
      }
    };
    Taggable.prototype.remove_tag = function(tag) {
      this._tags.splice(this._tags.indexOf(tag), 1);
      $("#" + tag.id).remove();
      this.scale();
      this.write();
      return this.options.onChange.call(this);
    };
    Taggable.prototype.last_tag = function() {
      return this._tags[this._tags.length - 1];
    };
    Taggable.prototype.write = function() {
      var tag;
      return this.original.val(((function() {
        var _i, _len, _ref, _results;
        _ref = this._tags;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tag = _ref[_i];
          _results.push(tag.value);
        }
        return _results;
      }).call(this)).join(this.options.delimiter));
    };
    Taggable.prototype.destroy = function() {
      this.write();
      this.container.remove();
      return this.original.css(this.original.data('original-position'));
    };
    Taggable.prototype.available_width = function() {
      var last_tag_element;
      if (this._tags.length > 0) {
        last_tag_element = this.last_tag().element();
        return this.container.innerWidth() - (this.input.position().left + last_tag_element.outerWidth());
      } else {
        return this.container.innerWidth();
      }
    };
    Taggable.prototype.generate_random_id = function() {
      var string;
      string = "sel" + this.generate_random_char() + this.generate_random_char() + this.generate_random_char();
      while ($("#" + string).length > 0) {
        string += this.generate_random_char();
      }
      return string;
    };
    Taggable.prototype.generate_random_char = function() {
      var chars, newchar, rand;
      chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZ";
      rand = Math.floor(Math.random() * chars.length);
      return newchar = chars.substring(rand, rand + 1);
    };
    return Taggable;
  })();
}).call(this);