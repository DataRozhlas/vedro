ig.drawTemperatures = ->
  years = [1907 to 2015].map (year) ->
    data = []
    {year, data}
  temps = for line, day in ig.data.temps.split "\n"
    line
      .split "\t"
      .map (temp, yearIndex) ->
        temp = parseFloat temp
        year = 1775 + yearIndex
        if !isNaN temp
          years[yearIndex].data[day] = temp
        {temp, day, year}
  len = temps.length
  binValues = []
  cols = for i, index in [0 til len by 3]
    threeDayTemps = temps[i] ++ temps[i + 1] ++ temps[i + 2]
    threeDayTemps .= filter -> !isNaN it.temp
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
  container = d3.select ig.containers.base
    ..classed \temp yes
  yAxis = container.append \div
    ..attr \class "axis y"
    ..selectAll \div.item .data [37 20 0 -20] .enter!append \div
      ..attr \class \item
      ..style \top -> "#{yScale it + 1}px"
      ..html -> it
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
  xAxis = container.append \div
    ..attr \class "axis x"
    ..selectAll \div.item .data months .enter!append \div
      ..attr \class \item
      ..style \width -> "#{it.length / 3 * pointRadius}px"
      ..html -> it.name

  drawOneYear = ->
    svg = container.append \svg
      ..attr {width: width, height}
    line = d3.svg.line!
      ..x (d) -> (d.index + 0.5) * (pointRadius / 3)
      ..y (d) -> yScale d.value
    path = svg.append \path
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
          ..on \mouseout -> undrawYear!

    drawYear = (yearIndex) ->
      data = years[yearIndex].data
        .map (value, index) -> {value, index}
        .filter -> it.value isnt void

      path.attr \d line data

    undrawYear = ->
      path.attr \d ""
    console.log 2015 - 1907
    drawYear 2015 - 1907
    # drawYear 1947 - 1907

  drawOneYear!
  container.append \ul
    ..attr \class \legend
    ..append \li .html "Nejčastější (průměrné) teploty"
    ..append \li .html "Teplotní minima a maxima"



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
    ..selectAll \div .data cols .enter!append \div
      ..attr \class (d, i) -> "col #{if i > 60 then 'right' else ''}"
      ..append \div
        ..attr \class "temp min"
        ..html ->
          day = it.temps.0
          "Nejchladnější den #{toHumanDate day.day, day.year}<br>Průměrně #{day.temp} °C"
        ..style \top -> "#{yScale Math.round it.temps.0.temp}px"
      ..append \div
        ..attr \class "temp max"
        ..html ->
          day = it.temps[*-1]
          "Nejteplejší den #{toHumanDate day.day, day.year}<br>Průměrně #{day.temp}  °C"
        ..style \top -> "#{yScale Math.round it.temps[*-1].temp}px"
      ..append \div
        ..attr \class "temp avg"
        ..html ->
          day = it.temps[Math.round it.temps.length / 2]
          "Průměrná teplota #{day.temp} °C"
        ..style \top -> "#{yScale Math.round it.temps[Math.round it.temps.length / 2].temp}px"
