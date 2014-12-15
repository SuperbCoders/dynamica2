$ ->
  if $('table.permissions').length
    #
    # Permissions
    #
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
      id = $(this).closest('tr.permission').data('id')
      $("#permission-#{id}").hide()
      $("#edit-permission-#{id}").hide()

    #
    # Pending Permissions
    #

    $('body').on 'click', '.js-new-pending-permission-toggle', (event) ->
      event.preventDefault()
      $wrapper = $(this).closest('tr#new-pending-permission')
      $wrapper.find('.js-invite').toggle()
      $wrapper.find('form').toggle()
      $wrapper.find('form #pending_permission_email').focus()
      clearNewPendingPermissionForm()
      false

    $('body').on 'ajax:success', 'form#new_pending_permission', (event, data, status) ->
      $('#new-pending-permission').before(data.html)
      $wrapper = $(this).closest('tr#new-pending-permission')
      $wrapper.find('.js-invite').toggle()
      $wrapper.find('form').toggle()
      clearNewPendingPermissionForm()

    $('body').on 'ajax:error', 'form#new_pending_permission', (event, error, status) ->
      errors = error.responseJSON
      $('#pending_permission_email').closest('form').addClass('has-error')
      alert(errors.base.join(',')) unless errors.base is undefined

    $('body').on 'ajax:success', '.js-destroy-pending-permission', (event, data, status) ->
      $(this).closest('tr.pending-permission').hide()

    clearNewPendingPermissionForm = ->
      $form = $('tr#new-pending-permission').find('form')
      $form.find('#pending_permission_email').val('').closest('form').removeClass('has-error')
      $form.find('#pending_permission_read').prop('checked', true)
      $form.find('#pending_permission_forecasting').prop('checked', false)
      $form.find('#pending_permission_manage').prop('checked', false)
      $form.find('#pending_permission_api').prop('checked', false)