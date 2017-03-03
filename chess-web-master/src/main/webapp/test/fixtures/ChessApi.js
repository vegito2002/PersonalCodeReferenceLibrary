define(function() {
    'use strict';

    return {

        initialBoardState: {
            "currentPlayer" : "White",
            "inCheck" : false,
            "gameOver" : false,
            "positionToPieces" : {
                "a8" : {"owner" : "Black", "type" : "r"},
                "b8" : {"owner" : "Black", "type" : "n"},
                "c8" : {"owner" : "Black", "type" : "b"},
                "d8" : {"owner" : "Black", "type" : "q"},
                "e8" : {"owner" : "Black", "type" : "k"},
                "f8" : {"owner" : "Black", "type" : "b"},
                "g8" : {"owner" : "Black", "type" : "n"},
                "h8" : {"owner" : "Black", "type" : "r"},
                "a7" : {"owner" : "Black", "type" : "p"},
                "b7" : {"owner" : "Black", "type" : "p"},
                "c7" : {"owner" : "Black", "type" : "p"},
                "d7" : {"owner" : "Black", "type" : "p"},
                "e7" : {"owner" : "Black", "type" : "p"},
                "f7" : {"owner" : "Black", "type" : "p"},
                "g7" : {"owner" : "Black", "type" : "p"},
                "h7" : {"owner" : "Black", "type" : "p"}
            }
        },

        boardInCheckState: {
            "currentPlayer" : "Black",
            "inCheck" : true,
            "gameOver" : false,
            "positionToPieces" : {
            }
        }

    };
});


