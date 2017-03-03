define([
    'jquery',
    'backbone'
], function($, Backbone) {


    var AppView = Backbone.View.extend({

        el: "#chess-web-app",

        initialize: function() {
            console.log('initialize this view');

        },

        render: function() {
            // TODO render the board
        }

    });

    return AppView;
})