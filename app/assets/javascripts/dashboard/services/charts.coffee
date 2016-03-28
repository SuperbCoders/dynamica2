@application.factory 'Charts', ['$http', ($http) ->
  new class Charts
    constructor: ->
      @project = undefined
      @range = undefined
      @data = {test: '123'}

    full_chart_data: ->
      return unless @project
      @fetch('full_chart_data')


    big_chart_data: ->
      return unless @project
      console.log "big_chart_data for #{@project.name}"


    other_chart_data: ->
      return unless @project
      console.log "other_chart_data for #{@project.name}"


    sorted_full_chart_data: ->
      return unless @project
      console.log "sorted_full_chart_data for #{@project.name}"

    fetch: (chart_type) ->
      vm = @

      return false if not @project

      chart_url = "/charts_data/#{chart_type}"
      chart_params =
        from: @range.raw_start.format('DD-MM-YYYY')
        to: @range.raw_end.format('DD-MM-YYYY')
        project_id: @project.id
        chart: @range.chart

      $http.get chart_url, params: chart_params

    start_loading: ->
      $('.pageOverlay').addClass 'show_overlay'
      return

    stop_loading: ->
      $('.pageOverlay').removeClass 'show_overlay'
      return

]
