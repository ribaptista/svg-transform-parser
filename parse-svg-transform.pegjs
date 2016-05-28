/*
 * Parser for SVG transform.
 * Based on http://www.w3.org/TR/SVG/coords.html#TransformAttribute
 */

transformList
  = wsp* ts:transforms? wsp* { return ts; }

transforms
  = t:transform commaWsp+ ts:transforms { return [t].concat(ts) }
    / t:transform { return [t] }

transform
  = matrix
    / translate
    / scale
    / rotate
    / skewX
    / skewY

matrix
  = "matrix" wsp* "(" wsp*
       a:number commaWsp
       b:number commaWsp
       c:number commaWsp
       d:number commaWsp
       e:number commaWsp
       f:number wsp* ")" {
      return {op: 'matrix', args: {a: a, b: b, c: c, d: d, e: e, f: f}};
    }

translate
  = "translate" wsp* "(" wsp* tx:number ty:commaWspNumber? wsp* ")" {
      var t = {tx: tx, ty: ty ? ty : 0};
      return {op: 'translate', args: t};
    }

scale
  = "scale" wsp* "(" wsp* sx:number sy:commaWspNumber? wsp* ")" {
      var s = {sx: sx, sy: sy ? sy : 1};
      return {op: 'scale', args: s};
    }

rotate
  = "rotate" wsp* "(" wsp* angle:number c:commaWspTwoNumbers? wsp* ")" {
      var r = {angle: angle};
      if (c) {
        r.cx = c[0];
        r.cy = c[1];
      }
      return {op: 'rotate', args: r};
    }

skewX
  = "skewX" wsp* "(" wsp* angle:number wsp* ")" {
      return {op: 'skewX', args: {angle: angle}};
    }

skewY
  = "skewY" wsp* "(" wsp* angle:number wsp* ")" {
      return {op: 'skewY', args: {angle: angle}};
    }

number
  = s:sign? f:floatingPointConstant { return parseFloat([s, f.join("")].join("")); }
    / i:(sign? integerConstant) { return parseInt(i.join("")); }

commaWspNumber
  = commaWsp n:number { return n; }

commaWspTwoNumbers
  = commaWsp n1:number commaWsp n2:number { return [n1, n2]; }

commaWsp
  = (wsp+ comma? wsp*) / (comma wsp*)

comma
  = ","

integerConstant
  = ds:digitSequence { return ds.join(""); }

floatingPointConstant
  = fractionalConstant exponent?
    / digitSequence exponent

fractionalConstant "fractionalConstant"
  = d1:digitSequence? "." d2:digitSequence { return [d1 ? d1.join("") : null, ".", d2.join("")].join(""); }
    / d:digitSequence "." { return d.join(""); }

exponent
  = e:[eE] s:sign? d:digitSequence { return [e, s, d.join("")].join("") }

sign
  = [+-]

digitSequence
  = digit+

digit
  = [0-9]

wsp
  = [\u0020\u0009\u000D\u000A]
