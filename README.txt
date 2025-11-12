(function (Drupal) {
  Drupal.behaviors.addToAnyCustomFixes = {
    attach: function (context) {
      // 1️⃣ Remove unnecessary title attribute
      context.querySelectorAll('a[title="Share Buttons"]').forEach(link => {
        link.removeAttribute('title');
      });

      // 2️⃣ Ensure modal focus management (optional if already handled)
      const modal = context.querySelector('#a2a_modal');
      const shareButton = context.querySelector('.a2a_dd, [data-a2a-url]');
      if (modal && shareButton) {
        modal.setAttribute('role', 'dialog');
        modal.setAttribute('aria-modal', 'true');
        modal.setAttribute('tabindex', '-1');

        const trapFocus = (event) => {
          const focusableElements = modal.querySelectorAll(
            'a, button, input, [tabindex]:not([tabindex="-1"])'
          );
          const first = focusableElements[0];
          const last = focusableElements[focusableElements.length - 1];
          if (event.key === 'Tab') {
            if (event.shiftKey && document.activeElement === first) {
              event.preventDefault();
              last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
              event.preventDefault();
              first.focus();
            }
          }
        };

        const observer = new MutationObserver(() => {
          const isVisible = modal.style.display !== 'none' && !modal.classList.contains('a2a_hide');
          if (isVisible) {
            const firstFocusable = modal.querySelector('a, button, [tabindex]:not([tabindex="-1"])');
            (firstFocusable || modal).focus();
            document.addEventListener('keydown', trapFocus);
          } else {
            document.removeEventListener('keydown', trapFocus);
            shareButton.focus();
          }
        });
        observer.observe(modal, { attributes: true, attributeFilter: ['style', 'class'] });
      }
    }
  };
})(Drupal);