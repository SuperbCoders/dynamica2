$ ->
  if $('table.items').length

    $('body').on 'click', '.js-new-item-toggle', (event) ->
      event.preventDefault()
      $('tr.new-item .button').toggle()
      $('tr.new-item .form').toggle()
      false