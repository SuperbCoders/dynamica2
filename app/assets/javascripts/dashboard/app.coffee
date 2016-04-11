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
    templateUrl: '/templates/stores/chart'
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

  $rootScope.set_datepicker_start_date = (datepicker, date) -> datepicker.datepicker('setStartDate', new Date(date))

  if $('.switcher').length
    $("[data-toggle='switch']").bootstrapSwitch({baseClass: 'switch'})

  # Load user profile
  $http.get('/profile').success((response) ->
    $rootScope.user = response
  )

  # Open user dropdown menu
  $('.user-toggle.dropdown-toggle').on('click', (element) -> $('.user.dropdown').toggleClass('open'))

  $('html').on('click', (element) ->
    element_id = element.toElement.id

    # Close user menu in header
    if element_id != 'user_dropdown' and $('.user.dropdown').hasClass('open')
      $('.user.dropdown').toggleClass('open')


    $('.setting.open').removeClass('open') if element_id != 'setting_menu'
  )

]
