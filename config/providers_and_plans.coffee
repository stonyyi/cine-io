humanizeBytes = Cine.lib('humanize_bytes')

module.exports =
  'cine.io':
    url: 'https://www.cine.io'
    plans:
      free:
        streams: 1
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
      developer:
        order: 10
        streams: 1
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
      solo:
        order: 20
        streams: 5
        price: 20
        bandwidth: humanizeBytes.GiB * 20
        storage: humanizeBytes.GiB * 5
      basic:
        order: 30
        streams: 25
        price: 100
        bandwidth: humanizeBytes.GiB * 150
        storage: humanizeBytes.GiB * 25
      premium:
        order: 40
        streams: 100
        price: 300
        bandwidth: humanizeBytes.GiB * 500
        storage: humanizeBytes.GiB * 50
      pro:
        order: 50
        streams: 500
        price: 500
        bandwidth: humanizeBytes.TiB * 1
        storage: humanizeBytes.GiB * 100
      startup:
        order: 60
        streams: "unlimited"
        price: 1000
        bandwidth: humanizeBytes.TiB * 2
        storage: humanizeBytes.GiB * 150
      business:
        order: 70
        streams: "unlimited"
        price: 2000
        bandwidth: humanizeBytes.TiB * 5
        storage: humanizeBytes.GiB * 250
      enterprise:
        order: 80
        streams: "unlimited"
        price: 5000
        bandwidth: humanizeBytes.TiB * 15
        storage: humanizeBytes.GiB * 500
  heroku:
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
    # Url likely to change once we're approved
    # I heard something about a dev profile and public profile
    url: 'https://www.appdirect.com/apps/12055'
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
