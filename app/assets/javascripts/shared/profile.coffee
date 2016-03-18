@application.factory 'Profile', ['Resource', (Resource) ->
  class Profile
    Resource '/profile', {id: @id}, [ {method: 'GET', isArray: false} ]

  new Profile
]
