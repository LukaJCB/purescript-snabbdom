var patch = require('snabbdom').init([
  require('snabbdom/modules/class').default,
  require('snabbdom/modules/attributes').default,
  require('snabbdom/modules/style').default,
  require('snabbdom/modules/eventlisteners').default,
  require('snabbdom/modules/props').default
])

var h = require('snabbdom/h').default

function transformEff1(fn) {
  return function(a) {
    return fn(a)()
  }
}

function transformEff2(fn) {
  return function(a,b) {
    return fn(a)(b)()
  }
}
exports.getElementImpl = function(proxy) {
  return function(just) {
    return function(nothing) {
      if (proxy.elm){
        return just(proxy.elm)
      } else {
        return nothing
      }
    }
  }
}

exports.text = function(text) {
  return text
}

exports.toVNodeHookObjectProxy = function(obj) {
  var proxy = {}
  for (var key in obj){
    if (obj[key].value0) {
      if (key !=  "update") {
        proxy[key] = transformEff1(obj[key].value0)
      } else {
        proxy[key] = transformEff2(obj[key].value0)
      }
    }
  }
  return proxy
}

exports.toVNodeEventObject = function (obj) {
  for (var key in obj) {
    var fn = obj[key]
    obj[key] = transformEff1(fn)
  }

  return obj
}

exports.h = function(sel) {
  return function(obj){
    return function(children){
      return h(sel, obj, children)
    }
  }
}


exports.patch = function(oldVnode) {
  return function(vnode) {
    return function() {
      patch(oldVnode, vnode)
    }
  }
}

exports.patchInitialSelector = function (sel) {
  var element = document.querySelector(sel)
  if (element) {
    return exports.patch(element)
  } else {
    return function (vnode) {
      return function() {}
    }
  }
}

exports.patchInitial = exports.patch

exports.updateValueHook = function(old) {
  return function(proxy){
    return function () {
      if (proxy.elm){
        if(proxy.elm.value != proxy.elm.getAttribute("value")){
          proxy.elm.value = proxy.elm.getAttribute("value")
        }
      }
    }
  }
}
