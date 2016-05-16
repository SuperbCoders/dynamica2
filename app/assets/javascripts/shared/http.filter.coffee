@application.factory 'httpFilter', [ '$q', '$rootScope', ($q, $rootScope) ->
  overlay =
    request: (request) ->

      if request.url
        if request.method is 'GET' and request.url.indexOf('charts_data') >= 1

          date_from = moment(request.params.from, 'MM.DD.YYYY')
          date_to = moment(request.params.to, 'MM.DD.YYYY')
          $rootScope.save_dates_to_ls(date_from, date_to)
      request

    response: (response) ->
      response

    requestError: (request) ->
      request

    responseError: (response) ->
      response

  overlay
]
