canCastAsObjectId = Cine.server_lib('can_cast_as_object_id')
User = Cine.server_model('user')

describe 'canCastAsObjectId', ->
  it 'returns true for an objectId', ->
    id = (new User)._id
    expect(canCastAsObjectId(id)).to.be.true

  it 'returns true for an objectId string', ->
    id = (new User)._id.toString()
    expect(canCastAsObjectId(id)).to.be.true

  it 'returns false for not an objectId', ->

    expect(canCastAsObjectId("not an id")).to.be.false
