# http://localhost:3000/draw/block?project_id=5&from=12.08.2013&to=12.08.2015
wp = require('webpage')
args = require('system').args

pages = {}

chart_types = ['donut', 'block', 'big']
donut_charts = ['new_and_repeat_customers_number', 'order_statuses']

charts = [
  'total_gross_revenues', 'total_gross_delivery', 'shipping_cost_as_a_percentage_of_total_revenue',
  'average_order_value', 'average_order_size', 'order_statuses', 'orders_number',
  'customers_number', 'new_customers_number', 'repeat_customers_number', 'average_revenue_per_customer',
  'sales_per_visitor', 'average_customer_lifetime_value', 'unique_users_number', 'visits',
  'new_and_repeat_customers_number', 'products_in_stock_number', 'items_in_stock_number', 'percentage_of_inventory_sold',
  'percentage_of_stock_sold', 'products_number'
]

options =
  prefix: ''
  url: ''
  project_id: 0
  from: 0
  to: 0

# Parse args and save to options
check_options = ->
  if not options.folder
    throw new Error('please pass images folder path at --folder')
  else
    console.log 'Image folder path : '+options.folder

  if not options.chart_type
    throw new Error('please pass --chart_type')
  else
    console.log 'ChartType : '+options.chart_type

  if not options.chart
    throw new Error('please pass --chart')
  else
    console.log 'Chart : '+options.chart

  if not options.project_id
    throw new Error('please pass --project_id')
  else
    console.log 'ProjectID : '+options.project_id

  if not options.from
    throw new Error('please pass --from in 13.08.1900 format')
  else
    console.log 'Date from : '+options.from

  if not options.to
    throw new Error('please pass --to in 13.08.1900 format')
  else
    console.log 'Date to : '+options.to

  if not options.prefix
    throw new Error('please pass --prefix')
  else
    console.log 'Prefix : '+options.prefix

parse_args = ->
  args.forEach (arg, i) ->
    arg_name = arg.split('=')[0]
    arg_value = arg.split('=')[1]

    switch arg_name
      when '--folder' then options.folder = arg_value
      when '--chart_type' then options.chart_type = arg_value if arg_value in chart_types
      when '--chart' then options.chart = arg_value if arg_value in charts
      when '--prefix' then options.prefix = arg_value
      when '--project_id' then options.project_id = arg_value
      when '--from' then options.from = arg_value
      when '--to' then options.to = arg_value
      when '--env' then options.env = arg_value

    return

imagePath = -> options.folder+'/'+options.prefix+'_'+options.chart_type+'_'+options.chart+'.png'

parse_args()
check_options()

# Request URL
if options.env is 'staging'
  host = 'http://dev-dyn2.onomnenado.ru/'
else if options.env is 'development'
  host = 'http://localhost:3000/'

url = "#{host}/draw/#{options.chart_type}?project_id=#{options.project_id}&from=#{options.from}&to=#{options.to}&chart="+options.chart

page = wp.create({url: url})
page.viewportSize = { width: 1280, height: 1024 };
page.onResourceRequested = (request) ->
  console.log '= onResourceRequested()'
  console.log '  request: ' + JSON.stringify(request, undefined, 4)
  return

page.onResourceReceived = (response) ->
  console.log '= onResourceReceived()'
  console.log '  id: ' + response.id + ', stage: "' + response.stage + '", response: ' + JSON.stringify(response)
  return

page.onLoadStarted = ->
  console.log '= onLoadStarted()'
  currentUrl = page.evaluate(->
    window.location.href
  )
  console.log '  leaving url: ' + currentUrl
  return

page.onLoadFinished = (status) ->
  console.log '= onLoadFinished()'
  console.log '  status: ' + status
  return

page.onNavigationRequested = (url, type, willNavigate, main) ->
  console.log '= onNavigationRequested'
  console.log '  destination_url: ' + url
  console.log '  type (cause): ' + type
  console.log '  will navigate: ' + willNavigate
  console.log '  from page\'s main frame: ' + main
  return

page.onResourceError = (resourceError) ->
  console.log '= onResourceError()'
  console.log '  - unable to load url: "' + resourceError.url + '"'
  console.log '  - error code: ' + resourceError.errorCode + ', description: ' + resourceError.errorString
  return

page.onError = (msg, trace) ->
  console.log '= onError()'
  msgStack = [ '  ERROR: ' + msg ]
  if trace
    msgStack.push '  TRACE:'
    trace.forEach (t) ->
      msgStack.push '    -> ' + t.file + ': ' + t.line + (if t.function then ' (in function "' + t.function + '")' else '')
      return
  console.log msgStack.join('\n')
  return

switch options.chart_type
  when 'big'
    page.clipRect = { top: 0, left: 0, width: 628, height: 520 }
  else
    page.clipRect = { top: 0, left: 0, width: 320, height: 290 }

page.open url, (status) ->
  if status == 'success'
    console.log 'Image for '+options.chart+' saved to '+imagePath()
    page.render imagePath(), {format: 'png', quality: '100'}
  else
    console.log 'Page status : '+status
  phantom.exit()
  return


