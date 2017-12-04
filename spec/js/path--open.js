module.exports = function (page, open) {
  var oldFn = page.onLoadFinished;
  page.onLoadFinished = function () {
    if (oldFn) {
      oldFn();
    }
    page.evaluate(function () {
        document.body.innerHTML = '&nbsp;';
        document.body.style['background-color'] = 'green';
    });
  };
  open();
}