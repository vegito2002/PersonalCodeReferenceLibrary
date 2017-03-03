/**
 * This module provides a mock server for doing JS integration testing.  When you bring this
 * file into a test it will mock out any connection to the server, allow you to specify URLs and responses, and
 * will throw an error if any requests are made.
 */
define([
    'underscore'
], function(_) {
    'use strict';

    var mockServer;

    var allResponses = {
        "GET": {},
        "POST": {},
        "PUT": {},
        "DELETE": {}
    };

    var responseOptions = {
        "GET": {},
        "POST": {},
        "PUT": {},
        "DELETE": {}
    };

    function cleanupRequestUrl(url) {
        var cleanedUpUrl = url;

        // get rid of _={randomness}, if any
        var cacheBusterPosition = url.indexOf('_=');
        if (cacheBusterPosition >= 0) {
            cleanedUpUrl = url.substring(0, cacheBusterPosition);
        }

        // get rid of trailing & or ?
        _.each(["&", "?"], function(characterToDelete) {
            if (cleanedUpUrl.slice(-1) === characterToDelete) {
                cleanedUpUrl = cleanedUpUrl.substring(0, cleanedUpUrl.length - 1);
            }
        });

        return cleanedUpUrl;
    }

    function addUrlAndResponse(options) {
        var method = options.method || "GET";
        var url = options.url;

        var methods = _.keys(allResponses);
        if (!_.contains(methods, method)) {
            throw new Error("Must specify options.method as one of " + methods.join(","));
        }

        if (_.isUndefined(url)) {
            throw new Error("Must define options.url");
        }

        var response = options.response;
        if (_.isUndefined(response)) {
            throw new Error("Must define options.response");
        }

        allResponses[method][url] = response;

        if (options.options && !_.isObject(options.options)) {
            throw new Error("If you specify options, it must be an object!");
        }

        responseOptions[method][url] = options.options;
    }

    function addUrlsAndResponses(options) {
        if (_.isArray(options)) {
            options.forEach(function(optionItem) {
                addUrlAndResponse(optionItem);
            });
        }
        else {
            addUrlAndResponse(options);
        }
    }

    /**
     * This method is called before any tests to set up the mock server
     */
    function initialize() {
        if (mockServer) {
            mockServer.restore();
        }

        mockServer = sinon.fakeServer.create();
        mockServer.autoRespond = true;
        var urlsRequested = [];

        mockServer.respondWith(/.*/, function (xhr) {
            var statusCode, body;
            try {
                var cleanedUpUrl = cleanupRequestUrl(xhr.url);

                var responses = allResponses[xhr.method];

                if (!_.isObject(responses)) {
                    throw new Error("Unexpected XHR method: " + xhr.method);
                }

                // error on unexpected requests, warn on dupe requests
                if (!_.has(responses, cleanedUpUrl)) {
                    throw new Error("unexpected ajax request made: " + cleanedUpUrl);
                }

                if (_.indexOf(urlsRequested, cleanedUpUrl) > -1) {
                    console.warn("Duplicate ajax requests made: " + cleanedUpUrl);
                    console.warn("Are you sure that's expected behavior?");
                    if (responseOptions[xhr.method][cleanedUpUrl] && responseOptions[xhr.method][cleanedUpUrl].errorOnDupeRequest) {
                        if (responseOptions[xhr.method][cleanedUpUrl].errorOnDupeRequest) {
                            throw new Error("Duplicate ajax requests made: " + cleanedUpUrl);
                        }
                    }
                } else {
                    urlsRequested.push(cleanedUpUrl);
                }

                var response = responses[cleanedUpUrl];
                if (_.isObject(response)) {
                    statusCode = 200;
                    body = response;
                } else {
                    var responseObj = response();
                    body = responseObj.data;
                    statusCode = responseObj.code;
                }
            }
            catch(e) {
                console.error(e.message);
                statusCode = 500;
                body = e.message;
            }
            finally {
                xhr.respond(statusCode,
                    {'Content-Type': 'application/json'},
                    JSON.stringify(body));
            }
        });
    }

    function waitForSyncThen(model, done) {
        model.once('sync', function () {
            done();
        });
    }

    function fetchAndWait(model, done) {
        waitForSyncThen(model, done);
        model.fetch();
    }

    function saveAndWait(model, done) {
        // TODO: get this to work!!
        waitForSyncThen(model, done);
        model.save();
    }

    function deleteAndWait(model, done) {
        waitForSyncThen(model, done);
        model.destroy();
    }

    beforeEach(function() {
        initialize();
    });

    afterEach(function() {
        if (mockServer) {
            mockServer.restore();
            mockServer = null;
        }
    });

    /**
     * We only share a few functions outside of this file
     */
    return {
        /**
         * Add a HTTP method, URL, and response to mock out.
         * @param options.  Possible keys:
         *   * method  An HTTP method to mock out.  Defaults to "GET"
         *   * url  (required)  The URL to mock
         *   * response (required)  The response to provide for the given request
         */
        add: addUrlsAndResponses,

        /**
         * Utility method to call "fetch" a given model/collection and then execute a callback.
         * @param model (required) The model to fetch
         * @param callback (optional) A method to call after the "fetch" completes
         */
        fetchAndWait: fetchAndWait,

        /**
         * Utility method to save a given model and then execute a callback.
         * @param model (required) The model to save
         * @param callback (optional) A method to call after the "save" completes
         */
        saveAndWait: saveAndWait,

        /**
         * Utility method to call "delete" on a given model and then execute a callback.
         * @param model (required) The model to fetch
         * @param callback (optional) A method to call after the "delete" finishes
         */
        deleteAndWait: deleteAndWait
    };
});