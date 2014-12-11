module.exports =
  stunServers: [
    {
      url: 'stun:rtc-sfo1.cine.io:3478'
    }
  ]
  turnServers: [
    {
      url: "turn:rtc-sfo1.cine.io:3478"
      # credential: project.publicKey
      # username: project.turnPassword
    }
  ]
