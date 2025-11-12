
      Yes 👍 — there is a simpler fix, without writing a full custom focus-trap script.
You can make the AddToAny “Share” modal accessible with just a few small steps — simple, clean, and Drupal-friendly 👇

⸻

🪄 Simple Fix (Quick Approach)

You just need to:
	1.	Give focus to the modal when it opens, and
	2.	Return focus to the “Share” button when it closes.

This doesn’t create a full focus trap, but it solves the main accessibility problem (screen reader + keyboard users knowing a modal appeared).

⸻

🧩 Steps

1. Add a small JavaScript file (example: a2a_focus_fix.js)
Put this file in your theme or custom module’s js/ folder:

(function (Drupal) {
  Drupal.behaviors.a2aFocusFix = {
    attach: function (context) {
      const modal = document.querySelector('#a2a_modal');
      const shareButton = document.querySelector('.a2a_dd'); // Adjust if different

      if (!modal || !shareButton) return;

      // Watch for the modal becoming visible
      const observer = new MutationObserver(() => {
        if (modal.style.display !== 'none') {
          // Modal is open — move focus inside
          modal.setAttribute('aria-modal', 'true');
          modal.setAttribute('role', 'dialog');
          modal.focus();
        } else {
          // Modal closed — return focus to Share button
          shareButton.focus();
        }
      });

      observer.observe(modal, { attributes: true, attributeFilter: ['style'] });
    },
  };
})(Drupal);


⸻

2. Add it to your theme’s .libraries.yml
Example:

a2a_focus_fix:
  js:
    js/a2a_focus_fix.js: {}
  dependencies:
    - core/drupal

Then attach it in your theme’s .info.yml:

libraries:
  - yourtheme/a2a_focus_fix


⸻

3. (Optional but Helpful) Add tabindex to make modal focusable
In your AddToAny modal markup, ensure:

<div id="a2a_modal" tabindex="-1"></div>

This lets .focus() actually work when the modal opens.

⸻

✅ Result
	•	Focus automatically moves inside the “Share” dialog when it opens.
	•	Focus returns to the Share button when closed.
	•	Screen readers will now announce the modal properly.
	•	No complicated JS or HTML rework needed.

⸻

Would you like me to show the exact CSS selector and code snippet based on your site’s AddToAny markup (you can paste a small HTML sample of your modal if you have it)?
That way, I’ll give you the 100% working version.