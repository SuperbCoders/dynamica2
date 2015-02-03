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
    $(this).find('.control-box').removeClass('has-error')

  $('body').on 'ajax:success', '.validate-login', (event, data, status) ->
    location.reload()

  $('body').on 'ajax:error', '.validate-login', (event, error, status) ->
    $(this).find('.control-box').addClass('has-error')

  #
  # Registration
  #
  $('body').on 'ajax:before', '.validate-signup', (event, data, status) ->
    $(this).find('.control-box').removeClass('has-error')

  $('body').on 'ajax:success', '.validate-signup', (event, data, status) ->
    location.reload()

  $('body').on 'ajax:error', '.validate-signup', (event, error, status) ->
    for attribute, errors of error.responseJSON
      $(this).find("#user_#{attribute}").closest('.control-box').addClass('has-error')