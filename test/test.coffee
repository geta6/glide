# Dependencies

fs = require 'fs'
path = require 'path'
assert = require 'assert'
request = require 'supertest'

app = require path.resolve 'config', 'app'
process.env.NODE_ENV = 'test'

describe 'app', ->

  before (done) ->
    app.listen done

  it 'returns 200', (done) ->
    request(app).get('/').expect(200).end(done)

