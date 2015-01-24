$ ->
  if $('.items').length

    # Initialize fileupload
    $('.item .attachment_file').each (index, fileInput)->
      $item = $(fileInput).closest('.item')
      $notSelected = $item.find('.file .not-selected')
      $loading = $item.find('.file .loading')
      $progressBar = $item.find('.file .loading .progress-bar')
      $done = $item.find('.file .done')

      $(fileInput).fileupload
        add: (e, data) ->
          $notSelected.hide()
          $loading.show()
          $progressBar.show().css(width: '0%')
          data.submit()
        done: (e, data) ->
          $loading.hide()
          $done.show()
          $item.find('#item_attachment_id').val(data.result.id)
        progress: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          $progressBar.animate(width: "#{progress}%")
        fail: (e, data) ->
          $loading.hide()
          $notSelected.show()
          alert 'Can not upload file'

    $('body').on 'click', '.js-add-new-item', (event) ->
      event.preventDefault()
      resetForm()
      $('.js-add-new-item').hide()
      $('.new-item').show()
      false

    $('body').on 'click', '.js-remove-new-item', (event) ->
      event.preventDefault()
      resetForm()
      $('.js-add-new-item').show()
      $('.new-item').hide()
      false

    # Open file dialog when user clicks on link
    $('body').on 'click', '.js-choose-file', (event) ->
      event.preventDefault()
      $(this).closest('.item').find('.attachment_file').click()
      false

    # POST /project/:project_id/items
    $('body').on 'ajax:success', 'form#new_item', (event, data, status) ->
      $('.items .new-item').after(data.html)
      $('.js-add-new-item').show()
      $('.new-item').hide()

    $('body').on 'ajax:error', 'form#new_item', (event, error, status) ->
      alert('Can not create item')

    # DELETE /project/:project_id/items/:id
    $('body').on 'ajax:success', '.js-destroy-item', (event, data, status) ->
      $(this).closest('.item').fadeOut()

    $('body').on 'ajax:error', '.js-destroy-item', (event, error, status) ->
      alert('Can not destroy item')

    resetForm = ->
      $form = $('#new_item')
      $form.find('#item_name').val('')
      $form.find('#item_sku').val('')
      $form.find('#item_attachment_id').val('')
      $('.new_item .file .notSelected').show()
      $('.new_item .file .loading').hide()
      $('.new_item .file .done').hide()
      $('.new_item .file .loading .progress-bar').css(width: '0%')