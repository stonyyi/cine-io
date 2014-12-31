# https://github.com/HubSpot/humanize/blob/master/coffee/src/humanize.coffee
humanizeNumber = Cine.lib('humanize_number')
pluralize = Cine.lib('pluralize')

TiB = 1099511627776
GiB = 1073741824
MiB = 1048576
KiB = 1024

module.exports = (filesize, thousand=',', places=2) ->
  if filesize >= TiB
    sizeStr = humanizeNumber(filesize / TiB, places, thousand) + " TiB"
  else if filesize >= GiB
    sizeStr = humanizeNumber(filesize / GiB, places, thousand) + " GiB"
  else if filesize >= MiB
    sizeStr = humanizeNumber(filesize / MiB, places, thousand) + " MiB"
  else if filesize >= KiB
    sizeStr = humanizeNumber(filesize / KiB, 0, thousand) + " KiB"
  else
    sizeStr = humanizeNumber(filesize, 0) + pluralize(filesize, " byte")

  sizeStr

module.exports.formatString = (filesize)->
  if filesize >= TiB
    return "TiB"
  else if filesize >= GiB
    return "GiB"
  else if filesize >= MiB
    return "MiB"
  else if filesize >= KiB
    return "KiB"
  else
    return "byte"

module.exports.TiB = TiB
module.exports.GiB = GiB
module.exports.MiB = MiB
module.exports.KiB = KiB
