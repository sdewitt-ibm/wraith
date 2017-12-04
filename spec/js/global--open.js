module.exports = function (page, open) {
  // This is not the greatest example of how to use the before_open hook but
  // it is the easiest thing to do for automated testing.
  var oldFn = page.onLoadFinished;
  page.onLoadFinished = function () {
    if (oldFn) {
      oldFn();
    }
    page.evaluate(function () {
        document.body.innerHTML = '&nbsp;';
        document.body.style['background-color'] = 'red';
    });
  };
  open();
}