@application.factory 'requestOverlay', [ '$q', ($q) ->
  overlay =
    request: (request) ->
      if request.url && request.url.indexOf('chart_data') > 1
        console.log 'Added overlay for '+request.url
        $('.pageOverlay').addClass('show_overlay')
      request

    response: (response) ->
      $('.pageOverlay').removeClass('show_overlay')
      response

    requestError: (request) ->
      $('.pageOverlay').removeClass('show_overlay')
      request

    responseError: (response) ->
      $('.pageOverlay').removeClass('show_overlay')
      response

  overlay
]
