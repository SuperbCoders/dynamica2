class LandingController
  constructor: (@rootScope, @scope, @window) ->
    vm = @
    console.log 'Landing controller'

    $('#restore_pass_popup').on 'shown.bs.modal', ->
      vm.restore_pass_email = ''
      return

    @window.init_charts()
    skrollr.init()
    @window.init_page()

  modal: (name, action) ->
    # Close all modals
    $('.modal').modal('hide')

    # Open modal
    $('#'+name).modal(action, {backdrop: 'static'})
    return


  sign_in: (email, password) ->
    vm = @
    $.ajax(
      url: '/users/sign_in'
      type: 'POST'
      data:
        user:
          email: email
          password: password
      complete: (data, status) ->
        console.log status
        console.log data.responseJSON
    )

  restore_pass_send: (email) ->
    vm = @
    $.ajax(
      url: '/users/password'
      type: 'POST'
      data:
        user:
          email: email
      complete: (data, status) ->
        vm.restore_pass_email = ''
        console.log status
        console.log data.responseJSON
        if data.responseJSON.errors.length > 0
          vm.rootScope.$apply(->
            vm.error_message = data.responseJSON.errors[0]
          )
        else
          vm.error_message = ''
          $('#restore_pass_popup').modal('hide')
          $('#password_sended_popup').modal('show')
    )





@application.controller 'LandingController', ['$rootScope', '$scope', '$window', LandingController]
