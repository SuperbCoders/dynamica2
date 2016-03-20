@application.factory 'Charts', ['$http', ($http) ->
  new class Charts
    constructor: ->
      @project = {}

    set_project: (project) -> @project = project

    getNewTweets: ->
      return unless @project
      request = $http.get '/tweets', params: { ts: @timestamp }
      request.then (result) =>
        @tweets = result.data
        @timestamp = Date.now()

    full_chart_data: ->
      return unless @project
      console.log "full_chart_data for #{@project.name}"


    big_chart_data: ->
      return unless @project
      console.log "big_chart_data for #{@project.name}"


    other_chart_data: ->
      return unless @project
      console.log "other_chart_data for #{@project.name}"


    sorted_full_chart_data: ->
      return unless @project
      console.log "sorted_full_chart_data for #{@project.name}"
]
