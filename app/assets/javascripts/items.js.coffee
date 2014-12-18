$ ->
  if $('table.items').length

    # Initialize fileupload
    $('#attachment_file').fileupload
      add: (e, data) ->
        $('.new_item .file .select').hide()
        $('.new_item .file .loading').show()
        $('.new_item .file .loading .progress-bar').show().css(width: '0%')
        data.submit()
      done: (e, data) ->
        $('.new_item .file .loading').hide()
        $('.new_item .file .done').show()
        $('#new_item #item_attachment_id').val(data.result.id)
      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $('.new_item .file .loading .progress-bar').animate(width: "#{progress}%")
      fail: (e, data) ->
        $('.new_item .file .loading').hide()
        $('.new_item .file .select').show()
        alert 'Can not upload file'

    $('body').on 'click', '.js-new-item-toggle', (event) ->
      event.preventDefault()
      resetForm()
      $('tr.new-item .button').toggle()
      $('tr.new-item .form').toggle()
      false

    # Open file dialog when user clicks on link
    $('body').on 'click', '.js-choose-file', (event) ->
      event.preventDefault()
      $('#attachment_file').click()
      false

    # POST /project/:project_id/items
    $('body').on 'ajax:success', 'form#new_item', (event, data, status) ->
      $('.items tr.new-item').before(data.html)
      $('tr.new-item .button').show()
      $('tr.new-item .form').hide()

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
      $('.new_item .file .select').show()
      $('.new_item .file .loading').hide()
      $('.new_item .file .done').hide()
      $('.new_item .file .loading .progress-bar').css(width: '0%')