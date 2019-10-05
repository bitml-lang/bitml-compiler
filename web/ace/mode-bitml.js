define("ace/mode/bitml_highlight_rules",["require","exports","module","ace/lib/oop","ace/mode/text_highlight_rules"], function(require, exports, module) {
"use strict";

var oop = require("../lib/oop");
var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

var BitmlHighlightRules = function() {
    var keywordControl = "case|do|let|loop|if|else|when|choice|participant|contract|debug-mode|has-at-least|deposit|vol-deposit|fee|secret|ref|debug-mode";
    var keywordOperator = "define|pre|sum|->|putrevealif|put|revealif|reveal|split|withdraw|after|auth|tau|true|and|or|not|=|!=|<|<=|+|-|size|pred|between|strategy|do-reveal|do-auth|not-destory|do-destory|state|check-liquid|check|has-more-than|check-query";
    //"eq|neq|and|or";
    var constantLanguage = "null|nil";
    var supportFunctions = ""; //"pre|sum|->|putrevealif|put|revealif|reveal|split|withdraw|after|auth|tau|btrue|band|bor|bnot|b=|b!=|b<|b<=|b+|b-|bsize|pred|between|strategy|b-if|do-reveal|do-auth|not-destory|do-destory|state|check-liquid|check|has-more-than|check-query";

    var keywordMapper = this.createKeywordMapper({
        "keyword.control": keywordControl,
        "keyword.operator": keywordOperator,
        "constant.language": constantLanguage,
        "support.function": supportFunctions
    }, "identifier", true);

    this.$rules = 
        {
    "start": [
        {
            token : "comment",
            regex : ";.*$"
        },
        {
            token: ["storage.type.function-type.bitml", "text", "entity.name.function.bitml"],
            regex: "(?:\\b(?:(defun|defmethod|defmacro))\\b)(\\s+)((?:\\w|\\-|\\!|\\?)*)"
        },
        {
            token: ["punctuation.definition.constant.character.bitml", "constant.character.bitml"],
            regex: "(#)((?:\\w|[\\\\+-=<>'\"&#])+)"
        },
        {
            token: ["punctuation.definition.variable.bitml", "variable.other.global.bitml", "punctuation.definition.variable.bitml"],
            regex: "(\\*)(\\S*)(\\*)"
        },
        {
            token : "constant.numeric", // hex
            regex : "0[xX][0-9a-fA-F]+(?:L|l|UL|ul|u|U|F|f|ll|LL|ull|ULL)?\\b"
        }, 
        {
            token : "constant.numeric", // float
            regex : "[+-]?\\d+(?:(?:\\.\\d*)?(?:[eE][+-]?\\d+)?)?(?:L|l|UL|ul|u|U|F|f|ll|LL|ull|ULL)?\\b"
        },
        {
                token : keywordMapper,
                regex : "[a-zA-Z_$][a-zA-Z0-9_$]*\\b"
        },
        {
            token : "string",
            regex : '"(?=.)',
            next  : "qqstring"
        }
    ],
    "qqstring": [
        {
            token: "constant.character.escape.bitml",
            regex: "\\\\."
        },
        {
            token : "string",
            regex : '[^"\\\\]+'
        }, {
            token : "string",
            regex : "\\\\$",
            next  : "qqstring"
        }, {
            token : "string",
            regex : '"|$',
            next  : "start"
        }
    ]
};

};

oop.inherits(BitmlHighlightRules, TextHighlightRules);

exports.BitmlHighlightRules = BitmlHighlightRules;
});

define("ace/mode/bitml",["require","exports","module","ace/lib/oop","ace/mode/text","ace/mode/bitml_highlight_rules"], function(require, exports, module) {
"use strict";

var oop = require("../lib/oop");
var TextMode = require("./text").Mode;
var BitmlHighlightRules = require("./bitml_highlight_rules").BitmlHighlightRules;

var Mode = function() {
    this.HighlightRules = BitmlHighlightRules;
    this.$behaviour = this.$defaultBehaviour;
};
oop.inherits(Mode, TextMode);

(function() {
       
    this.lineCommentStart = ";";
    
    this.$id = "ace/mode/bitml";
}).call(Mode.prototype);

exports.Mode = Mode;
});                (function() {
                    window.require(["ace/mode/bitml"], function(m) {
                        if (typeof module == "object" && typeof exports == "object" && module) {
                            module.exports = m;
                        }
                    });
                })();
            