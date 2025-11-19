// DPM-18987: OneTrust Cookie Modal - Add tabindex + aria-label
const otSelectors = [
  '.ot-cat-item',
  '.ot-tab-desc',
  '.ot-tab-list',
  '.ot-abt-tab'
];

$(otSelectors.join(','), context).each(function () {

  // Avoid modifying natural controls like <a> and <button>
  if (!$(this).is('a, button')) {

    $(this).attr('tabindex', '0');
    $(this).attr('aria-label', 'Cookie Preference Center');

  }
});

// Fallback interval for late-loaded OneTrust content
const interval = setInterval(() => {
  const $targets = $(otSelectors.join(','));
  if ($targets.length > 0) {

    $targets.each(function () {
      if (!$(this).is('a, button')) {
        $(this).attr('tabindex', '0');
        $(this).attr('aria-label', 'Cookie Preference Center');
      }
    });

    clearInterval(interval);
  }
}, 250);