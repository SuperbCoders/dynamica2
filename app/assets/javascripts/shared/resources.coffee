@application.factory 'Resource', ['$resource',
  ($resource) -> (url, urlDesc, customActions) ->
    actions =
      get:
        method: 'GET'
        isArray: false
      save:
        method: 'PUT'
      create:
        method: 'POST'

    if customActions
      _.forEach customActions, (action) ->
        actions[action.name] =
          method: action.method
          url: [url, action.name].join('/')
          isArray: action.isArray || false

    resource = $resource url, urlDesc, actions
]

@application.factory 'Resources', ['$resource',
  ($resource) -> (url, urlDesc, customActions) ->
    actions =
      save:
        method: 'PUT'
      create:
        method: 'POST'
      remove:
        method: 'DELETE'

    if customActions
      _.forEach customActions, (action) ->
        actions[action.name] =
          method: action.method
          url: [url, action.name].join('/')
          isArray: action.isArray || false

    resources = $resource url, urlDesc, actions


]
