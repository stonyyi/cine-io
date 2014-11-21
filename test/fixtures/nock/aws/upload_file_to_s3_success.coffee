original = (fileName, fileContents, options)->
  nock('https://cine-io-hls.s3.amazonaws.com:443')
    .put("/#{fileName}", fileContents)
    .reply(200, "", { 'x-amz-id-2': 'pUygvEyjqX1IleQ2RA8UltFJayOTlzieQ89J+3TnZSGetqSk50UWjcs1W3M2FAsT',
    'x-amz-request-id': '03108629EDFF2B6C',
    date: 'Tue, 18 Nov 2014 02:51:09 GMT',
    etag: '"26bb73556ceb32a5df30b733c5355ee5"',
    'content-length': '0',
    server: 'AmazonS3' })

first = (fileName, fileContents, options)->
  thing = nock('https://cine-io-hls.s3.amazonaws.com:443').put('/my-pub-key/some_stream-1234567890123.ts', "this is a fake ts file\n")
  if options.delay
    thing = thing.delayConnection(200)
  thing.reply 200, "",
    'x-amz-id-2': '7aSibYtEYUlxVyCkf55FsqqeGB2MemaxeGfG5z3GvjY/zmsuELfz6lTwT7EE0DLreRuT2trNyeM=',
    'x-amz-request-id': 'FCC224F29FF55426',
    date: 'Tue, 18 Nov 2014 18:08:58 GMT',
    etag: '"9b483a2f1df944e1e00d5ed402048cca"',
    'content-length': '0',
    server: 'AmazonS3'

second = (fileName, fileContents, options)->
  thing = nock('https://cine-io-hls.s3.amazonaws.com:443').put('/my-pub-key/some_stream-0987654321098.ts', "this is a second fake ts file\n")
  if options.delay
    thing = thing.delayConnection(200)
  thing.reply 200, "",
    'x-amz-id-2': 'BA1r9ili8Tojx0miPxwnIXydTI5LEJE/wJ3+EeXvjADD0GyTjBHvGdUzDlUzs0BC',
    'x-amz-request-id': '3C450B20DE0AC3C0',
    date: 'Tue, 18 Nov 2014 23:50:08 GMT',
    etag: '"f92667e9e6a006ce8ce7f2d4c7068fc0"',
    'content-length': '0',
    server: 'AmazonS3'

third = (fileName, fileContents, options)->
  nock('https://cine-io-vod.s3.amazonaws.com:443')
    .put('/cines/this-pub-key/mystream.20141008T191601.mp4', "this is a fake video file\n")
    .reply(200, "", { 'x-amz-id-2': 'h0+goGUKOtgfiXSfdvAk4Ai4bGzotjhdjjl2yMIG2xYxdjWL9ZVicSTC0rEQlC/E',
    'x-amz-request-id': 'EFCA1E2CB3563896',
    date: 'Fri, 21 Nov 2014 22:07:11 GMT',
    etag: '"b60f2176fb6ee89c8242fcb28a95233e"',
    'content-length': '0',
    server: 'AmazonS3' })
module.exports = (fileName, fileContents, options={})->
  # I have NO CLUE why this doesn't work using the original s3 nock
  if fileName == 'my-pub-key/some_stream-1234567890123.ts'
    first(fileName, fileContents, options)
  else if fileName == 'my-pub-key/some_stream-0987654321098.ts'
    second(fileName, fileContents, options)
  else if fileName == 'cines/this-pub-key/mystream.20141008T191601.mp4'
    third(fileName, fileContents, options)
  else
    original(fileName, fileContents, options)
