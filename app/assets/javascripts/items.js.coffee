$ ->
  if $('.items').length

    # Initialize fileupload
    $('.item .attachment_file').each (index, fileInput)->
      $item = $(fileInput).closest('.item')
      $selected = $item.find('.file .selected')
      $notSelected = $item.find('.file .not-selected')
      $loading = $item.find('.file .loading')
      $progressBar = $item.find('.file .loading .js-progress-bar')

      $(fileInput).fileupload
        add: (e, data) ->
          $notSelected.hide()
          $loading.show()
          $progressBar.show().css(width: '0%')
          data.submit()
        done: (e, data) ->
          $loading.hide()
          $selected.show()
          $selected.find('.js-real-count').hide()
          $selected.find('.js-attachment-uploaded').show()
          $item.find('.attachment_id').val(data.result.id)
        progress: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          $progressBar.animate(width: "#{progress}%")
        fail: (e, data) ->
          $loading.hide()
          $notSelected.show()
          alert 'Can not upload file'

    $('body').on 'click', '.js-submit-new-item', (event) ->
      event.preventDefault()
      $(this).closest('form').submit()

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

    # PATCH/PUT /project/:project_id/items/:item_id
    $('body').on 'ajax:success', 'form.edit-item', (event, data, status) ->
      return unless event.target is this
      $(this).closest('.item').replaceWith(data.html)

    $('body').on 'ajax:error', 'form.edit-item', (event, error, status) ->
      return unless event.target is this
      alert('Can not save item')

    # DELETE /project/:project_id/items/:id
    $('body').on 'ajax:success', '.js-destroy-item', (event, data, status) ->
      $(this).closest('.item').fadeOut()

    $('body').on 'ajax:error', '.js-destroy-item', (event, error, status) ->
      alert('Can not destroy item')

    # DELETE /projects/:project_id/items/:id/values
    $('body').on 'ajax:success', '.js-destroy-values', (event, data, status) ->
      $fileBlock = $(this).closest('.file')
      $fileBlock.find('.selected').hide()
      $fileBlock.find('.not-selected').show()

    $('body').on 'ajax:error', '.js-destroy-values', (event, error, status) ->
      alert('Can not destroy values')

    resetForm = ->
      $form = $('#new_item')
      $form.find('#item_name').val('')
      $form.find('#item_sku').val('')
      $form.find('#item_attachment_id').val('')
      $('.new-item .file .selected').hide()
      $('.new-item .file .not-selected').show()
      $('.new-item .file .loading').hide()
      $('.new-item .file .loading .progress-bar').css(width: '0%')