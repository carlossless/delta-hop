var superagent = require('superagent')
var expect = require('expect.js')

describe('timer REST api', function() {
  var id;

  it('creates an object', function(done){
    superagent.post('http://localhost:3000/timers')
      .send({ 
        name: 'Timer name',
        description: 'A description'
      })
      .end(function(e, res) {
        expect(res.body.id.length).to.eql(24);
        id = res.body.id;
        done();
      });
  });

  it('retrieves the created object', function(done){
    superagent.get('http://localhost:3000/timers/' + id)
      .end(function(e, res) {
        expect(res.body.name).to.eql('Timer name');
        expect(res.body.description).to.eql('A description');
        done();
      });
  });

  it('retrieves a collection of timers', function(done) {
    superagent.get('http://localhost:3000/timers')
      .end(function(e, res) {
        expect(res.body.map(function (item){return item._id})).to.contain(id);
        done();
      });
  });

  it('updates an object', function(done) {
    superagent.put('http://localhost:3000/timers/' + id)
      .send({
        name: 'Timer name2', 
        description: 'A description2'
      })
      .end(function(e, res) {
        expect(res.body.name).to.eql('Timer name2');
        expect(res.body.description).to.eql('A description2');
        done();
      });
  });

  it('removes an object', function(done) {
    superagent.del('http://localhost:3000/timers/' + id)
      .end(function(e, res) {
        expect(res.body.id).to.eql(id);
        done();
      });
  });
});