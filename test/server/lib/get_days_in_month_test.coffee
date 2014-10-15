getDaysInMonth = Cine.server_lib('get_days_in_month')

describe 'getDaysInMonth', ->
  it 'returns the correct amount of days', ->
    jan = new Date(2014, 0)
    expect(getDaysInMonth(jan)).to.equal(31)

    sept = new Date(2014, 8)
    expect(getDaysInMonth(sept)).to.equal(30)

  it 'returns the correct amount of days for a leap year', ->
    feb = new Date(2014, 1)
    expect(getDaysInMonth(feb)).to.equal(28)
    feb = new Date(2016, 1)
    expect(getDaysInMonth(feb)).to.equal(29)
