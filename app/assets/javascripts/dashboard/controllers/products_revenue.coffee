class ProductsRevenueController
  constructor: (@rootScope, @scope, @Projects, @http, @T, @filter) ->
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = 'products_revenue'
    vm.project = @rootScope.$stateParams.project
    vm.sortType = ''
    vm.sortReverse = false
    vm.date_range = 0
    vm.itemsPerPage = 50
    vm.range =
      chart: vm.chart
      from: @rootScope.$stateParams.from
      to: @rootScope.$stateParams.to

    vm.datepicker = $('.datePicker')

    # Scopes
    vm.products_view = 'none'

    @rootScope.$state.go('projects.list') if not vm.range.from or not vm.range.to

    @scope.$watch('vm.products_view', (old) ->
      console.log 'Watch vm.products_view '+old
      vm.products = []
      vm.sales = 0
      vm.gross_revenue = 0

      $('.pageOverlay').addClass('show_overlay')

      switch old

        when 'all_products'
          for p in vm.raw_products
            vm.sales += p.sales
            vm.gross_revenue += p.gross_revenue
            vm.products.push angular.copy(p)

        when 'best_sellers'
          vm.bestsellers_products = vm.filter('orderBy')(vm.raw_products, 'sales', true)
          vm.bestsellers_products = vm.bestsellers_products.slice(0, 50)
          for p in vm.bestsellers_products
            vm.sales += p.sales
            vm.gross_revenue += p.gross_revenue
            vm.products.push angular.copy(p)

        when 'rule_80_20'
          vm.products_80 = []
          vm.products_20 = []
          vm.total_gross_revenue = 0
          vm.sorted_products = vm.filter('orderBy')(vm.raw_products, 'sales', true)
          temp = 0
          slice_index = 0

          total_products = vm.sorted_products.length

          # Sum product gross_revenue with total
          vm.total_gross_revenue += p.gross_revenue for p in vm.sorted_products

          # Set product ranks and culumative_revenue
          for product, index in vm.sorted_products
            slice_index = index
            if index < total_products - 1
              product.rank = index + 1
              product.culumative_revenue = product.gross_revenue + vm.sorted_products[index + 1].gross_revenue
              product.culumative_precentage = (product.culumative_revenue.toFixed(2) / vm.total_gross_revenue.toFixed(2)) * 100

              vm.temp += product.culumative_precentage

              break if temp > 60

          vm.products_80 = vm.sorted_products.slice(0, slice_index)
          vm.products_20 = vm.sorted_products.slice(slice_index, total_products)

      $('.pageOverlay').removeClass('show_overlay')
    )

    @init_dashboard()

    # Set datepicker dates
    console.log vm.range
    vm.range.raw_start = rangeStart = moment(vm.range.from, 'MM.DD.YYYY')
    vm.range.raw_end = rangeEnd = moment(vm.range.to, 'MM.DD.YYYY')
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    vm.rootScope.set_datepicker_date(vm.datepicker, rangeStart, rangeEnd)

    @Projects.search({slug: vm.slug}).$promise.then( (project) ->
      vm.project = project
      vm.rootScope.set_datepicker_start_date(vm.datepicker, vm.project.first_product_data)
      vm.fetch()
    )

  fetch: ->
    return if not @project
    vm = @
    chart_url = "/charts_data/products_characteristics"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.raw_products = []
    vm.products = []
    vm.http.get(chart_url, params: chart_params).success((response) ->
      vm.raw_products = response

      if vm.raw_products.length > 0
        if vm.products_view == 'none'
          vm.products_view = 'all_products'
        else
          temp_view = vm.products_view
          vm.products_view = 'none'
          vm.products_view = temp_view
    )

  datepicker_changed: ->
    vm = @
    dates = vm.datepicker_date.split(' – ')

    if dates.length == 2
      vm.range.raw_start = moment(dates[0])
      vm.range.raw_end = moment(dates[1])
      vm.range.from = vm.range.raw_start.format('MM.DD.YYYY')
      vm.range.to = vm.range.raw_end.format('MM.DD.YYYY')
      vm.fetch()

  fit2Limits: (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  set_date_range: (range_type) ->
    vm = @
    return if range_type not in ["0","1","2","3","4","5","6"]
    return if not vm.datepicker

    vm.rootScope.set_date_range(vm.range, parseInt(range_type))
    vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
    vm.fetch()
    return

  init_dashboard: ->
    vm = @
    $('.selectpicker').selectpicker({size: 70, showTick: false, showIcon: false})
    $('.page').addClass('dashboard_page')

    vm.datepicker.datepicker(
      multidate: 2
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – ')

    wnd = $(window)
    scrollParent = $('.scrollParent')
    doc = $(document)
    scrollBottomFixed = $('.scrollBottomFixed')

    $(window).scroll ->
      if scrollParent.offset().top - doc.scrollTop() + scrollBottomFixed.height() + scrollBottomFixed.css('marginTop').replace('px', '') * 1 <= wnd.height()
        scrollBottomFixed.addClass('table-footer-fixed').removeClass 'table-footer-bottom'
      if scrollParent.offset().top - doc.scrollTop() > wnd.height() - (scrollBottomFixed.height() * 2)
        scrollBottomFixed.removeClass('table-footer-fixed').removeClass 'table-footer-bottom'
      if doc.scrollTop() + wnd.height() - scrollBottomFixed.height() >= scrollParent.offset().top + scrollParent.height()
        scrollBottomFixed.removeClass('table-footer-fixed').addClass 'table-footer-bottom'

  parse_diff: (diff_str) -> parseInt(diff_str)
  chart_changed: (chart) -> @rootScope.$state.go('projects.chart', {project: @project,slug: @project.slug,chart: @range[chart],from: @range.from,to: @range.to})
  toggle_debug: -> if @debug is true then @debug = false else @debug = true
@application.controller 'ProductsRevenueController', ['$rootScope', '$scope', 'Projects', '$http', 'Translate', '$filter', ProductsRevenueController]
