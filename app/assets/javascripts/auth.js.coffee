$ ->
  $('body').on 'click', '[data-modal]', (event) ->
    event.preventDefault()
    id = $(this).data('modal')
    $.arcticmodal('close')
    $("#modal-#{id}").arcticmodal()

  #
  # Login
  #
  $('body').on 'ajax:before', '.validate-login', (event, data, status) ->
    return false if $(this).hasClass('waiting')
    $(this).fadeTo('fast', 0.7)
    $(this).addClass('waiting')
    $(this).find('.control-box').removeClass('has-error')

  $('body').on 'ajax:complete', '.validate-login', (event, data, status) ->
    $(this).fadeTo('fast', 1.0)
    $(this).removeClass('waiting')

  $('body').on 'ajax:success', '.validate-login', (event, data, status) ->
    location.reload()

  $('body').on 'ajax:error', '.validate-login', (event, error, status) ->
    $(this).find('.control-box').addClass('has-error')

  #
  # Registration
  #
  $('body').on 'ajax:before', '.validate-signup', (event, data, status) ->
    return false if $(this).hasClass('waiting')
    $(this).fadeTo('fast', 0.7)
    $(this).addClass('waiting')
    $(this).find('.control-box').removeClass('has-error')

  $('body').on 'ajax:complete', '.validate-signup', (event, data, status) ->
    $(this).fadeTo('fast', 1.0)
    $(this).removeClass('waiting')

  $('body').on 'ajax:success', '.validate-signup', (event, data, status) ->
    window.location.replace('/projects')

  $('body').on 'ajax:error', '.validate-signup', (event, error, status) ->
    for attribute, errors of error.responseJSON
      $(this).find("#user_#{attribute}").closest('.control-box').addClass('has-error')

  #
  # Password recovery
  #
  $('body').on 'ajax:complete', '.validate-password-recovery', (event, data, status) ->
    email = $('#modal-recover #user_email').val()
    $('#modal-password-recovery-sent span.email').text(email)
    $.arcticmodal('close')
    $('#modal-password-recovery-sent').arcticmodal()