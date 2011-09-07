class DisplayOptionsInterface
  constructor: (element) ->
    @element = element
    return if @element.size() == 0
    @options = []
    this.setup()

  setup: ->
    table = @element.find('table tbody')
    @table = if table.size() != 0
      table
    else
      $('<table><thead><tr><th colspan="2">Display options</th></tr></thead><tbody></tbody></table>').appendTo(@element)
    this.parse_table()

  parse_table: ->
    @table.find('tr').each (index, element) =>
      row = $ element
      cells = row.find('td')
      switch row.data 'type'
        when 'value-list'
          @options.push new ValueList $(cells[0]).text(), ($(span).text() for span in $(cells[1]).find('span')), row
          break
        when 'key-value-list'
          values = $(cells[1]).find('span.option').map (index, span) ->
            element = $ span
            {
              key: element.find('.key').text(),
              value: element.find('.value').text()
            }
          @options.push new KeyValueList $(cells[0]).text(), values, row
          break

class DisplayOption
  constructor: (name, values, element) ->
    @_name    = name
    @_values  = values || []
    @_element = element if element
    this.setup_observers()

  setup_observers: ->
    this.element().delegate 'td', 'click', (event) =>
      return if event.srcElement.nodeName in ['INPUT', 'DIV']
      cell = $ event.currentTarget
      if cell.hasClass 'name'
        this.edit_key(cell)
      else
        this.edit_values(cell)

  name: (name) ->
    @_name = name if name?
    @_name

  values: (values) ->
    @_values = values if values?
    @_values

  edit_key: (cell) ->
    cell = cell
    input = $ '<input>',
      type: 'text',
      name: 'option_name',
      value: this.name()
    .bind 'keypress.display_option', (event) =>
      stroke = event.which ? event.keyCode
      if stroke == 13
        cell.html this.name input.val()
        input.remove()

    cell.html input
    input.focus()

  element: ->
    return @_element if @_element?
    @_element = $ """
                    <tr data-type=\"#{@type}\">
                      <td class=\"name\">#{this.name()}</td>
                      <td class=\"values\">#{this.values_as_html_string()}</td>
                    </tr>
                  """

class ValueList extends DisplayOption

  constructor: ->
    @type = 'value-list'
    super arguments...

  persist_values: (cell) ->
    this.values $.grep (this.input().val().split(',').map (value) ->
      $.trim value
    ), (n) -> n
    cell.html this.values().join(', ')
    delete @_input

  edit_values: (cell) ->
    this.input().bind 'keypress.display_option', (event) =>
      stroke = event.which ? event.keyCode
      if stroke == 13
        this.persist_values cell

    cell.html this.input()

    button = $('<button>Spara</button>').click (event) =>
      event.preventDefault()
      this.input().taggable 'destroy'
      this.persist_values cell
    button.insertAfter this.input()

    this.input().taggable
      delimiter: ','

  input: ->
    return @_input if @_input?
    @_input = $ '<input>',
      type: 'text'
      name: 'option_values'
      value: this.values().join(', ')
      data:
        delimiter: ','
      css:
        width: '100%'

  values_as_html_string: ->
    this.values().map (index, value) ->
      "<span class=\"value\">#{value}</span>"
    .join(', ')

class KeyValueList extends DisplayOption

  constructor: ->
    @type = 'key-value-list'
    super arguments...

  values_as_html_string: ->
    @values.map (index, value) ->
      """
        <span class=\"option\">
          <span class=\"key\">#{value.key}</span>
          <span class=\"value\">#{value.key}</span>
        </span>
      """
    .join(', ')

$(document).ready ->
  display_options = new DisplayOptionsInterface $ '#display_options'