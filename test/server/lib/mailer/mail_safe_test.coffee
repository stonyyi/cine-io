mailSafe = Cine.server_lib('mailer/mail_safe')

describe 'mailSafe', ->
  it 'should reject non cine.io emails', ->
    message =
      to: [
        {name:'Thomas GS', email: 'thomas@cine.io'}
        {name: 'Thomas Gmail', email: 'thomas@gmail.com'}
      ]
      cc: [
        {name:'Optimus Prime GS', email: 'optimus@cine.io'}
        {name: 'Optimus Prime Gmail', email: 'optimus@gmail.com'}
      ]
      bcc: [
        {name:'Gandalf GS', email: 'gandalf@cine.io'}
        {name: 'Gandalf Gmail', email: 'gandalf@gmail.com'}
      ]
    mailSafe(message)
    expect(message.to).to.deep.equal([{name:'Thomas GS', email: 'thomas@cine.io'}])
    expect(message.cc).to.deep.equal([{name:'Optimus Prime GS', email: 'optimus@cine.io'}])
    expect(message.bcc).to.deep.equal([{name:'Gandalf GS', email: 'gandalf@cine.io'}])
