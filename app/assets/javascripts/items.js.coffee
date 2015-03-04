$ ->
  if $('.items').length

    resetForm = ->
      $form = $('#new_item')
      $form.find('#item_name').val('')
      $form.find('#item_sku').val('')
      $form.find('#item_attachment_id').val('')
      $('.new-item .file .selected').hide()
      $('.new-item .file .not-selected').show()
      $('.new-item .file .loading').hide()
      $('.new-item .file .loading .progress-bar').css(width: '0%')

    initFileupload = (fileInput) ->
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
          $item.replaceWith(data.result.html)
        progress: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          $progressBar.animate(width: "#{progress}%")
        fail: (e, data) ->
          $loading.hide()
          $notSelected.show()
          alert 'Can not upload file'

    # Initialize fileupload
    initFileuploads = ->
      $('.item .item_attachment').each (index, fileInput)->
        initFileupload(fileInput)

    initFileuploads()

    # Open file dialog when user clicks on link
    $('body').on 'click', '.js-choose-file', (event) ->
      event.preventDefault()
      $(this).closest('.item').find('.item_attachment').click()

    $('body').on 'focusout', '.item #item_name', (event) ->
      $(this).closest('form').submit()

    # POST /project/:project_id/items
    $('body').on 'ajax:success', '#js-add-new-item', (event, data, status) ->
      $newItem = $(data.html)
      $('.items .js-insert-new-item-here').after($newItem)
      # initFileupload($newItem.find('.item_attachment'))
      initFileuploads()

    # PATCH/PUT /project/:project_id/items/:item_id
    $('body').on 'ajax:success', 'form.edit-item', (event, data, status) ->
      return unless event.target is this
      $item = $(this).closest('.item')
      $item.replaceWith(data.html)
      initFileuploads()

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
      initFileuploads()

    $('body').on 'ajax:error', '.js-destroy-values', (event, error, status) ->
      alert('Can not destroy values')