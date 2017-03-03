require.config({

    basePath: ".",

    paths: {
        'underscore': 'lib/underscore',
        'backbone' : 'lib/backbone',
        'jquery': 'lib/jquery',
        'handlebars': 'lib/handlebars'
    }
});

require(['views/AppView', 'jquery'], function(AppView, $) {
    $(function() {
        var App = new AppView();
    });
});

