$ ->
  if $('.case-profile').length
    $('body').on 'click', '#js-delete-avatar', (event) ->
      event.preventDefault()
      $('#js-avatar').hide()
      $('#js-default-avatar').show()
      $('#user_remove_avatar').val('1')

    $('body').on 'click', '#js-choose-file', (event) ->
        event.preventDefault()
        $('#user_avatar').click()

    $userAvatar = $('#user_avatar')
    $userAvatar.fileupload
      url: '/users/avatar'
      dropZone: $('.upload-box')
      add: (e, data) ->
        data.submit()
      done: (e, data) ->
        $('#js-delete-avatar').show()
        $('#js-avatar').show()
        $('#js-avatar').attr('src', "#{data.result.avatar.medium.url}?#{new Date().getTime()}")
        $('#js-default-avatar').hide()
        $('#user_remove_avatar').val('')
      fail: (e, data) ->
        alert 'Can not upload avatar'