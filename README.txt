
(function accessibilityEW($) {

  'use strict';

  Drupal.behaviors.accessibility = {
    attach: function (context) {

      // -------------------------------------
      // DPM-15107: Accessibility Table Elements
      // -------------------------------------
      $('table > thead > tr > th', context).attr('scope', 'col');
      $('table > tbody > tr > th', context).attr('scope', 'row');

      // -------------------------------------
      // Selectors for OneTrust elements
      // -------------------------------------
      const otSelectors = [
        '.ot-cat-item',
        '.ot-tab-desc',
        '.ot-tab-list',
        '.ot-abt-tab'
      ];

      // -------------------------------------
      // Apply tabindex + aria-label (initial pass)
      // -------------------------------------
      $(otSelectors.join(','), context).each(function () {
        if (!$(this).is('a, button')) {
          $(this).attr('tabindex', '0');
          $(this).attr('aria-label', 'Cookie Preference Center');
        }
      });

      // -------------------------------------
      // Apply dialog role to modal container
      // -------------------------------------
      $('.ot-pc-container', context)
        .attr('role', 'dialog')
        .attr('aria-modal', 'true')
        .attr('aria-label', 'Cookie Preference Center')
        .attr('tabindex', '0');

      // -------------------------------------
      // INTERVAL — REQUIRED for late-loaded content
      // -------------------------------------
      const interval = setInterval(() => {

        const $targets = $(otSelectors.join(','));

        if ($targets.length > 0) {

          $targets.each(function () {
            if (!$(this).is('a, button')) {
              $(this).attr('tabindex', '0');
              $(this).attr('aria-label', 'Cookie Preference Center');
            }
          });

          // Apply again to dialog container if loaded late
          $('.ot-pc-container')
            .attr('role', 'dialog')
            .attr('aria-modal', 'true')
            .attr('aria-label', 'Cookie Preference Center')
            .attr('tabindex', '0');

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



























(function accessibilityEW($) {

  'use strict';

  Drupal.behaviors.accessibility = {
    attach: function (context) {

      // -------------------------------------
      // DPM-15107: Accessibility Table Elements
      // -------------------------------------
      $('table > thead > tr > th', context).attr('scope', 'col');
      $('table > tbody > tr > th', context).attr('scope', 'row');

      // -------------------------------------
      // DPM-18987: OneTrust Cookie Categories
      // Add tabindex + aria-label
      // -------------------------------------
      const otSelectors = [
        '.ot-cat-item',
        '.ot-tab-desc',
        '.ot-tab-list',
        '.ot-abt-tab'
      ];

      $(otSelectors.join(','), context).each(function () {
        // avoid interactive elements
        if (!$(this).is('a, button')) {
          $(this).attr('tabindex', '0');
          $(this).attr('aria-label', 'Cookie Preference Center');
        }
      });

      // -------------------------------------
      // DPM-18987: OneTrust Modal Container
      // Add dialog role + modal + tabindex
      // -------------------------------------
      $('.ot-pc-container', context)
        .attr('role', 'dialog')
        .attr('aria-modal', 'true')
        .attr('aria-label', 'Cookie Preference Center')
        .attr('tabindex', '0');

      // -------------------------------------
      // DPM-15100: Carousel Live Region
      // -------------------------------------
      $('.slick--field-carousel-slides', context).attr('aria-live', 'polite');
    }
  };

})(jQuery);












(function accessibilityEW($) {

  'use strict';

  Drupal.behaviors.accessibility = {
    attach: function (context) {

      // -------------------------------------
      // DPM-15107: Accessibility Table Elements
      // -------------------------------------
      $('table > thead > tr > th', context).attr('scope', 'col');
      $('table > tbody > tr > th', context).attr('scope', 'row');

      // -------------------------------------
      // DPM-18987: OneTrust Cookie Categories - tabindex + aria-label
      // -------------------------------------
      const otSelectors = [
        '.ot-cat-item',
        '.ot-tab-desc',
        '.ot-tab-list',
        '.ot-abt-tab'
      ];

      $(otSelectors.join(','), context).each(function () {
        if (!$(this).is('a, button')) {
          $(this).attr('tabindex', '0');
          $(this).attr('aria-label', 'Cookie Preference Center');
        }
      });

      // -------------------------------------
      // DPM-18987: OneTrust Modal Container - role="dialog"
      // -------------------------------------
      // Pick the correct modal container (OneTrust root)
      $('.ot-pc-container', context)
        .attr('role', 'dialog')
        .attr('aria-modal', 'true')
        .attr('aria-label', 'Cookie Preference Center')
        .attr('tabindex', '0');

      // -------------------------------------
      // DPM-15100: Carousel Live Region
      // -------------------------------------
      $('.slick--field-carousel-slides', context).attr('aria-live', 'polite');

    }
  };

})(jQuery);





















(function accessibilityEW($) {

  'use strict';

  Drupal.behaviors.accessibility = {
    attach: function (context) {

      // DPM-15107: Table accessibility
      $('table > thead > tr > th', context).attr('scope', 'col');
      $('table > tbody > tr > th', context).attr('scope', 'row');

      // DPM-18987: OneTrust Cookie Modal Elements
      const otSelectors = [
        '.ot-cat-item',
        '.ot-tab-desc',
        '.ot-tab-list',
        '.ot-abt-tab'
      ];

      // Add tabindex + aria-label
      $(otSelectors.join(','), context).each(function () {
        if (!$(this).is('a, button')) {
          $(this).attr('tabindex', '0');
          $(this).attr('aria-label', 'Cookie Preference Center');
        }
      });

      // Add role="dialog" to the COOKIE MODAL container only
      const dialogContainer = $('.ot-pc-container, .ot-pc-content, .ot-sdk-container', context).first();

      if (dialogContainer.length) {
        dialogContainer.attr('role', 'dialog');
        dialogContainer.attr('tabindex', '0');
        dialogContainer.attr('aria-label', 'Cookie Preference Center');
      }

      // Fallback for late-loaded OneTrust content
      const interval = setInterval(() => {

        const $targets = $(otSelectors.join(','));
        if ($targets.length > 0) {

          $targets.each(function () {
            if (!$(this).is('a, button')) {
              $(this).attr('tabindex', '0');
              $(this).attr('aria-label', 'Cookie Preference Center');
            }
          });

          // Ensure dialog role is applied even after async load
          const dialog = $('.ot-pc-container, .ot-pc-content, .ot-sdk-container').first();
          if (dialog.length) {
            dialog.attr('role', 'dialog');
            dialog.attr('tabindex', '0');
            dialog.attr('aria-label', 'Cookie Preference Center');
          }

          clearInterval(interval);
        }
      }, 250);

      // DPM-15100: Carousel live region
      $('.slick--field-carousel-slides', context).attr('aria-live', 'polite');

    }
  };

})(jQuery);

















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