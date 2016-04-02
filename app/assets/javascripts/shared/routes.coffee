@application.factory 'Routes',[ '$rootScope', ($rootScope) ->
  {
    locale: (path) -> '/'+$rootScope.locale+'/'+path
    email_uniqueness_path: -> '/profile/email_uniqueness'
  }
]

