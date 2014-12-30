humanizeBytes = Cine.lib('humanize_bytes')
THOUSAND = 1000
MILLION = THOUSAND * THOUSAND
MINUTES = 60

module.exports =
  'cine.io':
    broadcast:
      url: 'https://www.cine.io'
      plans:
        free:
          order: 10
          streams: 1
          price: 0
          bandwidth: humanizeBytes.GiB
          storage: 0
          bandwidthOverage: 0
          storageOverage: 0
        solo:
          order: 20
          streams: 5
          price: 20
          bandwidth: humanizeBytes.GiB * 20
          storage: humanizeBytes.GiB * 5
          bandwidthOverage: 0
          storageOverage: 0
        basic:
          order: 30
          streams: "unlimited"
          price: 100
          bandwidth: humanizeBytes.GiB * 150
          storage: humanizeBytes.GiB * 25
          bandwidthOverage: 0
          storageOverage: 0
        premium:
          order: 40
          streams: "unlimited"
          price: 300
          bandwidth: humanizeBytes.GiB * 500
          storage: humanizeBytes.GiB * 50
          bandwidthOverage: 0
          storageOverage: 0
        pro:
          order: 50
          streams: "unlimited"
          price: 500
          bandwidth: humanizeBytes.TiB * 1
          storage: humanizeBytes.GiB * 100
          bandwidthOverage: 0
          storageOverage: 0
        startup:
          order: 60
          streams: "unlimited"
          price: 1000
          bandwidth: humanizeBytes.TiB * 2
          storage: humanizeBytes.GiB * 150
          bandwidthOverage: 0
          storageOverage: 0
        business:
          order: 70
          streams: "unlimited"
          price: 2000
          bandwidth: humanizeBytes.TiB * 5
          storage: humanizeBytes.GiB * 250
          bandwidthOverage: 0
          storageOverage: 0
        enterprise:
          order: 80
          streams: "unlimited"
          price: 5000
          bandwidth: humanizeBytes.TiB * 15
          storage: humanizeBytes.GiB * 500
          bandwidthOverage: 0
          storageOverage: 0
    peer:
      url: 'https://www.cine.io'
      plans:
        free:
          order: 10
          minutes: 60 * MINUTES
          price: 0
        solo:
          order: 20
          minutes: 2 * THOUSAND * MINUTES
          price: 20
        basic:
          order: 30
          minutes: 12.5 * THOUSAND * MINUTES
          price: 100
        premium:
          order: 40
          minutes: 35 * THOUSAND * MINUTES
          price: 300
        pro:
          order: 50
          minutes: 70 * THOUSAND * MINUTES
          price: 500
        startup:
          order: 60
          minutes: 165 * THOUSAND * MINUTES
          price: 1000
        business:
          order: 70
          minutes: 400 * THOUSAND * MINUTES
          price: 2000
        enterprise:
          order: 80
          minutes: 1.25 * MILLION * MINUTES
          price: 5000
  heroku:
    broadcast:
      url: 'https://addons.heroku.com/cine'
      plans:
        test:
          price: 0
          bandwidth: humanizeBytes.GiB
          storage: 0
          bandwidthOverage: 0
          storageOverage: 0
        starter:
          price: 0
          bandwidth: humanizeBytes.GiB
          storage: 0
          bandwidthOverage: 0
          storageOverage: 0
        solo:
          price: 20
          bandwidth: humanizeBytes.GiB * 15
          storage: humanizeBytes.GiB * 3
          bandwidthOverage: 0
          storageOverage: 0
        basic:
          price: 100
          bandwidth: humanizeBytes.GiB * 110
          storage: humanizeBytes.GiB * 15
          bandwidthOverage: 0
          storageOverage: 0
        pro:
          price: 500
          bandwidth: humanizeBytes.Gib * 750
          storage: humanizeBytes.GiB * 75
          bandwidthOverage: 0
          storageOverage: 0
  engineyard:
    broadcast:
      url: 'https://addons.engineyard.com/addons/cineio'
      plans:
        test:
          price: 0
          bandwidth: humanizeBytes.GiB
          storage: 0
          bandwidthOverage: 0
          storageOverage: 0
        starter:
          price: 0
          bandwidth: humanizeBytes.GiB
          storage: 0
          bandwidthOverage: 0
          storageOverage: 0
        solo:
          price: 20
          bandwidth: humanizeBytes.GiB * 15
          storage: humanizeBytes.GiB * 3
          bandwidthOverage: 0
          storageOverage: 0
        basic:
          price: 100
          bandwidth: humanizeBytes.GiB * 110
          storage: humanizeBytes.GiB * 15
          bandwidthOverage: 0
          storageOverage: 0
        pro:
          price: 500
          bandwidth: humanizeBytes.Gib * 750
          storage: humanizeBytes.GiB * 75
          bandwidthOverage: 0
          storageOverage: 0

  appdirect:
    broadcast:
      url: 'https://www.appdirect.com/apps/14079'
      plans:
        'sample-addon':
          price: 0
          bandwidth: humanizeBytes.GiB
        starter:
          price: 0
          bandwidth: humanizeBytes.GiB
          storage: 0
          bandwidthOverage: 0
          storageOverage: 0
        solo:
          price: 20
          bandwidth: humanizeBytes.GiB * 15
          storage: humanizeBytes.GiB * 3
          bandwidthOverage: 0
          storageOverage: 0
        basic:
          price: 100
          bandwidth: humanizeBytes.GiB * 110
          storage: humanizeBytes.GiB * 15
          bandwidthOverage: 0
          storageOverage: 0
        pro:
          price: 500
          bandwidth: humanizeBytes.Gib * 750
          storage: humanizeBytes.GiB * 75
          bandwidthOverage: 0
          storageOverage: 0
