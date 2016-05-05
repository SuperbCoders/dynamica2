class SubscriptionController
  constructor: (@rootScope, @scope, @http, @routes, @window) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.requested = false

    vm.fetch_subscription()

  change: (type) ->
    vm = @
    console.log 'Change subscription to '+type

    packet =
      id: vm.project.id
      sub_type: type

    vm.requested = true
    vm.http.post(vm.routes.change_subscription_path(), packet).then((response) ->
      data = response.data


      if data.success
        vm.window.location.href = response.data.charge.confirmation_url
      else
        console.log data
        vm.requested = false
    )


@application.controller 'SubscriptionController', ['$rootScope', '$scope', '$http', 'Routes', '$window', SubscriptionController]
