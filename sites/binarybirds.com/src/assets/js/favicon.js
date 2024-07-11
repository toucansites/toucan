window.addEventListener('load', function () {
  var darkSchemeIcon = '/icons/favicondark.ico';
  var lightSchemeIcon = '/icons/favicon.ico';

  function setFavicon(icon) {
    var link = document.querySelector("link[rel='shortcut icon']");
    if (!link) {
      link = document.createElement('link');
      link.rel = 'shortcut icon';
      document.head.appendChild(link);
    }
    link.href = icon;
  }

  var darkSchemeMediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  function handleColorSchemeChange(e) {
    setFavicon(e.matches ? darkSchemeIcon : lightSchemeIcon);
  }

  darkSchemeMediaQuery.addListener(handleColorSchemeChange);
  handleColorSchemeChange(darkSchemeMediaQuery);
});
