module.exports =
  token: process.env.EDGECAST_TOKEN || '2580b744-962a-44d9-9e95-df7fa6e39e13'
  account: "C45E"
  ftp:
    host: process.env.EDGECAST_FTP_HOST || "ftp.vny.C45E.edgecastcdn.net"
    user: process.env.EDGECAST_FTP_USER || 'fake-account'
    password: process.env.EDGECAST_FTP_PASSWORD || 'fake-password'
    connTimeout: 30000
