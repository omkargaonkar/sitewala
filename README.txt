
 (function (Drupal) {
  Drupal.behaviors.addToAnyFocusTrap = {
    attach: function (context) {
      const modal = document.querySelector('#a2a_modal');
      const shareButton = document.querySelector('.a2a_dd, [data-a2a-url]');
      if (!modal || !shareButton) return;

      // Make sure modal has correct ARIA roles
      modal.setAttribute('role', 'dialog');
      modal.setAttribute('aria-modal', 'true');
      modal.setAttribute('tabindex', '-1');

      // Trap focus function
      const trapFocus = (event) => {
        const focusableElements = modal.querySelectorAll(
          'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'
        );
        if (!focusableElements.length) return;

        const firstElement = focusableElements[0];
        const lastElement = focusableElements[focusableElements.length - 1];

        // TAB key
        if (event.key === 'Tab') {
          if (event.shiftKey) {
            // SHIFT + TAB
            if (document.activeElement === firstElement) {
              event.preventDefault();
              lastElement.focus();
            }
          } else {
            // TAB forward
            if (document.activeElement === lastElement) {
              event.preventDefault();
              firstElement.focus();
            }
          }
        }

        // ESC closes modal
        if (event.key === 'Escape') {
          modal.style.display = 'none';
          modal.classList.add('a2a_hide');
          shareButton.focus();
        }
      };

      // Observe modal open/close state
      const observer = new MutationObserver(() => {
        const isVisible = modal.style.display !== 'none' && !modal.classList.contains('a2a_hide');

        if (isVisible) {
          // Move focus to first focusable element or modal itself
          const focusTarget = modal.querySelector('a, button, input, [tabindex]:not([tabindex="-1"])');
          (focusTarget || modal).focus();

          document.addEventListener('keydown', trapFocus);
        } else {
          document.removeEventListener('keydown', trapFocus);
          shareButton.focus();
        }
      });

      observer.observe(modal, { attributes: true, attributeFilter: ['style', 'class'] });
    },
  };
})(Drupal);