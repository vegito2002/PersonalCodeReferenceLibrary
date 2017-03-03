require.config({

    baseUrl: '../',

    paths: {
        'backbone' : 'lib/backbone',
        'underscore': 'lib/underscore',
        'jquery': 'lib/jquery',

        'jasmine': 'test/lib/jasmine',
        'jasmine-html': 'test/lib/jasmine-html',
        'boot': 'test/lib/boot',

        'ServerMock': 'test/lib/ServerMock',
        'sinon': 'test/lib/sinon',
        'expect': 'test/lib/expect'

    },
    shim: {
        'jasmine': {
            exports: 'window.jasmineRequire'
        },
        'jasmine-html': {
            deps: ['jasmine'],
            exports: 'window.jasmineRequire'
        },
        'boot': {
            deps: ['jasmine', 'jasmine-html'],
            exports: 'window.jasmineRequire'
        },
        'ServerMock': {
            deps: ['sinon'],
            exports: 'ServerMock'
        },
        // TODO: get expect js working
        'expect': {
            exports: 'window.expect'
        }


    }
});

var specs = [
    'test/specs/ChessboardModelTests'
];

require(['boot'], function () {

    require(specs, function () {
        // Initialize the HTML Reporter and execute the environment (setup by `boot.js`)
        window.onload();
    });
});


