$ ->
  hash = window.location.hash.substring(1)
  if hash == 'login' and $('#modal-login').length
    $('#modal-login').arcticmodal()
  if hash == 'password-new' and $('#modal-password-new').length
    $('#modal-password-new').arcticmodal()