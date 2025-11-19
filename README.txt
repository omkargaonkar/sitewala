(function accessibilityEW($) {

  "use strict";

  Drupal.behaviors.accessibility = {
    attach: function (context) {

      // -------------------------------------
      // DPM-15107: Accessibility Table Elements
      // -------------------------------------
      $('table > thead > tr > th', context).attr('scope', 'col');
      $('table > tbody > tr > th', context).attr('scope', 'row');

      // -------------------------------------
      // DPM-18987: OneTrust Cookie Modal - Add tabindex
      // -------------------------------------
      // Add tabindex="0" to specific OT classes
      const otSelectors = [
        '.ot-cat-item',
        '.ot-tab-desc',
        '.ot-tab-list',
        '.ot-abt-tab'
      ];

      $(otSelectors.join(','), context).each(function () {
        // Avoid adding tabindex on links/buttons (already focusable)
        if (!$(this).is('a, button')) {
          $(this).attr('tabindex', '0');
        }
      });

      // If OneTrust loads later, run a fallback interval
      const interval = setInterval(() => {
        const $targets = $(otSelectors.join(','));
        if ($targets.length > 0) {
          $targets.each(function () {
            if (!$(this).is('a, button')) {
              $(this).attr('tabindex', '0');
            }
          });
          clearInterval(interval);
        }
      }, 250);

      // -------------------------------------
      // DPM-15100: Carousel Live Region
      // -------------------------------------
      $('.slick--field-carousel-slides', context).attr('aria-live', 'polite');

    }
  };

})(jQuery);