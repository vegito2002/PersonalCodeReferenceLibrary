define([
    'backbone'
], function (
    Backbone
    ) {
    var ChessboardModel = Backbone.Model.extend({

        urlRoot: function () {
            return "api/chess";
        },

        initialize: function() {
            console.log('initialize this chessboard');

        }
    });

    return ChessboardModel;
})
