class SubscriptionController
  constructor: (@rootScope, @scope, @Projects, @http, @routes, @window) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.requested = false

    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project

      vm.new_sub_type = vm.project.sub_type if vm.project.sub_type != 'trial'
      vm.fetch_subscription()
    )

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

  fetch_subscription: ->
    vm = @
    vm.http.get(vm.routes.show_subscription_path(vm.project.id), {}).then((response) ->
      if response.data.success
        vm.history = response.data.history
        vm.subscription = response.data.subscription
    )

@application.controller 'SubscriptionController', ['$rootScope', '$scope', 'Projects', '$http', 'Routes', '$window', SubscriptionController]
