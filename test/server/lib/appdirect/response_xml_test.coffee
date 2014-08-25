responseXML = Cine.server_lib('appdirect/response_xml')
Account = Cine.server_model('account')
Project = Cine.server_model('project')

describe 'responseXML', ->

  it 'creates xml', ->
    response = responseXML(hey: 'buddy', lets: 'play')
    expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <hey>buddy</hey>\n  <lets>play</lets>\n</result>")

  describe '.unknownError', ->
    it 'creates xml', ->
      response = responseXML.unknownError()
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>UNKNOWN_ERROR</errorCode>\n  <message>An unknown error occured</message>\n</result>")

  describe '.unauthorized', ->
    it 'creates xml', ->
      response = responseXML.unauthorized("could not auth yo")
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>UNAUTHORIZED</errorCode>\n  <message>could not auth yo</message>\n</result>")

  describe '.configurationError', ->
    it 'creates xml', ->
      response = responseXML.configurationError()
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>CONFIGURATION_ERROR</errorCode>\n  <message>Our server is not configured to handle this request.</message>\n</result>")

  describe '.invalidResponse', ->
    it 'creates xml', ->
      response = responseXML.invalidResponse()
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>INVALID_RESPONSE</errorCode>\n  <message>Could not fetch event details.</message>\n</result>")

  describe '.userExists', ->
    it 'creates xml', ->
      response = responseXML.userExists("some-email")
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>USER_ALREADY_EXISTS</errorCode>\n  <message>The account for some-email already exists.</message>\n</result>")

  describe '.userDoesNotExist', ->
    it 'creates xml', ->
      response = responseXML.userDoesNotExist('some-non-email')
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>USER_NOT_FOUND</errorCode>\n  <message>The account for some-non-email does not exist.</message>\n</result>")

  describe '.accountDoesNotExist', ->
    it 'creates xml', ->
      response = responseXML.accountDoesNotExist('some-account-id')
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>false</success>\n  <errorCode>ACCOUNT_NOT_FOUND</errorCode>\n  <message>The account some-account-id does not exist.</message>\n</result>")

  describe '.userAssigned', ->
    it 'creates xml', ->
      response = responseXML.userAssigned()
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n</result>")

  describe '.userUnAssigned', ->
    it 'creates xml', ->
      response = responseXML.userUnAssigned()
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <message>User unassigned successfully.</message>\n</result>")

  describe '.accountCreated', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.accountCreated(account)
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The account for this email was created.</message>\n</result>")

  describe '.planChanged', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.planChanged(account)
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The account for this email was changed to starter.</message>\n</result>")

  describe '.accountCanceled', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.accountCanceled(account)
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The account for this email was canceled.</message>\n</result>")

  describe '.accountDeactivated', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.accountDeactivated(account)
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The account for this email was deactivated.</message>\n</result>")

  describe '.accountReactivated', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.accountReactivated(account)
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The account for this email was reactivated.</message>\n</result>")

  describe '.addonAdded', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.addonAdded(account, 'test')
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <id>test</id>\n  <message>The addon test was added to the account for this email.</message>\n</result>")

  describe '.addonRemoved', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.addonRemoved(account, 'test')
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The addon test was removed from the account for this email.</message>\n</result>")

  describe '.addonBind', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      project = new Project(secretKey: 'my sec', publicKey: 'dat pub')
      response = responseXML.addonBind(account, project, 'test')
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <metadata>\n    <entry>\n      <key>secretKey</key>\n      <value>my sec</value>\n    </entry>\n    <entry>\n      <key>publicKey</key>\n      <value>dat pub</value>\n    </entry>\n  </metadata>\n  <message>The addon test was bound with the account for this email.</message>\n</result>")

  describe '.addonUnBind', ->
    it 'creates xml', ->
      account = new Account(billingEmail: 'this email', plans: ['starter'])
      response = responseXML.addonUnBind(account, 'test')
      expect(response).to.equal("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<result>\n  <success>true</success>\n  <accountIdentifier>#{account._id.toString()}</accountIdentifier>\n  <message>The addon test was unbound from the account for this email.</message>\n</result>")
