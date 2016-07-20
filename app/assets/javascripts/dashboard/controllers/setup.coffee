class SetupController
  constructor: (@rootScope, @scope, @Alerts, @http, @R) ->
    vm = @
    vm.profile =
      email: undefined
      password: ''
      password_confirmation: ''
    console.log 'SetupController'


  save: ->
    vm = @
    return if not @check_profile()


    # Check email uniqueness
    vm.http.post(vm.R.email_uniqueness_path(), {email: vm.profile.email}).success((result) ->
      if result.exist
      else
        vm.http.post(vm.R.update_profile_path(), vm.profile).then((response) ->
          vm.password = response.data.password

          if response.data.profile.valid
            vm.rootScope.user = response.data.profile
            vm.rootScope.$state.go('projects.list')
        )
    )
    return


  check_profile: ->
    vm = @
    if not @profile.email
      @Alerts.error(@T.t('please_enter_valid_email'))

    if not @profile.password or not @profile.password_confirmation
      return @Alerts.error(@T.t('please_enter_password'))

    if @profile.password != @profile.password_confirmation
      return @Alerts.error(@T.t('password_mismatch'))
    return true

@application.controller 'SetupController', ['$rootScope', '$scope', 'Alerts', '$http', 'Routes', SetupController]
