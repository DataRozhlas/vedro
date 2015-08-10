require! {
  fs
}

lines = fs.readFileSync "#__dirname/../data/milesovka.csv" .toString!split "\n"
  ..shift!
  ..pop!
# lines.length = 2
tempsAssoc = {}
for line in lines
  [day, temp] = line.split ","
  temp = parseInt do
    temp.replace "\r" ""
    10

  if temp < -999
    temp = void
  continue if temp is void
  if tempsAssoc[day] is void
    tempsAssoc[day] = temp / 10

objs = for dateStr, temp of tempsAssoc
  year  = parseInt (dateStr.substr 0, 4), 10
  month = parseInt (dateStr.substr 4, 2), 10
  day   = parseInt (dateStr.substr 6, 2), 10
  date = new Date!
    ..setTime 0
    ..setUTCFullYear year
    ..setUTCMonth month - 1
    ..setUTCDate day
  {date, temp}

objs.sort (a, b) -> a.date.getTime! - b.date.getTime!
currentDate = new Date!
  ..setTime objs.0.date.getTime!
lastDate = objs[*-1].date
lastYear = 1906
out = "#lastYear\t"
while currentDate < lastDate
  year = currentDate.getUTCFullYear!
  month = currentDate.getUTCMonth! + 1
  day = currentDate.getUTCDate!
  unless day == 29 and month == 2
    if year != lastYear
      out += "\n#year\t"
      lastYear = year
    else
      out += "\t"
    month = "0#month" if month < 10
    day = "0#day" if day < 10
    str = "#{year}#{month}#{day}"
    out += if tempsAssoc[str] isnt void then tempsAssoc[str] else ''
  currentDate.setTime currentDate.getTime! + 8.64e7
# console.log out
fs.writeFileSync "#__dirname/../data/milesovka.matrix.tsv", out
