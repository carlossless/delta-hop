exports.setup = function(app) {

	var api_url = "https://devbridge.freshbooks.com/api/2.1/xml-in"
	var api_token = "08fcf553188d99199053acfce6b27ee9"
	var FreshBooks = require("freshbooks");
	var freshbooks = new FreshBooks(api_url, api_token)

	var co = require("co");

	app.get('/projects', function(req, res) {
		var project = new freshbooks.Project();
		project.list(function(err, projects) {
			if (err) {
				res.send(err);
			}
			res.send(projects);
		});
	});

	app.get('/tasks', function(req, res) {
		var task = new freshbooks.Task();
		task.list(function(err, freshtasks) {
			if (err) {
				es.send(err);
			}
			res.send(freshtasks);
		});
	});

}