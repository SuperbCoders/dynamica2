@application.factory 'Routes',[ '$rootScope', ($rootScope) ->
  {
    locale: (path) -> '/'+$rootScope.locale+'/'+path
    destroy_avatar_path: -> @locale('/profile/avatar/destroy')
    upload_avatar_path: -> @locale('/profile/avatar/upload')
    email_uniqueness_path: -> '/profile/email_uniqueness'
    update_profile_path: -> @locale('/profile')
    show_subscription_path: -> @locale('/subscriptions/show')
    change_subscription_path: -> @locale('/subscriptions/change')
  }
]

