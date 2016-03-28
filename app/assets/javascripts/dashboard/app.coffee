@application = angular.module('dynamica.dashboard',
  [ 'ui.router',
    'ngResource'])

@application.config ['$httpProvider', '$stateProvider', '$urlRouterProvider', ($httpProvider, $stateProvider, $urlRouterProvider) ->
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.headers.post['Content-Type']= 'application/json'
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
  $httpProvider.interceptors.push 'requestOverlay'
  delete $httpProvider.defaults.headers.common['X-Requested-With']

  $stateProvider
  .state 'profile',
    url: '/profile',
    templateUrl: 'templates/profile/edit'
    controller: 'ProfileController',
    controllerAs: 'vm'

  .state 'projects',
    url: '/stores',
    templateUrl: 'templates/stores/index'

  .state 'projects.list',
    url: '/',
    templateUrl: 'templates/stores/list'
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
    templateUrl: 'templates/stores/new'
    controller: 'ProjectsController',
    controllerAs: 'vm',
    resolve:
      Projects: ['Resource', (Resource) ->
        Resource '/projects', {id: @id}, [ {method: 'GET', isArray: false} ]
      ]

  .state 'projects.edit',
    url: '/edit/:slug'
    templateUrl: 'templates/stores/new'
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
    templateUrl: 'templates/stores/view'
    controller: 'DashboardController',
    controllerAs: 'vm'
    resolve:
      Projects: ['Resource', (Resource) ->
        Resource '/projects/:id', {id: @id}, [
          {method: 'GET', isArray: false},
          {name: 'search', method: 'POST', isArray: false}
        ]
      ]

  .state 'projects.chart',
    url: '/:slug/:chart/:from/:to',
    templateUrl: 'templates/stores/chart'
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

@application.run ['$rootScope', '$state', '$stateParams', '$http', ($rootScope, $state, $stateParams, $http) ->
  $rootScope.$state = $state
  $rootScope.$stateParams = $stateParams
  $rootScope.locale = $("meta[name=locale]").attr('content')

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
