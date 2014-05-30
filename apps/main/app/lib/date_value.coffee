module.exports =
  _dateValue: (attr)->
    dateValue = @get(attr)
    return null if !dateValue? || dateValue == ''
    new Date(dateValue)
