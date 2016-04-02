class SetupController
  constructor: (@rootScope, @scope, @Alerts, @T, @http, @R) ->
    vm = @
    vm.profile =
      email: undefined
      password: ''
      password_confirmation: ''
    console.log 'SetupController'


  save: ->
    return if not @check_profile()
    vm = @


  check_profile: ->
    vm = @
    if not @profile.email
      @Alerts.error(@T.t('please_enter_valid_email'))

    if not @profile.password or not @profile.password_confirmation
      return @Alerts.error(@T.t('please_enter_password'))

    if @profile.password != @profile.password_confirmation
      return @Alerts.error(@T.t('password_mismatch'))

    # Check email uniqueness
    console.log @R.email_uniqueness_path()
    vm.http.post(vm.R.email_uniqueness_path(), {email: vm.profile.email}).success((result) ->
      if result.exist
        vm.Alerts.error(vm.T.t('email_already_taken'))
      else
        vm.Alerts.success(vm.T.t('email_succefull_changed'))
        console.log result
    )

@application.controller 'SetupController', ['$rootScope', '$scope', 'Alerts', 'Translate', '$http', 'Routes', SetupController]
