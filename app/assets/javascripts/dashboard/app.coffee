@application = angular.module('dynamica.dashboard',
  [ 'ui.router',
    'ngResource',
    'angularUtils.directives.dirPagination'])

@application.config ['$httpProvider', '$stateProvider', '$urlRouterProvider', ($httpProvider, $stateProvider, $urlRouterProvider) ->
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.headers.post['Content-Type']= 'application/json'
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
  $httpProvider.interceptors.push 'requestOverlay'
  delete $httpProvider.defaults.headers.common['X-Requested-With']

  $stateProvider
  .state 'setup',
    url: '/setup'
    templateUrl: '/templates/setup'
    controller: 'SetupController'
    controllerAs: 'vm'
    
  .state 'profile',
    url: '/profile',
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
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.view',
    url: '/:slug',
    templateUrl: '/templates/stores/dashboard'
    controller: 'DashboardController',
    controllerAs: 'vm'
    resolve:
      Projects: ['Resource', (Resource) ->
        Resource '/projects/:id', {id: @id}, [
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

  .state 'projects.subscription',
    url: '/:slug/subscription',
    templateUrl: '/templates/stores/subscription'
    controller: 'SubscriptionController'
    controllerAs: 'vm'
    resolve:
      Projects: ['Resource', (Resource) ->
        Resource '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.products_revenue',
    url: '/:slug/products_revenue/:from/:to',
    templateUrl: '/templates/stores/products_revenue'
    controller: 'ProductsRevenueController'
    controllerAs: 'vm'
    params: {project: null}
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
    controller: 'ChartController',
    controllerAs: 'vm',
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

@application.run ['$rootScope', '$state', '$stateParams', '$http', '$location', ($rootScope, $state, $stateParams, $http, $location) ->
  $rootScope.$state = $state
  $rootScope.$stateParams = $stateParams
  $rootScope.$location = $location
  $rootScope.locale = $("meta[name=locale]").attr('content')

  if $('.switcher').length
    $("[data-toggle='switch']").bootstrapSwitch({baseClass: 'switch'})

  # Load user profile
  $http.get('/profile').success((response) -> $rootScope.user = response)

  # Open user dropdown menu
  $('.user-toggle.dropdown-toggle').on('click', (element) -> $('.user.dropdown').toggleClass('open'))

  $('html').on('click', (element) ->
    element_id = element.toElement.id

    # Close user menu in header
    if element_id != 'user_dropdown' and $('.user.dropdown').hasClass('open')
      $('.user.dropdown').toggleClass('open')


    $('.setting.open').removeClass('open') if element_id != 'setting_menu'
  )


  # Shared datepicker helpers
  $rootScope.set_date_range = (range, period, datepicker = $('.datePicker')) ->
    # range - object that will sended to backed
    today = moment()
    rangeEnd = moment()

    switch period
      when 0
        # Current month
        rangeStart = moment(today).startOf('month')
        rangeEnd = moment(today).endOf('month')
        console.log period+': Period is Current month from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

      when 1
        # Previous month
        rangeStart = moment(today).subtract(1, 'month').startOf('month')
        rangeEnd = moment(today).subtract(1, 'month').endOf('month')
        console.log period+': Period is Previous month from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

      when 2
        # Last 3 month
        rangeStart = moment(today).subtract(3, 'month')
        console.log period+': Period is Last 3 month from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

      when 3
        # Last 6 month
        rangeStart = moment(today).subtract(6, 'month')
        console.log period+': Period is Last 6 month from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

      when 4
        # Last year
        rangeStart = moment(today).subtract(12, 'month')
        console.log period+': Period is Last year from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

      when 5
        # All time
        rangeStart = moment(datepicker.datepicker('getStartDate'))
        console.log period+': Period is All time year from '+rangeStart.format('lll')+' to '+rangeEnd.format('lll')

    range.raw_start = rangeStart
    range.raw_end = rangeEnd
    range.from = rangeStart.format('MM.DD.YYYY')
    range.to = rangeEnd.format('MM.DD.YYYY')
    return

  $rootScope.fit2Limits = (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  $rootScope.set_datepicker_date = (datepicker, rangeStart, rangeEnd) ->
    rangeStart = rangeStart.toDate()
    rangeEnd = rangeEnd.toDate()
    console.log 'Setting datepicker with from ['+rangeStart+'] to ['+rangeEnd+']'

    datepicker.datepicker('setDates', [rangeStart, rangeEnd]).datepicker 'update'


  $rootScope.set_datepicker_start_date = (datepicker, date) -> datepicker.datepicker('setStartDate', new Date(date))


]
