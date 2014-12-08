validateSecureIdentity = Cine.server_lib('signaling/validate_secure_identity')

describe 'validateSecureIdentity', ->
  it 'rejects invalid identities', ->
    actual = validateSecureIdentity('thomas', 'my-secret-key', '1418074933', 'invalid-signature')
    expect(actual).to.be.false

  it 'works with string timestamps', ->
    actual = validateSecureIdentity('thomas', 'my-secret-key', '1418074933', '14eebec6b38236826c85708521652103cd8d30e9')
    expect(actual).to.be.true

  it 'works with number timestamps', ->
    actual = validateSecureIdentity('thomas', 'my-secret-key', 1418074933, '14eebec6b38236826c85708521652103cd8d30e9')
    expect(actual).to.be.true
