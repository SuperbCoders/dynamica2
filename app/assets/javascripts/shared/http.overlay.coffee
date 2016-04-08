@application.factory 'requestOverlay', [ '$q', ($q) ->
  overlay =
    request: (request) ->
      if request.url
        if request.url.indexOf('charts_data') >= 1 or request.url.indexOf('products_characteristics') > 1
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
