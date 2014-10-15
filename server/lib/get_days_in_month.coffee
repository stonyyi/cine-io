# days is 1 based, so 0 is the same as subtracting 1 day
module.exports = (month)->
  d = new Date(month.getFullYear(), month.getMonth()+1, 0)
  d.getDate()
