response = "ns:http://specs.openid.net/auth/2.0\nsession_type:DH-SHA256\nassoc_type:HMAC-SHA256\nassoc_handle:381655eecf29e80\nexpires_in:1799\ndh_server_public:AMFmAWtYiXh6apTO2uwBdKHETuVTh0u1nFgwZn21jQlYDiQzWEMjyc3WJQlcsrGuFyN4D4jXxUIiP26ydV9+KJG/Y0rjfE8S/DUUptQQsKDnwGC9cP9Uw1ZnZZmNV84dGIJbf2yFYkmXzyGI9/EkWaxP7Xb7MCHZA8tfjesQVuIq\nenc_mac_key:cB/tBA97xtlFtUvup9Qssn25qdD3FLFoe8+t6wdC4Yk=\n"
module.exports = ->
  nock('https://www.appdirect.com')
    .post('/openid/op')
    .reply(200, response)
