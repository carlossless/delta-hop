var superagent = require('superagent')
var expect = require('expect.js')

describe('freshbooks REST api', function() {

  it('retrieves a collection of projects', function(done) {
    superagent.get('http://localhost:3000/projects')
      .end(function(e, res) {
        expect(res.body).to.not.be.empty();
        done();
      });
  });

  it('retrieves a collection of tasks', function(done) {
    superagent.get('http://localhost:3000/tasks')
      .end(function(e, res) {
        expect(res.body).to.not.be.empty();
        done();
      });
  });

});