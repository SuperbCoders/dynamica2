@application.factory 'Projects', (Resource) ->
  Resource '/projects/:id', {id: @id}, [
    {method: 'GET', isArray: false},
    {name: 'search', method: 'POST', isArray: false}
  ]
