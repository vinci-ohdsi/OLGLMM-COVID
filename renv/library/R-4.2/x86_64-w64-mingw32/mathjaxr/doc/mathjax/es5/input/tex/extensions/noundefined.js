!function(modules){function __webpack_require__(moduleId){if(installedModules[moduleId])return installedModules[moduleId].exports;var module=installedModules[moduleId]={i:moduleId,l:!1,exports:{}};return modules[moduleId].call(module.exports,module,module.exports,__webpack_require__),module.l=!0,module.exports}var installedModules={};return __webpack_require__.m=modules,__webpack_require__.c=installedModules,__webpack_require__.d=function(exports,name,getter){__webpack_require__.o(exports,name)||Object.defineProperty(exports,name,{enumerable:!0,get:getter})},__webpack_require__.r=function(exports){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(exports,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(exports,"__esModule",{value:!0})},__webpack_require__.t=function(value,mode){if(1&mode&&(value=__webpack_require__(value)),8&mode)return value;if(4&mode&&"object"==typeof value&&value&&value.__esModule)return value;var ns=Object.create(null);if(__webpack_require__.r(ns),Object.defineProperty(ns,"default",{enumerable:!0,value:value}),2&mode&&"string"!=typeof value)for(var key in value)__webpack_require__.d(ns,key,function(key){return value[key]}.bind(null,key));return ns},__webpack_require__.n=function(module){var getter=module&&module.__esModule?function getDefault(){return module["default"]}:function getModuleExports(){return module};return __webpack_require__.d(getter,"a",getter),getter},__webpack_require__.o=function(object,property){return Object.prototype.hasOwnProperty.call(object,property)},__webpack_require__.p="",__webpack_require__(__webpack_require__.s=3)}([function(module,exports,__webpack_require__){"use strict";Object.defineProperty(exports,"__esModule",{value:!0}),exports.isObject=MathJax._.components.global.isObject,exports.combineConfig=MathJax._.components.global.combineConfig,exports.combineDefaults=MathJax._.components.global.combineDefaults,exports.combineWithMathJax=MathJax._.components.global.combineWithMathJax,exports.MathJax=MathJax._.components.global.MathJax},function(module,exports,__webpack_require__){"use strict";function noUndefined(parser,name){var e_1,_a,textNode=parser.create("text","\\"+name),options=parser.options.noundefined||{},def={};try{for(var _b=__values(["color","background","size"]),_c=_b.next();!_c.done;_c=_b.next()){var id=_c.value;options[id]&&(def["math"+id]=options[id])}}catch(e_1_1){e_1={error:e_1_1}}finally{try{_c&&!_c.done&&(_a=_b["return"])&&_a.call(_b)}finally{if(e_1)throw e_1.error}}parser.Push(parser.create("node","mtext",[],def,textNode))}var __values=this&&this.__values||function(o){var s="function"==typeof Symbol&&Symbol.iterator,m=s&&o[s],i=0;if(m)return m.call(o);if(o&&"number"==typeof o.length)return{next:function(){return o&&i>=o.length&&(o=void 0),{value:o&&o[i++],done:!o}}};throw new TypeError(s?"Object is not iterable.":"Symbol.iterator is not defined.")};Object.defineProperty(exports,"__esModule",{value:!0}),exports.NoUndefinedConfiguration=void 0;var Configuration_js_1=__webpack_require__(2);exports.NoUndefinedConfiguration=Configuration_js_1.Configuration.create("noundefined",{fallback:{macro:noUndefined},options:{noundefined:{color:"red",background:"",size:""}},priority:3})},function(module,exports,__webpack_require__){"use strict";Object.defineProperty(exports,"__esModule",{value:!0}),exports.Configuration=MathJax._.input.tex.Configuration.Configuration,exports.ConfigurationHandler=MathJax._.input.tex.Configuration.ConfigurationHandler,exports.ParserConfiguration=MathJax._.input.tex.Configuration.ParserConfiguration},function(module,__webpack_exports__,__webpack_require__){"use strict";__webpack_require__.r(__webpack_exports__);var global=__webpack_require__(0),NoUndefinedConfiguration=__webpack_require__(1);Object(global.combineWithMathJax)({_:{input:{tex:{noundefined:{NoUndefinedConfiguration:NoUndefinedConfiguration}}}}})}]);