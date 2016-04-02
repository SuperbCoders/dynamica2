class SetupController
  constructor: (@rootScope, @scope, @Alerts, @T, @http, @R) ->
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
        vm.Alerts.error(vm.T.t('email_already_taken'))
      else
        vm.http.post(vm.R.update_profile_path(), vm.profile).then((response) ->
          vm.password = response.data.password

          if response.data.profile.valid
            vm.rootScope.user = response.data.profile
            vm.Alerts.success(vm.T.t('profile_succefully_updated'))
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

@application.controller 'SetupController', ['$rootScope', '$scope', 'Alerts', 'Translate', '$http', 'Routes', SetupController]
