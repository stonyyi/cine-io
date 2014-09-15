humanizeBytes = Cine.lib('humanize_bytes')

module.exports =
  'cine.io':
    url: 'https://www.cine.io'
    plans:
      free:
        price: 0
        transfer: humanizeBytes.GiB
      solo:
        price: 20
        transfer: humanizeBytes.GiB * 20
      basic:
        price: 100
        transfer: humanizeBytes.GiB * 150
      pro:
        price: 500
        transfer: humanizeBytes.TiB
  heroku:
    url: 'https://addons.heroku.com/cine'
    plans:
      starter:
        price: 0
        transfer: humanizeBytes.GiB
      test:
        price: 0
        transfer: humanizeBytes.GiB

  engineyard:
    url: 'https://addons.engineyard.com/cine.io'
    plans:
      test:
        price: 0
        transfer: humanizeBytes.GiB
      starter:
        price: 0
        transfer: humanizeBytes.GiB
      solo:
        price: 20
        transfer: humanizeBytes.GiB * 20
      basic:
        price: 100
        transfer: humanizeBytes.GiB * 150
      pro:
        price: 500
        transfer: humanizeBytes.TiB

  appdirect:
    # Url likely to change once we're approved
    # I heard something about a dev profile and public profile
    url: 'https://www.appdirect.com/apps/12055'
    plans:
      'sample-addon':
        price: 0
        transfer: humanizeBytes.GiB
      starter:
        price: 0
        transfer: humanizeBytes.GiB
      solo:
        price: 20
        transfer: humanizeBytes.GiB * 20
      basic:
        price: 100
        transfer: humanizeBytes.GiB * 150
      pro:
        price: 500
        transfer: humanizeBytes.TiB
