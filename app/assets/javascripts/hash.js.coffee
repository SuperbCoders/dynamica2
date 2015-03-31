$ ->
  hash = window.location.hash.substring(1)
  if hash == 'login' and $('#modal-login').length
    $('#modal-login').arcticmodal()