$ ->
  if $('table.permissions').length
    $('body').on 'click', '.js-edit-permission-toggle', (event) ->
      event.preventDefault()
      id = $(this).data('id')
      $("#permission-#{id}").toggle()
      $("#edit-permission-#{id}").toggle()
      false

    $('body').on 'ajax:success', 'form.edit_permission', (event, data, status) ->
      id = data.permission.id
      $("#permission-#{id}").replaceWith(data.html).show()
      $("#edit-permission-#{id}").hide()

    $('body').on 'ajax:error', 'form.edit_permission', (event, error, status) ->
      alert error.responseJSON.base.join(',')

    $('body').on 'ajax:success', '.js-destroy-permission', (event, data, status) ->
      id = data.permission.id
      $("#permission-#{id}").hide()
      $("#edit-permission-#{id}").hide()