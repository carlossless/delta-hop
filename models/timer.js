var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var TimerSchema = new Schema({
	name: String,
	description: String,
	startDate: Date
});

module.exports = mongoose.model('Timer', TimerSchema);