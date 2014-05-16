ReactView = Cine.view('react')
# React = require('../../vendor/react/React')
Homepage = Cine.component('homepage')

module.exports = class HomepageShow extends ReactView
  @id: 'homepage/show'
  className: 'homepage-show'
  getComponent: ->
    Homepage()
