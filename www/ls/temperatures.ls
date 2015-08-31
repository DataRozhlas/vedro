isComparingGraph = window.location.hash == '#47'
ig.drawTemperatures = ->
  years = [1907 to 2015].map (year) ->
    data = []
    {year, data}
  temps = for line, day in ig.data.temps.split "\n"
    line
      .split "\t"
      .map (temp, yearIndex) ->
        temp = parseFloat temp
        year = 1907 + yearIndex
        if !isNaN temp
          years[yearIndex].data[day] = temp
        {temp, day, year}
  len = temps.length
  binValues = []
  cols = for i, index in [0 til len by 3]
    threeDayTemps = temps[i] ++ temps[i + 1] ++ temps[i + 2]
    threeDayTemps .= filter -> !isNaN it.temp
    if isComparingGraph
      threeDayTemps.sort (a, b) -> a.year - b.year
    else
      threeDayTemps.sort (a, b) -> a.temp - b.temp
    binnedDays = [0 to 58].map -> 0
    for {temp}, ii in threeDayTemps
      bin = Math.round temp + 20
      binValues.push bin
      binnedDays[bin] += 1
    {temps:threeDayTemps, index, binnedDays}

  color = d3.scale.quantize!
    ..range ['#f6f6f6','#fde5d0','#ffd5ac','#ffc489','#ffb361', '#fd8d3c']

  y = 58
  x = 122


  pointRadius = 8

  width = x * pointRadius
  height = y * pointRadius
  yScale = -> height - (it + 20) * pointRadius
  dayDivider = if isComparingGraph
    2
  else
    3

  xScale = (index) -> (index + 0.5) * (pointRadius / dayDivider)
  container = d3.select ig.containers.base
    ..classed \temp yes
    ..classed \comparing isComparingGraph

  yAxis = container.append \div
    ..attr \class "axis y"
    ..selectAll \div.item .data [30 20 0 -20] .enter!append \div
      ..attr \class \item
      ..style \top -> "#{yScale it + 1}px"
      ..html -> it
  unless isComparingGraph
    canvas = container.append \canvas
      ..attr \width "#{width}px"
      ..attr \height "#{height}px"
      ..style \margin-left \23px

    ctx = canvas.node!getContext \2d
    for col, xIndex in cols
      cx = xIndex * pointRadius + 4
      color.domain d3.extent col.binnedDays
      for count, yIndex in col.binnedDays
        continue unless count
        cy = height - yIndex * pointRadius - 4
        ctx.beginPath!
        ctx.fillStyle = color count
        ctx.arc cx, cy, pointRadius / 2 - 0.5, 0, 2 * Math.PI
        ctx.fill!

  drawOverlay container, width, height, cols, yScale

  months =
    * length: 31
      name: "leden"
    * length: 28
      name: "únor"
    * length: 31
      name: "březen"
    * length: 30
      name: "duben"
    * length: 31
      name: "květen"
    * length: 30
      name: "červen"
    * length: 31
      name: "červenec"
    * length: 31
      name: "srpen"
    * length: 30
      name: "září"
    * length: 31
      name: "říjen"
    * length: 30
      name: "listopad"
    * length: 31
      name: "prosinec"
  if isComparingGraph
    months.length = 8
  xAxis = container.append \div
    ..attr \class "axis x"
    ..selectAll \div.item .data months .enter!append \div
      ..attr \class \item
      ..style \width -> "#{it.length / dayDivider * pointRadius}px"
      ..html -> it.name
  svg = null
  drawOneYear = (isSecondary) ->
    svg := container.append \svg
      ..attr {width: width, height}
    line = d3.svg.line!
      ..x (d) -> xScale d.index
      ..y (d) -> yScale d.value
    path = svg.append \path
    unless isComparingGraph
      yearAxis = container.append \div
        ..attr \class \year-axis
        ..append \h2
          ..html "Vyberte rok, jehož teploty chcete zobrazit"
        ..append \ol
          ..selectAll \li .data years .enter!append \li
            ..classed \left (d, i) -> i > 100
            ..append \span
              ..html (d, i) -> d.year
            ..filter ((d, i) -> 8 == i % 20)
              ..classed \big yes
            ..on \mouseover (d, i) -> drawYear i
            ..on \touchstart (d, i) -> drawYear i
            ..on \mouseout -> drawYear 2015 - 1907

    lastYear = years[*-1]
    lastX = xScale lastYear.data.length
    lastY = yScale lastYear.data[*-1]
    yearLegend = svg.append \g
      ..attr \class \year-legend
      ..attr \transform "translate(#lastX, #lastY)"
      ..append \circle
        ..attr \r 3
        ..attr \cx -2
        ..attr \cy -2
    unless isComparingGraph
      yearLegend.append \text
        ..html "9. srpna 2015"
        ..attr \y 4
        ..attr \x 10

    drawYear = (yearIndex) ->
      data = years[yearIndex].data
        .map (value, index) -> {value, index}
        .filter -> it.value isnt void
      if yearLegend
        yearLegend.classed \active yearIndex == 2015 - 1907

      path.attr \d line data


    undrawYear = ->
      path.attr \d ""
    {drawYear}

  drawComparison = (yearIndex1, yearIndex2) ->
    lastValue = null
    len = years[yearIndex1].data.length

    year1 = for i in [0 til len]
      value = years[yearIndex1].data[i]
      if value
        lastValue := value
        value
      else
        lastValue
    year2 = for i in [0 til len]
      value = years[yearIndex2].data[i]
      if value
        lastValue := value
        value
      else
        lastValue


    area1 = d3.svg.area!
      ..x (d, i) -> xScale i
      ..y1 (d, i) ->
        if year1[i] <= year2[i]
          yScale year2[i]
        else
          yScale year1[i]
      ..y0 (d, i) ->
        yScale year2[i]
    svg.append \path
      ..attr \class "area area1"
      ..attr \d area1 year1
    [year1, year2] = [year2, year1]
    svg.append \path
      ..attr \class "area area2"
      ..attr \d area1 year1

  drawOneYear!
    ..drawYear 2015 - 1907
  if isComparingGraph
    drawOneYear yes
      ..drawYear 1947 - 1907
    drawComparison do
      2015 - 1907
      1947 - 1907

  unless isComparingGraph
    container.append \ul
      ..attr \class \legend
      ..append \li .html "Obvyklá nejvyšší teplota"
      ..append \li .html "Teplotní extrémy"
  else
    container.append \ul
      ..attr \class \legend
      ..append \li .html "Rok 1947"
      ..append \li .html "Rok 2015"

index47 = 1947 - 1907
drawOverlay = (container, width, height, cols, yScale) ->

  date = new Date!
    ..setHours 12

  toHumanDate = (dayIndex, year) ->
    startDay = dayIndex + 1
    date
      ..setMonth 0
      ..setDate startDay
      ..setFullYear year
    "#{date.getDate!}. #{date.getMonth! + 1}. #{date.getFullYear!}"

  monthContainer = container.append \div
    ..attr \class \monthContainer
    ..style \width "#{width}px"
    ..style \height "#{height}px"
  if isComparingGraph
    cols.length = 81
    monthContainer.selectAll \div .data cols .enter!append \div
      ..attr \class (d, i) -> "col #{if i > 60 then 'right' else ''}"
      ..attr \data-prdel (d, i) -> i
      ..append \div
        ..attr \class "temp min"
        ..html ->
          for day in it.temps
            break if day.year == 1947
          "Nejvyšší teplota #{toHumanDate day.day, day.year}: #{day.temp} °C"
        ..style \top ->
          for day in it.temps
            break if day.year == 1947
          y = yScale Math.round day.temp

          currentDay = it.temps[*-1]
          if currentDay.year == 2015
            currentY = yScale Math.round currentDay.temp
            diff = Math.abs currentY - y
            if diff < 25
              if currentY < y
                y += 25 - diff
              else
                y -= 25 - diff
          "#{y}px"
      ..append \div
        ..attr \class "temp max"
        ..html ->
          day = it.temps[*-1]
          return void if day.year != 2015
          "Letošní nejvyšší teplota #{day.temp}  °C"
        ..style \top ->
          day = it.temps[*-1]
          return 999 if day.year != 2015
          "#{yScale Math.round day.temp}px"

  else
    monthContainer.selectAll \div .data cols .enter!append \div
      ..attr \class (d, i) -> "col #{if i > 60 then 'right' else ''}"
      ..append \div
        ..attr \class "temp min"
        ..html ->
          day = it.temps.0
          "Nejchladnější den #{toHumanDate day.day, day.year}<br>Nejvyšší teplota #{day.temp} °C"
        ..style \top -> "#{yScale Math.round it.temps.0.temp}px"
      ..append \div
        ..attr \class "temp max"
        ..html ->
          day = it.temps[*-1]
          "Nejteplejší den #{toHumanDate day.day, day.year}<br>Nejvyšší teplota #{day.temp}  °C"
        ..style \top -> "#{yScale Math.round it.temps[*-1].temp}px"
      ..append \div
        ..attr \class "temp avg"
        ..html ->
          day = it.temps[Math.round it.temps.length / 2]
          "Obvyklé teplotní maximum: #{day.temp} °C"
        ..style \top -> "#{yScale Math.round it.temps[Math.round it.temps.length / 2].temp}px"

