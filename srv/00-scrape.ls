require! soap
require! async
require! fs

date = new Date!
  ..setFullYear 2009
  ..setMonth 8
  ..setDate 1
now = Date.now!
toSoapDate = ->
  "#{it.getFullYear!}-#{toDouble it.getMonth! + 1}-#{toDouble it.getDate!}"

toDouble = -> if it < 10 then "0#it" else it
checkDate = -> now > date.getTime!
download = (cb) ->
  d = toSoapDate date
  console.log "Getting " + d
  (err, client) <~ soap.createClient "http://support-apps.cro.cz/services/pocasi/wsdl"
  params = env: getParams: den: "#{d} 10:00:00"
  console.log params
  (err, response) <~ client.getWeatherReviewRecords params
  xml = response
    .return
    .item
    .filter( -> it.key.'$value' == 'data')
    .0.value.$value
  # console.log xml
  fs.writeFile "#__dirname/../data/raw/#d.xml", xml

  date.setTime do
    date.getTime! + 86400 * 1e3
  cb!

<~ download!
# console.log checkDate!
# return
# <~ async.whilst checkDate, download
