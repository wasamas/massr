require('bootstrap');
require('magnific-popup');

var imagesLoaded = require('imagesloaded');
imagesLoaded.makeJQueryPlugin($);

require('jquery-bridget');
$.bridget('masonry', require('masonry-layout'));

require('./css/bootstrap');
require('./css/bootstrap-responsive');
require('./css/jquery.pnotify.default');
require('./css/magnific-popup');
require('./css/default');
