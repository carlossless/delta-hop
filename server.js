var bodyParser = require('body-parser');
var express = require('express');

var app = express();

app.use(bodyParser.json());

app.use("/styles", express.static(__dirname + '/styles'));
app.use("/js", express.static(__dirname + '/js'));

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

[
  'freshbooks',
  'timer'
].map(function(controllerName){
  var controller = require('./controllers/' + controllerName);
  controller.setup(app);
});

app.get('/', function(req, res) {
	res.render('index', { title: 'The index page' });
});

var server = app.listen(3000, function() {
    console.log('Listening on port %d', server.address().port);
});