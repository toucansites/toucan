window.addEventListener('load', function () {
  var currentYear = new Date().getFullYear();
  var copyrightSpan = document.getElementById('copyright');
  copyrightSpan.textContent =
    'Binary Birds © 2022-' + currentYear + ' - All Rights Reserved';
});
