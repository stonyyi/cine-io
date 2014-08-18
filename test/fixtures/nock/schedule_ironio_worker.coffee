_extend = require('underscore').extend

ironIOResponse =
  msg:"Queued up"
  tasks:[
    id:'5359a10cac845a1dd20084ef'
  ]

module.exports = (jobName, jobPayload={}, options={})->
  payload =
    environment:
      NODE_ENV:"test"
      MONGOHQ_URL:"mongodb://localhost/cineio-test"
      MANDRILL_APIKEY:"J33rrY3UdBYa9bbwky7Rcw"

      EDGECAST_TOKEN: "2580b744-962a-44d9-9e95-df7fa6e39e13"
      EDGECAST_FTP_HOST: 'ftp.vny.C45E.edgecastcdn.net'
      EDGECAST_FTP_USER: 'fake-account'
      EDGECAST_FTP_PASSWORD: 'fake-password'

    jobPayload: jobPayload
    jobName: jobName

  postBody =
    tasks:[
      _extend({
        'code_name': 'MainWorker',
        'payload': JSON.stringify(payload)
      }, options)
    ]

  nockCall = nock('https://worker-aws-us-east-1.iron.io:443:443')
    .post('/2/projects/53c5eda8bf42cb0005000004/tasks', postBody)
    .reply(200, JSON.stringify(ironIOResponse))
  return nock: nockCall, postBody: postBody
