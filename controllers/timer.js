exports.setup = function(app) {

	var mongoose = require('mongoose');
	mongoose.connect('mongodb://localhost:27017/');

	var Timer = require('./../models/timer');

	app.get('/timers', function(req, res) {
		Timer.find(function (err, timers) {
			res.json(timers);
		})
	});

	app.get('/timers/:id', function(req, res) {
		Timer.find({ _id: req.params.id }, function (err, timers) {
    		if (err) {
				res.send(err);
			}
			res.json(timers[0]);
		})
	});

	app.put('/timers/:id', function(req, res) {
		Timer.find({ _id: req.params.id }, function (err, timers) {
   		 	if (err) {
				res.send(err);
			}
			var timer = timers[0];
			timer.name = req.body.name;
			timer.description = req.body.description;
			timer.startDate = Date();

			timer.save(function(err) {
				if (err) {
					res.send(err);
				}
				res.json({ id: timer._id });
			});
		})
	});

	app.post('/timers/', function(req, res) {
		var timer = new Timer();
		timer.name = req.body.name;
		timer.description = req.body.description;
		timer.startDate = Date();

		// save the bear and check for errors
		timer.save(function(err) {
			if (err) {
				res.send(err);
			}
			res.json({ id: timer._id });
		});
	});
	
}