
Got it 👍 — you’re referring to Accessibility Issue: early-AMP104 about the AddToAny (Share) modal in Drupal, where keyboard focus isn’t trapped inside the modal once it opens.

Let’s go step-by-step on how to fix this for the AddToAny module.

⸻

🧩 Issue Summary

When the user opens the AddToAny “Share” modal (dialog), focus:
	•	Does not move inside the modal.
	•	Is not trapped within it (you can tab out of the dialog).

This violates WCAG 2.1.1 Keyboard and 2.4.3 Focus Order, plus ARIA 1.2 Dialog pattern requirements.

⸻

✅ Goal

When the modal opens:
	1.	Move focus to the first focusable element (e.g., “Copy Link”).
	2.	Trap focus within the modal (Shift+Tab / Tab shouldn’t escape).
	3.	Return focus to the trigger (e.g., “Share” button) when modal closes.

⸻

🛠️ Solution (Drupal AddToAny Integration)

Option 1: Custom JavaScript Fix (Recommended)
Since AddToAny doesn’t yet support focus trapping natively, you can patch this behavior with a small JS snippet in your Drupal theme or custom module.

Add this JS to your custom module or theme (for example, custom_focus_trap.js):

(function (Drupal) {
  Drupal.behaviors.addToAnyFocusTrap = {
    attach: function (context) {
      const modal = document.querySelector('#a2a_modal');
      const shareButton = document.querySelector('[data-a2a-url], .a2a_dd'); // adjust selector if needed

      if (!modal || !shareButton) return;

      // Trap focus inside modal
      const trapFocus = (event) => {
        const focusableElements = modal.querySelectorAll(
          'a, button, textarea, input, select, [tabindex]:not([tabindex="-1"])'
        );
        const firstElement = focusableElements[0];
        const lastElement = focusableElements[focusableElements.length - 1];

        if (event.key === 'Tab') {
          if (event.shiftKey) {
            // Shift + Tab
            if (document.activeElement === firstElement) {
              event.preventDefault();
              lastElement.focus();
            }
          } else {
            // Tab
            if (document.activeElement === lastElement) {
              event.preventDefault();
              firstElement.focus();
            }
          }
        }
      };

      // Observe modal open
      const observer = new MutationObserver(() => {
        if (modal.style.display !== 'none') {
          // Move focus to first element
          const focusable = modal.querySelector('a, button, [tabindex]:not([tabindex="-1"])');
          if (focusable) focusable.focus();

          modal.addEventListener('keydown', trapFocus);
        } else {
          modal.removeEventListener('keydown', trapFocus);
          // Return focus to Share button
          shareButton.focus();
        }
      });

      observer.observe(modal, { attributes: true, attributeFilter: ['style', 'class'] });
    },
  };
})(Drupal);

Then add it in your theme or module’s .libraries.yml and attach it.

Example (in your theme):

custom_focus_trap:
  js:
    js/custom_focus_trap.js: {}
  dependencies:
    - core/drupal

Attach it in your theme’s .info.yml:

libraries:
  - yourtheme/custom_focus_trap


⸻

Option 2: Add Accessible Attributes (Optional Enhancement)
You can improve accessibility by ensuring these attributes are present:

<div id="a2a_modal" role="dialog" aria-modal="true" aria-labelledby="shareDialogTitle">
  <h2 id="shareDialogTitle" class="visually-hidden">Share this content</h2>
</div>

aria-modal="true" helps screen readers recognize the modal context.

⸻

🧠 Why This Works
	•	Focus automatically moves to the modal → users immediately know something changed.
	•	Tabbing stays inside → prevents accidental focus escape.
	•	Focus returns to “Share” → consistent keyboard behavior.
	•	Works without altering AddToAny’s source code.

⸻

🔗 References
	•	W3C ARIA Dialog Best Practices:
https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/
	•	AddToAny Drupal Module:
https://www.drupal.org/project/addtoany

⸻

If you tell me which Drupal version you’re using (e.g. 9 or 10), I can tailor the JS snippet to match that (for example, once() usage or attaching via Drupal.behaviors correctly).
Would you like me to give you a version-specific snippet (for Drupal 9 or 10)?