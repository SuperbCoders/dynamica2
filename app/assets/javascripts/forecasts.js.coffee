$ ->
  if $('.case-project-edit').length

    $depthInput = $('input#forecast_depth')
    $depthInput.autoNumeric('init', {aSep: '', mDec: '0', wEmpty: 'zero', lZero: 'deny'})

    depth = ->
      value = parseInt($depthInput.val(), 10)
      if isNaN(value) then 0 else value
      

    $('body').on 'click', '.el-arrow-minus', (event) ->
      event.preventDefault()
      if depth() > 1
        $depthInput.val(depth() - 1)

    $('body').on 'click', '.el-arrow-plus', (event) ->
      event.preventDefault()
      $depthInput.val(depth() + 1)