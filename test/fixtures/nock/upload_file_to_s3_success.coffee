module.exports = (fileName, fileContents)->
  # I have NO CLUE why this doesn't work using the original s3 nock
  if fileName == 'my-pub-key/some_stream-1234567890123.ts'
    nock('https://cine-io-hls.s3.amazonaws.com:443')
      .put('/my-pub-key/some_stream-1234567890123.ts', "this is a fake ts file\n")
      .reply(200, "", { 'x-amz-id-2': '7aSibYtEYUlxVyCkf55FsqqeGB2MemaxeGfG5z3GvjY/zmsuELfz6lTwT7EE0DLreRuT2trNyeM=',
      'x-amz-request-id': 'FCC224F29FF55426',
      date: 'Tue, 18 Nov 2014 18:08:58 GMT',
      etag: '"9b483a2f1df944e1e00d5ed402048cca"',
      'content-length': '0',
      server: 'AmazonS3' });
  else
    nock('https://cine-io-hls.s3.amazonaws.com:443')
      .put("/#{fileName}", fileContents)
      .reply(200, "", { 'x-amz-id-2': 'pUygvEyjqX1IleQ2RA8UltFJayOTlzieQ89J+3TnZSGetqSk50UWjcs1W3M2FAsT',
      'x-amz-request-id': '03108629EDFF2B6C',
      date: 'Tue, 18 Nov 2014 02:51:09 GMT',
      etag: '"26bb73556ceb32a5df30b733c5355ee5"',
      'content-length': '0',
      server: 'AmazonS3' })
