basicModel = Cine.require 'test/helpers/basic_model'
basicModel('project', urlAttributes: ['publicKey'])
Project = Cine.model('project')

describe 'Project', ->
  it 'has plans', ->
    expect(Project.plans).to.deep.equal(['free', 'solo', 'startup', 'enterprise'])
