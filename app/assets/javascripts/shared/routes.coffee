@application.factory 'Routes',[ '$rootScope', ($rootScope) ->
  {
    locale: (path) -> '/'+$rootScope.locale+'/'+path
    email_uniqueness_path: -> '/profile/email_uniqueness'
    update_profile_path: -> '/profile'
    show_subscription_path: (project_id) -> '/subscriptions/' + project_id;
    change_subscription_path: -> '/subscriptions/change';
  }
]

