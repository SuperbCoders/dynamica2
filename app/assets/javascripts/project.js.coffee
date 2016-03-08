$ ->
  $('.hover-select-box.front-select-btn select').change ->
    window.location.href = '/projects/' + $(this).val()

    return
