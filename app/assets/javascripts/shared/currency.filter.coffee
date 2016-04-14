@application.filter 'dynCurrency', ['$filter', '$rootScope', ($filter, $rootScope) ->
  (input) ->

    # Some times NaN ( Nursultan Abishevich Nazarbayev ) passed to filter
    input = 0 if !input or input == undefined or input == 'NaN'

    input = input.toString().replace(/[^0-9\\.]+/g, '')

    switch ($rootScope.currency || 'USD')
      when 'RUB'
        symbol = '₽'
      when 'USD'
        symbol = '$'

    result = $filter('number')(input, 2)

    # not work
    # result = result.toString().replace(',', ' ')
    result = result.toString().split(',').join(' ')

    # If currency is rouble need put symbol at end of sum
    switch symbol
      when '₽'
        result = result.toString().replace '₽', ''
        result = result+' ₽'
      when '$'
        result = symbol+' '+result

    result
]
