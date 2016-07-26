class LandingController
  constructor: (@rootScope, @scope, @window, @anchorScroll, @location, @http) ->
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

    auth =
      email: email
      password: password

    vm.http.post('/users/sign_in', {user: auth}).then((response) ->
      if response.data.redirect_to
        vm.window.location.href = response.data.redirect_to
      else
        vm.http.post('/users', {user: auth}).then((response) ->
          if response.data.redirect_to
            vm.window.location.href = response.data.redirect_to
          else
            console.log response
        )
    )

  gotoAnchor: (x) ->
    vm = @
    newHash = x
    if vm.location.hash() != newHash
      # set the $location.hash to `newHash` and
      # $anchorScroll will automatically scroll to it
      vm.location.hash x
    else
      # call $anchorScroll() explicitly,
      # since $location.hash hasn't changed
      vm.anchorScroll()
    return

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





@application.controller 'LandingController', ['$rootScope', '$scope', '$window', '$anchorScroll', '$location', '$http', LandingController]
