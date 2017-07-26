/* Polyfills
 *
 */
String.prototype.interpolate = function (opts) {
    var reg = /\$\{(.*?)\}/g,
        str = this,
        res;

    while (res = reg.exec(str)) {
        str = str.replace(res[0], opts[res[1]]);
    }
    return str;
};
