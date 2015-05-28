var couchapp = require('couchapp');
var path = require('path');

var ddoc = {
  _id: '_design/app',
  rewrites: [
    {from: '/', to: '/index.html'},
    {from: '/api', to:'../../'},
    {from: '/api/*', to:'../../*'},
    {from: '/*', to: '/*'}
  ]
};

couchapp.loadAttachments(ddoc, path.join(__dirname, 'public'));

module.exports = ddoc;
