class ProductsRevenueController
  constructor: (@rootScope, @scope, @Projects, @http, @filter) ->
    console.log 'ProductsRevenueController'
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = 'products_revenue'
    vm.products_view = 'none'
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

    # return to projets list if date range not present in URL
    @rootScope.$state.go('projects.list') if not vm.range.from or not vm.range.to

    # Watch products view switcher for products table
    @scope.$watch('vm.products_view', (products_view) ->
      # Clear products lists and counters
      vm.products = []
      vm.sales = 0
      vm.gross_revenue = 0

      vm.rootScope.overlay('show')

      switch products_view

        when 'all_products'
          vm.products_count = 0
          for p in vm.raw_products
            vm.products_count += 1
            vm.sales += p.sales
            vm.gross_revenue += p.gross_revenue
            vm.products.push angular.copy(p)

        when 'best_sellers'
          vm.products_count = 0
          vm.bestsellers_products = vm.filter('orderBy')(vm.raw_products, 'sales', true)
          vm.bestsellers_products = vm.bestsellers_products.slice(0, 50)
          for p in vm.bestsellers_products
            vm.products_count += 1
            vm.sales += p.sales
            vm.gross_revenue += p.gross_revenue
            vm.products.push angular.copy(p)

        when 'rule_80_20'
          # 60% is stop for calculating 80/20
          stop_percent = 60
          vm.products_80 = []
          vm.products_20 = []
          vm.gross_revenue = 0
          temp = 0
          slice_index = 0

          # Sort all products by sales field
          vm.sorted_products = vm.filter('orderBy')(vm.raw_products, 'sales', true)

          total_products = vm.sorted_products.length

          # Sum product gross_revenue with total
          for p in vm.sorted_products
            vm.sales += p.sales
            vm.gross_revenue += p.gross_revenue

          # Set product ranks and culumative_revenue
          for p, index in vm.sorted_products
            slice_index = index
            if index < total_products - 1
              p.rank = index + 1

              # product culumative_revenue is sum of product gross_revenue and prev product gross_revenue
              p.culumative_revenue = p.gross_revenue + vm.sorted_products[index + 1].gross_revenue

              # culumative precentage is precent culumative_revenue of total_gross_revenue
              p.culumative_precentage = (p.culumative_revenue.toFixed(2) / vm.gross_revenue.toFixed(2)) * 100

              temp += p.culumative_precentage

              break if temp > stop_percent

          # Slice to 80/20 arrays
          vm.products_80 = vm.sorted_products.slice(0, slice_index)
          vm.products_20 = vm.sorted_products.slice(slice_index, total_products)

          # Now need concat with divider
          vm.products = _.concat(
            [{divider: true, divider_title: '80% made of revenue'}],
            vm.products_80,
            [{divider: true, divider_title: '20% made of revenue'}],
            vm.products_20
          )

          vm.products_count = vm.products.length - 2

      vm.rootScope.overlay('hide')
    )

    @init_dashboard()

    # Set datepicker dates
    vm.range.raw_start = rangeStart = moment(vm.range.from, 'MM.DD.YYYY')
    vm.range.raw_end = rangeEnd = moment(vm.range.to, 'MM.DD.YYYY')
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    @Projects.search({slug: vm.slug}).$promise.then( (project) ->
      vm.project = project
      vm.rootScope.currency = vm.project.currency
      vm.rootScope.set_datepicker_start_date(vm.datepicker, vm.project.first_product_data)
      vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
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

    vm.rootScope.overlay('show')

    vm.raw_products = []
    vm.products = []
    vm.http.get(chart_url, params: chart_params).success((response) ->
      vm.raw_products = response
      vm.products_count = vm.raw_products.length
      if vm.raw_products.length > 0
        if vm.products_view == 'none'
          vm.products_view = 'all_products'
        else
          temp_view = vm.products_view
          vm.products_view = 'none'
          vm.products_view = temp_view

      vm.rootScope.overlay('hide')
    )

  datepicker_changed: ->
    vm = @
    dates = vm.datepicker_date.split(' – ')

    if dates.length == 2

      vm.range.raw_start = moment(dates[0], "MMM D, YYYY")
      vm.range.raw_end = moment(dates[1], "MMM D, YYYY")
      vm.range.from = vm.range.raw_start.format('MM.DD.YYYY')
      vm.range.to = vm.range.raw_end.format('MM.DD.YYYY')
      vm.fetch()

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

    $(window).scrollTop(100)
    $(window).scroll ->
      if scrollParent.offset().top - doc.scrollTop() + scrollBottomFixed.height() + scrollBottomFixed.css('marginTop').replace('px', '') * 1 <= wnd.height()
        scrollBottomFixed.addClass('table-footer-fixed').removeClass 'table-footer-bottom'
      if scrollParent.offset().top - doc.scrollTop() > wnd.height() - (scrollBottomFixed.height() * 2)
        scrollBottomFixed.removeClass('table-footer-fixed').removeClass 'table-footer-bottom'
      if doc.scrollTop() + wnd.height() - scrollBottomFixed.height() >= scrollParent.offset().top + scrollParent.height()
        scrollBottomFixed.removeClass('table-footer-fixed').addClass 'table-footer-bottom'

  state_is: (name) -> @rootScope.state_is(name)
  parse_diff: (diff_str) -> parseInt(diff_str)
  chart_changed: (chart) -> @rootScope.$state.go('projects.chart', {project: @project,slug: @project.slug,chart: @range[chart],from: @range.from,to: @range.to})
  toggle_debug: -> if @debug is true then @debug = false else @debug = true

@application.controller 'ProductsRevenueController', ['$rootScope', '$scope', 'Projects', '$http', '$filter', ProductsRevenueController]
