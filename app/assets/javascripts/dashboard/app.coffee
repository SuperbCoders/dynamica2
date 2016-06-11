@application = angular.module('dynamica.dashboard',
  [ 'ui.router',
    'ngResource',
    'angularUtils.directives.dirPagination',
    'ngDroplet',
    'LocalStorageModule'])

@application.config ['$httpProvider', '$stateProvider', '$urlRouterProvider', 'localStorageServiceProvider', ($httpProvider, $stateProvider, $urlRouterProvider, localStorageServiceProvider) ->
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.headers.post['Content-Type']= 'application/json'
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
  $httpProvider.interceptors.push 'httpFilter'
  delete $httpProvider.defaults.headers.common['X-Requested-With']

  localStorageServiceProvider.setPrefix('dynamica.dashboard')

  $stateProvider
  .state 'setup',
    url: '/setup'
    templateUrl: '/templates/setup'
    controller: 'SetupController'
    controllerAs: 'vm'
    
  .state 'profile', url: '/profile', templateUrl: '/templates/profile/index'

  .state 'profile.edit',
    url: '/edit',
    templateUrl: '/templates/profile/edit'
    controller: 'ProfileController',
    controllerAs: 'vm'

  .state 'projects',
    url: '/stores',
    templateUrl: '/templates/stores/index'

  .state 'projects.list',
    url: '/',
    templateUrl: '/templates/stores/list'
    controller: 'ProjectsController',
    controllerAs: 'vm',
    resolve:
      Projects: ['Resources', (Resources) ->
        Resources '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {remove: {method: 'DELETE'}},

        ]
      ]

  .state 'projects.new',
    url: '/new',
    templateUrl: '/templates/stores/new'
    controller: 'ProjectsController',
    controllerAs: 'vm',
    resolve:
      Projects: ['Resource', (Resource) ->
        Resource '/projects', {id: @id}, [ {method: 'GET', isArray: false} ]
      ]

  .state 'projects.edit',
    url: '/edit/:slug'
    templateUrl: '/templates/stores/new'
    controller: 'ProjectsController',
    controllerAs: 'vm',
    resolve:
      Projects: ['Resources', (Resources) ->
        Resources '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false},
          {remove: {method: 'DELETE'}}
        ]
      ]

  .state 'projects.view',
    url: '/:slug',
    templateUrl: '/templates/stores/dashboard'
    controller: 'DashboardController',
    controllerAs: 'vm'
    resolve:
      Projects: ['Resources', (Resources) ->
        Resources '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.settings',
    url: '/:slug/settings'
    templateUrl: '/templates/stores/settings'
    controller: 'ProjectsController'
    controllerAs: 'vm'
    resolve:
      Projects: ['Resources', (Resources) ->
        Resources '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.products_revenue',
    url: '/:slug/products_revenue/:from/:to',
    templateUrl: '/templates/stores/products/products_revenue'
    controller: 'ProductsRevenueController'
    controllerAs: 'vm'
    params: {project: null}
    resolve:
      Projects: ['Resource', (Resource) ->
        Resource '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.donut_chart',
    url: '/:slug/donut/:chart/:from/:to',
    templateUrl: '/templates/stores/donut_chart_dashboard'
    controller: 'DonutChartController'
    controllerAs: 'vm'
    resolve:
      Projects: ['Resources', (Resources) ->
        Resources '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.chart',
    url: '/:slug/:chart/:from/:to',
    templateUrl: '/templates/stores/full_dashboard'
    controller: 'ChartController'
    controllerAs: 'vm'
    params: {project: null}
    resolve:
      Projects: ['Resources', (Resources) ->
        Resources '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  $urlRouterProvider.otherwise '/stores/'
  return
]

@application.run ['$rootScope', '$state', '$stateParams', '$http', '$location', '$filter', 'Alerts', 'Translate', 'localStorageService', ($rootScope, $state, $stateParams, $http, $location, $filter, Alerts, Translate, localStorageService) ->
  $rootScope.currency = '$'
  $rootScope.$state = $state
  $rootScope.$stateParams = $stateParams
  $rootScope.$location = $location
  $rootScope.alerts = Alerts
  $rootScope.locale = $("meta[name=locale]").attr('content')
  $rootScope.T = Translate

  # Subscription check
  $rootScope.$on("$locationChangeStart", (event, next, current) ->
    if $rootScope.user and $rootScope.user.subscription.expired
      $rootScope.subscription()
  )

  $rootScope.subscription = -> $state.go 'profile.edit'


  if $('.switcher').length
    $("[data-toggle='switch']").bootstrapSwitch({baseClass: 'switch'})

  # Load user profile
  $rootScope.update_user = ->
    $http.get('/profile').success((response) ->
      $rootScope.user = response


      if $rootScope.user.subscription.expired
        $rootScope.subscription()

      if $rootScope.user.projects.length == 1 and $state.current.name is not 'projects.list'
        project = $rootScope.user.projects[0]

        $state.go('projects.view', {id: project.id, slug: project.slug})
    )
  $rootScope.update_user()

  $rootScope.overlay = (action) ->
    switch action
      when 'show'
        $('.pageOverlay').addClass('show_overlay')
      when 'hide'
        $('.pageOverlay').removeClass('show_overlay')
    return


  # Open user dropdown menu
  $('.user-toggle.dropdown-toggle').on('click', (element) -> $('.user.dropdown').toggleClass('open'))

  $('html').on('click', (element) ->
    element_id = element.toElement.id

    # Close user menu in header
    if element_id != 'user_dropdown' and $('.user.dropdown').hasClass('open')
      $('.user.dropdown').toggleClass('open')


    $('.setting.open').removeClass('open') if element_id != 'setting_menu'
  )

  # В зависимости от вида графика показывать валюту или нет в разных частях дашборда
  # param value - значение(цифра)
  # param chart_name - название графика
  $rootScope.period_value = (value, chart_name) ->
    if chart_name in ['items_in_stock_number', 'products_number', 'orders_number', 'customers_number', 'products_in_stock_number']
      value
    else
      value = $filter('dynCurrency')(value)

  # Set current project
  $rootScope.current_project = (project) ->
    $rootScope.project = project

  # State checker for current class for menu
  $rootScope.state_is = (name) ->
    chart_name = $rootScope.$stateParams.chart
    state = $rootScope.$state.current.name
    total_states = ['total_gross_revenues', 'shipping_cost_as_a_percentage_of_total_revenue', 'average_order_value', 'average_order_size']
    customer_states = ['customers_number','new_customers_number','repeat_customers_number','average_revenue_per_customer','sales_per_visitor','average_customer_lifetime_value','unique_users_number','visits']
    products_states = ['products_in_stock_number','items_in_stock_number','percentage_of_inventory_sold','percentage_of_stock_sold','products_number','products_revenue', 'products_number']

    return true if name is 'dashboard' and state is 'projects.view'
    return true if name is 'products' and state is 'projects.products_revenue'
    return true if name is 'products_number' and state is 'projects.products_number'

    switch name
      when 'general'
        return true if chart_name in total_states
      when 'customers'
        return true if chart_name in customer_states
      when 'products'
        return true if chart_name in products_states

    return false

  # Shared datepicker helpers
  $rootScope.set_date_range = (range, period, datepicker = $('.datePicker')) ->
    # range - object that will sended to backed
    today = moment()
    rangeEnd = moment()

    switch period
      when 0
        # Current month
        rangeName = 'Current month'
        rangeStart = moment(today).startOf('month')
        rangeEnd = moment(today).endOf('month')

      when 1
        # Previous month
        rangeName = 'Previous month'
        rangeStart = moment(today).subtract(1, 'month').startOf('month')
        rangeEnd = moment(today).subtract(1, 'month').endOf('month')

      when 2
        # Last 3 month
        rangeName = 'Last 3 month'
        rangeStart = moment(today).subtract(3, 'month')

      when 3
        # Last 6 month
        rangeName = 'Last 6 month'
        rangeStart = moment(today).subtract(6, 'month')

      when 4
        # Last year
        rangeName = 'Last year'
        rangeStart = moment(today).subtract(12, 'month')

      when 5
        # All time
        rangeName = 'All time'
        rangeStart = moment(datepicker.datepicker('getStartDate'))


    # console.log period+': Period is '+rangeName+' from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

    range.raw_start = rangeStart
    range.raw_end = rangeEnd
    range.from = rangeStart.format('MM.DD.YYYY')
    range.to = rangeEnd.format('MM.DD.YYYY')

#    if $state.current.name in ['projects.chart', 'projects.products_revenue']
#      $rootScope.reload_state_params(range)


    # Save period in localStorage
    $rootScope.save_dates_to_ls(rangeStart, rangeEnd)

    return

  $rootScope.reload_state_params = (range) ->
    $stateParams.from = range.from
    $stateParams.to = range.to
    $state.transitionTo($state.current, $stateParams, {
      reload: true, inherit: false, notify: false
    })

  $rootScope.fit2Limits = (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  $rootScope.set_datepicker_date = (datepicker, rangeStart, rangeEnd) ->
    rangeStart = rangeStart.toDate() if rangeStart._isAMomentObject
    rangeEnd = rangeEnd.toDate() if rangeEnd._isAMomentObject
    datepicker.datepicker('setDates', [rangeStart, rangeEnd]).datepicker 'update'

  # Set datepicker start date. Different projects has different data with different start days
  $rootScope.set_datepicker_start_date = (datepicker, date) ->
    console.log 'Project for data : '+date
    datepicker.datepicker('setStartDate', new Date(date))


  # Localstorage funcs
  $rootScope.load_dates_from_ls = (scope) ->
    debug = false
    if localStorageService.isSupported

      from = localStorageService.get('from')
      to = localStorageService.get('to')

      if from
        scope.range.from = moment(from).format('MM.DD.YYYY')
        scope.range.raw_start = moment(from)
      else
        scope.range.from = moment().startOf('month').format('MM.DD.YYYY')
        scope.range.raw_start = moment().startOf('month')


      if to
        scope.range.to = moment(to).format('MM.DD.YYYY')
        scope.range.raw_end = moment(to)
      else
        scope.range.to = moment().endOf('month').format('MM.DD.YYYY')
        scope.range.raw_end = moment().endOf('month')

      console.log 'Dates from LS loaded. From : '+scope.range.from+'. To : '+scope.range.to if debug

  # Save dates from $stateParams to LS
  $rootScope.$on('$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    if toState.name in ['projects.chart', 'projects.products_revenue']
      $rootScope.save_dates_to_ls_from_params()
  )

  $rootScope.save_dates_to_ls_from_params = ->
    debug = false
    if $stateParams.from and $stateParams.to
      console.log 'Save dates from stateParams' if debug
      $rootScope.save_dates_to_ls(moment($stateParams.from, 'MM.DD.YYYY'), moment($stateParams.to, 'MM.DD.YYYY'))
    else
      console.log $stateParams if debug

  # Save dates to localStorage
  # rangeStart - momentjs object
  # rangeEnd - momentjs object
  $rootScope.save_dates_to_ls = (rangeStart, rangeEnd) ->
    debug = false
    if localStorageService.isSupported
      if debug
        console.log 'Save dates to localStorage. From : '+rangeStart.format('lll')+'. To '+rangeEnd.format('lll')
      localStorageService.set('from', rangeStart )
      localStorageService.set('to', rangeEnd )

]
