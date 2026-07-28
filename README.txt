(function () {
  document.querySelectorAll('.social-media-links--platforms a').forEach(function (link) {
    if (!link.hasAttribute('aria-label') || !link.getAttribute('aria-label').trim()) {

      if (link.classList.contains('social-media-link-icon--tiktok')) {
        link.setAttribute('aria-label', 'Follow Zelle on TikTok');
      } else if (link.classList.contains('social-media-link-icon--twitter')) {
        link.setAttribute('aria-label', 'Follow Zelle on X');
      } else if (link.classList.contains('social-media-link-icon--youtube')) {
        link.setAttribute('aria-label', 'Subscribe to Zelle on YouTube');
      }

      // Optional: keep tooltip consistent
      link.setAttribute('title', link.getAttribute('aria-label'));
    }
  });
})();




The reported accessibility issue has been resolved. The focus indicator now meets the WCAG requirement with a contrast ratio greater than 3:1. Ready for QA verification.



.paragraph-body p a.cta_link:focus,
.paragraph-body p a.cta_link:focus-visible {
    box-shadow: 0 0 0 .25rem rgba(36,51,77,.6) !important;
}






Hi [Manager’s Name],

I checked the current sprint assignments in Jira and noticed that I’ve been assigned 6 story points, while Shraddha has been assigned 12 story points.

I have additional bandwidth this sprint, so I’d be happy to take on some of her tasks if that helps balance the workload.






Implemented a JavaScript fix to ensure aria-describedby only references valid IDs. Invalid references are removed and restored dynamically when validation messages are available, resolving the accessibility issue.

Yes. If you're restricted to using the **Drupal JS Injector**, you can fix the issue by:

* Removing `aria-describedby` when the referenced ID does **not** exist.
* Restoring `aria-describedby` automatically when the validation message is added to the DOM.
* Watching for DOM changes so it works with Eloqua validation.

### Drupal JS Injector

```javascript
(function () {

  if (window.ariaDescribedByFixInitialized) return;
  window.ariaDescribedByFixInitialized = true;

  function updateAriaDescribedBy() {

    document.querySelectorAll('[aria-describedby]').forEach(function (field) {

      var describedBy = field.getAttribute('aria-describedby');

      if (!describedBy) return;

      var ids = describedBy.trim().split(/\s+/);
      var validIds = [];

      ids.forEach(function (id) {
        if (document.getElementById(id)) {
          validIds.push(id);
        }
      });

      if (validIds.length) {
        field.setAttribute('aria-describedby', validIds.join(' '));
      } else {
        field.removeAttribute('aria-describedby');
      }

    });

  }

  // Initial check
  updateAriaDescribedBy();

  // Watch for validation messages added by Eloqua
  new MutationObserver(function () {
    updateAriaDescribedBy();
  }).observe(document.body, {
    childList: true,
    subtree: true
  });

})();
```

### What this fixes

Before validation:

```html
<input aria-describedby="error_lastName">
```

❌ `error_lastName` does not exist

↓

JS changes it to:

```html
<input>
```

When Eloqua adds:

```html
<span id="error_lastName">
Please provide your last name.
</span>
```

↓

JS automatically changes it back to:

```html
<input aria-describedby="error_lastName">
```

### Why this is a good solution

* ✅ Works for all Eloqua forms.
* ✅ No hardcoded field names.
* ✅ Supports multiple IDs in `aria-describedby`.
* ✅ Fixes the accessibility scan by ensuring `aria-describedby` only references IDs that actually exist.
* ✅ Can be added once in the Drupal JS Injector and reused across all forms.
********************************************************************************************************************************************************************************************************************************************************


DPM-23000
***************************
Since **both issues are the same accessibility rule** (focusable elements inside `aria-hidden="true"`), **don't add two separate scripts**. That can cause duplicate MutationObservers and unnecessary processing.

Instead, use **one combined JS Injector** that handles **both `.slick-slide` and `.slick__slide`** carousels across your Drupal site.

### Combined Drupal JS Injector

```javascript
(function () {

  if (window.slickAriaHiddenFixInitialized) return;
  window.slickAriaHiddenFixInitialized = true;

  function updateAccessibility() {

    document.querySelectorAll('.slick-slide, .slick__slide').forEach(function (slide) {

      var isHidden = slide.getAttribute('aria-hidden') === 'true';

      // Make the slide itself non-focusable when hidden
      slide.setAttribute('tabindex', isHidden ? '-1' : '0');

      // Update all focusable elements inside the slide
      slide.querySelectorAll(
        'a[href], button, input, select, textarea, details, audio[controls], video[controls], [tabindex]'
      ).forEach(function (el) {

        if (isHidden) {

          if (!el.hasAttribute('data-original-tabindex')) {
            el.setAttribute(
              'data-original-tabindex',
              el.hasAttribute('tabindex') ? el.getAttribute('tabindex') : ''
            );
          }

          el.setAttribute('tabindex', '-1');

        } else {

          if (el.hasAttribute('data-original-tabindex')) {

            var original = el.getAttribute('data-original-tabindex');

            if (original === '') {
              el.removeAttribute('tabindex');
            } else {
              el.setAttribute('tabindex', original);
            }

            el.removeAttribute('data-original-tabindex');

          } else if (
            el.matches('a[href], button, input, select, textarea, details, audio[controls], video[controls]')
          ) {

            el.removeAttribute('tabindex');

          }

        }

      });

    });

  }

  // Initial run
  updateAccessibility();

  // Observe all Slick carousels
  document.querySelectorAll('.slick-slider, .slick-track').forEach(function (slider) {

    new MutationObserver(updateAccessibility).observe(slider, {
      subtree: true,
      attributes: true,
      attributeFilter: ['aria-hidden', 'class']
    });

  });

})();
```

### Why use one script?

* ✅ One JS Injector for all pages.
* ✅ Handles both `.slick-slide` and `.slick__slide`.
* ✅ Covers Homepage, Shoppers Page, Merchant Carousel, and any other Slick carousel.
* ✅ Prevents duplicate observers and duplicate execution.
* ✅ Easier to maintain in Drupal.

**This is the approach I recommend instead of pasting two separate JS snippets into the Drupal JS Injector.**

**************************

(function () {

  if (window.slickAriaHiddenSlidesFix) return;
  window.slickAriaHiddenSlidesFix = true;

  function updateSlides() {

    document.querySelectorAll('.slick__slide, .slick-slide').forEach(function (slide) {

      var hidden = slide.getAttribute('aria-hidden') === 'true';

      // Remove slide itself from tab order
      slide.setAttribute('tabindex', hidden ? '-1' : '0');

      // Update all focusable descendants
      slide.querySelectorAll(
        'a[href], button, input, select, textarea, [tabindex]'
      ).forEach(function (el) {

        if (hidden) {

          if (!el.hasAttribute('data-original-tabindex')) {
            el.setAttribute(
              'data-original-tabindex',
              el.hasAttribute('tabindex') ? el.getAttribute('tabindex') : ''
            );
          }

          el.setAttribute('tabindex', '-1');

        } else {

          if (el.hasAttribute('data-original-tabindex')) {

            var original = el.getAttribute('data-original-tabindex');

            if (original === '') {
              el.removeAttribute('tabindex');
            } else {
              el.setAttribute('tabindex', original);
            }

            el.removeAttribute('data-original-tabindex');

          } else {

            el.removeAttribute('tabindex');

          }

        }

      });

    });

  }

  updateSlides();

  document.querySelectorAll('.slick-slider, .slick-track').forEach(function (slider) {

    new MutationObserver(updateSlides).observe(slider, {
      subtree: true,
      attributes: true,
      attributeFilter: ['aria-hidden', 'class']
    });

  });

})();

Implemented a JavaScript fix to remove hidden (aria-hidden="true") carousel content from the keyboard tab order and restore focusability when slides become visible. This resolves the accessibility issue for focusable elements within aria-hidden="true" on the Homepage and Shoppers Page.

Based on the HTML you shared, the issue is caused by **Slick Slider**. 

For example, there are slides like:

```html
<div class="slick__slide" aria-hidden="true" tabindex="0">
```

and inside them are focusable links:

```html
<a href="..." tabindex="0">
```

This violates WCAG because **elements hidden from assistive technology (`aria-hidden="true"`) must not be keyboard focusable.** 

---

## Drupal JS Injector Fix

This code automatically:

* ✅ Finds every `.slick__slide`
* ✅ Checks `aria-hidden`
* ✅ If `aria-hidden="true"`

  * removes all focusable elements from keyboard (`tabindex="-1"`)
* ✅ If `aria-hidden="false"`

  * restores focusability
* ✅ Works after Slick changes slides
* ✅ Uses MutationObserver so it continues working
* ✅ Prevents duplicate execution
* ✅ Covers Homepage and Shoppers Page

```javascript
(function () {

  if (window.slickAriaHiddenFixInitialized) return;
  window.slickAriaHiddenFixInitialized = true;

  function updateHiddenSlides() {

    document.querySelectorAll('.slick__slide').forEach(function (slide) {

      var isHidden = slide.getAttribute('aria-hidden') === 'true';

      var focusable = slide.querySelectorAll(
        'a[href], button, input, select, textarea, details, audio[controls], video[controls], [tabindex]'
      );

      focusable.forEach(function (el) {

        if (isHidden) {

          // Save original tabindex
          if (!el.hasAttribute('data-original-tabindex')) {
            el.setAttribute(
              'data-original-tabindex',
              el.hasAttribute('tabindex') ? el.getAttribute('tabindex') : ''
            );
          }

          el.setAttribute('tabindex', '-1');

        } else {

          if (el.hasAttribute('data-original-tabindex')) {

            var original = el.getAttribute('data-original-tabindex');

            if (original === '') {
              el.removeAttribute('tabindex');
            } else {
              el.setAttribute('tabindex', original);
            }

            el.removeAttribute('data-original-tabindex');

          } else {

            if (
              el.matches('a[href], button, input, select, textarea')
            ) {
              el.removeAttribute('tabindex');
            }

          }

        }

      });

    });

  }

  // Initial run
  updateHiddenSlides();

  // Observe aria-hidden changes from Slick
  document.querySelectorAll('.slick-slider, .slick-track').forEach(function (slider) {

    new MutationObserver(function () {
      updateHiddenSlides();
    }).observe(slider, {
      attributes: true,
      subtree: true,
      attributeFilter: ['aria-hidden', 'class']
    });

  });

})();
```

---

## Why this fixes the issue

When Slick marks a slide as:

```html
<div aria-hidden="true">
```

all interactive elements inside become:

```html
<a tabindex="-1">
<button tabindex="-1">
<input tabindex="-1">
<select tabindex="-1">
```

When the slide becomes visible again:

```html
aria-hidden="false"
```

their original keyboard behavior is restored automatically.

---

### This covers the accessibility rule

✔ No focusable element inside `aria-hidden="true"` content

✔ Hidden slides removed from keyboard navigation

✔ Visible slides remain keyboard accessible

✔ Works dynamically with Slick Carousel

✔ Meets the WCAG requirement for **Focusable element with `aria-hidden="true"`**.

This solution is more robust than simply targeting `<a>` elements because it covers **all interactive controls** (links, buttons, inputs, selects, textareas, audio/video controls, and any element with a `tabindex`) that could trigger this accessibility violation.


************************************************************************************************


DPM-23034
Resolved the aria-describedby invalid ID accessibility issue on the Contact Sales form. Ensured that every aria-describedby attribute references a valid element in the DOM by creating missing error message containers for fields that did not have corresponding IDs. Existing valid references were left unchanged. This ensures screen readers can correctly associate descriptive/error text with each form control and addresses the WCAG requirement for valid aria-describedby references.

Based on your HTML, the issue is that these IDs are missing at page load:

* `error_lastName`
* `error_mobilePhone`
* `error_emailAddress`
* `error_company`
* `error_title`

Since you are using a **Drupal JS Injector**, the best approach is to create the missing elements only if they don't already exist.

```javascript
(function () {

  // Prevent duplicate execution
  if (window.fixAriaDescribedbyInvalidIds) return;
  window.fixAriaDescribedbyInvalidIds = true;

  function fixAriaDescribedby() {

    document.querySelectorAll('input[aria-describedby]').forEach(function (input) {

      var describedBy = input.getAttribute('aria-describedby');
      if (!describedBy) return;

      describedBy.trim().split(/\s+/).forEach(function (id) {

        // Skip if referenced element already exists
        if (document.getElementById(id)) return;

        // Create hidden placeholder
        var errorMessage = document.createElement('span');
        errorMessage.id = id;
        errorMessage.className = 'LV_validation_message';
        errorMessage.setAttribute('role', 'alert');
        errorMessage.setAttribute('aria-live', 'polite');
        errorMessage.hidden = true;
        errorMessage.textContent = '';

        // Insert immediately after the field wrapper
        var wrapper = input.closest('.field-control-wrapper');

        if (wrapper) {
          wrapper.insertAdjacentElement('afterend', errorMessage);
        } else {
          input.insertAdjacentElement('afterend', errorMessage);
        }

      });

    });

  }

  // Initial execution
  fixAriaDescribedby();

  // Re-run if the form is dynamically updated
  var observer = new MutationObserver(function () {
    fixAriaDescribedby();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

})();
```

### What this fixes

If your HTML is:

```html
<input
    id="fe215"
    aria-describedby="error_lastName">
```

and there is **no** element with:

```html
id="error_lastName"
```

the script creates:

```html
<span
    id="error_lastName"
    class="LV_validation_message"
    role="alert"
    aria-live="polite"
    hidden>
</span>
```

It does the same for:

* `error_mobilePhone`
* `error_emailAddress`
* `error_company`
* `error_title`

### Important

This fixes the specific accessibility rule **only if the problem is that the referenced IDs are missing**.

However, if the accessibility scanner is running **before your form or validation library finishes rendering**, or if the validation library later removes/replaces these elements, then the real fix should be made in the form template or validation code rather than by JavaScript injection.

**Before deploying this**, verify by running in the browser console after page load:

```javascript
document.querySelectorAll('[id^="error_"]')
```

If you now see all of the following IDs:

* `error_firstName`
* `error_lastName`
* `error_mobilePhone`
* `error_emailAddress`
* `error_company`
* `error_title`

then the `aria-describedby` references are valid and this specific WCAG issue should be resolved.

*************************************************************************************************

DPM-22998

Added a Drupal JS accessibility fix for image-only blog links that were missing an accessible name. The script detects the affected blog link and programmatically adds an appropriate aria-label ("Online Checkout Report"), ensuring the link has a clear accessible name for screen reader users while preserving the existing visual presentation.

(function () {

    if (window.blogLinkAccessibilityFix) return;
    window.blogLinkAccessibilityFix = true;

    document.querySelectorAll('a[href]').forEach(function (link) {

        // Skip if link already has an accessible name
        if (
            link.hasAttribute('aria-label') ||
            link.hasAttribute('aria-labelledby') ||
            link.textContent.trim() !== ""
        ) {
            return;
        }

        var img = link.querySelector('img');

        if (!img) return;

        // Add accessible name based on destination
        if (link.href.includes('/blog/online-checkout-report-trust-and-security')) {

            link.setAttribute(
                'aria-label',
                'Online Checkout Report – Trust and Security'
            );

        }

    });

})();


*********************************************************************************
********************************************************************************

Comment :

Implemented accessibility improvements for the Slick carousel to align with the WCAG acceptance criteria.

Completed fixes:

Added role="region" to the carousel container.
Added aria-roledescription="carousel" to the carousel container.
Added an accessible aria-label to the carousel container (without using the word "carousel").
Updated slide labels dynamically to announce the correct position (e.g., "1 of 3", "2 of 3").
Implemented dynamic aria-hidden management so only the active slide is exposed to assistive technologies.
Added aria-live="polite" and aria-atomic="false" to the slide wrapper for appropriate screen reader announcements.
Removed unnecessary tabindex="0" from active links while maintaining tabindex="-1" for inactive slide links.
Ensured accessibility attributes are updated automatically on every Slick slide change.
Hidden cloned Slick slides from assistive technologies to prevent duplicate announcements.

******************************************************************************************
DPM-22797
**************************************************************************************
Below is a **single Drupal JS Injector compatible script** that addresses **only** the issues you listed.

**✔ Fixes included**

* ✅ Adds `role="region"` to carousel container
* ✅ Adds `aria-roledescription="carousel"`
* ✅ Adds accessible `aria-label`
* ✅ Corrects slide labels (`1 of N`, `2 of N`, ...)
* ✅ Updates `aria-hidden` dynamically
* ✅ Adds `aria-live` and `aria-atomic`
* ✅ Removes unnecessary `tabindex="0"` from active links
* ✅ Keeps `tabindex="-1"` on inactive slide links
* ✅ Automatically updates after every Slick slide change
* ✅ Prevents duplicate initialization

```javascript
(function () {

    // Prevent duplicate initialization
    if (window.carouselAccessibilityInitialized) return;
    window.carouselAccessibilityInitialized = true;

    function initCarouselAccessibility() {

        document.querySelectorAll('.slick').forEach(function (carousel) {

            if (carousel.dataset.carouselA11yInitialized) return;
            carousel.dataset.carouselA11yInitialized = "true";

            //----------------------------------------------------
            // Carousel Container
            //----------------------------------------------------

            var container =
                carousel.closest('.paragraph-wrapper') ||
                carousel.querySelector('.paragraph-wrapper') ||
                carousel;

            container.setAttribute('role', 'region');
            container.setAttribute('aria-roledescription', 'carousel');

            if (!container.hasAttribute('aria-label') &&
                !container.hasAttribute('aria-labelledby')) {
                container.setAttribute('aria-label', 'Featured Resources');
            }

            //----------------------------------------------------
            // Live Region
            //----------------------------------------------------

            var track = carousel.querySelector('.slick-track');

            if (track) {
                track.setAttribute('aria-live', 'polite');
                track.setAttribute('aria-atomic', 'false');
            }

            //----------------------------------------------------
            // Update Slides
            //----------------------------------------------------

            function updateSlides() {

                var slides = carousel.querySelectorAll(
                    '.slick__slide:not(.slick-cloned)'
                );

                var total = slides.length;

                slides.forEach(function (slide, index) {

                    var content =
                        slide.querySelector('.paragraph') ||
                        slide.querySelector('[role="group"]') ||
                        slide;

                    //--------------------------------------------
                    // Slide Role
                    //--------------------------------------------

                    content.setAttribute('role', 'group');
                    content.setAttribute('aria-roledescription', 'slide');
                    content.setAttribute(
                        'aria-label',
                        (index + 1) + ' of ' + total
                    );

                    //--------------------------------------------
                    // Active Slide
                    //--------------------------------------------

                    var active = slide.classList.contains('slick-active');

                    content.setAttribute(
                        'aria-hidden',
                        active ? 'false' : 'true'
                    );

                    //--------------------------------------------
                    // Links
                    //--------------------------------------------

                    slide.querySelectorAll('a').forEach(function (link) {

                        if (active) {
                            // Native links don't need tabindex="0"
                            if (link.getAttribute('tabindex') === '0') {
                                link.removeAttribute('tabindex');
                            }
                        } else {
                            link.setAttribute('tabindex', '-1');
                        }

                    });

                });

                //------------------------------------------------
                // Hide cloned slides
                //------------------------------------------------

                carousel.querySelectorAll('.slick-cloned').forEach(function (clone) {

                    clone.setAttribute('aria-hidden', 'true');

                    clone.querySelectorAll('a').forEach(function (link) {
                        link.setAttribute('tabindex', '-1');
                    });

                });

            }

            updateSlides();

            //----------------------------------------------------
            // Observe class changes from Slick
            //----------------------------------------------------

            var observer = new MutationObserver(function () {
                updateSlides();
            });

            carousel.querySelectorAll('.slick__slide').forEach(function (slide) {

                observer.observe(slide, {
                    attributes: true,
                    attributeFilter: ['class']
                });

            });

        });

    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initCarouselAccessibility);
    } else {
        initCarouselAccessibility();
    }

})();
```

### This script covers all requested fixes

| Issue                                  | Fixed |
| -------------------------------------- | :---: |
| `role="region"`                        |   ✅   |
| `aria-roledescription="carousel"`      |   ✅   |
| Accessible `aria-label`                |   ✅   |
| Correct slide labels (`1 of 3`, etc.)  |   ✅   |
| Dynamic `aria-hidden`                  |   ✅   |
| `aria-live="polite"`                   |   ✅   |
| `aria-atomic="false"`                  |   ✅   |
| Remove unnecessary `tabindex="0"`      |   ✅   |
| Keep `tabindex="-1"` on inactive links |   ✅   |
| Supports Slick slide changes           |   ✅   |
| Drupal JS Injector compatible          |   ✅   |

This script is suitable for your **Zelle Drupal Slick Carousel** implementation and addresses the accessibility issues you listed without modifying the HTML templates.



*****************************************************************************************

(function () {

    // Prevent duplicate initialization
    if (window.carouselAccessibilityFixInitialized) return;
    window.carouselAccessibilityFixInitialized = true;

    function initCarouselAccessibility() {

        document.querySelectorAll('.paragraph-wrapper[aria-roledescription="carousel"]').forEach(function (carousel, carouselIndex) {

            // Prevent duplicate processing
            if (carousel.dataset.a11yInitialized) return;
            carousel.dataset.a11yInitialized = "true";

            //-------------------------------------------------
            // Carousel Container
            //-------------------------------------------------

            carousel.setAttribute('role', 'region');
            carousel.setAttribute('aria-roledescription', 'carousel');

            if (!carousel.hasAttribute('aria-label') &&
                !carousel.hasAttribute('aria-labelledby')) {

                carousel.setAttribute(
                    'aria-label',
                    'Featured content'
                );
            }

            //-------------------------------------------------
            // Live Region
            //-------------------------------------------------

            var slider = carousel.querySelector('.slick-track');

            if (slider) {

                slider.setAttribute('aria-live', 'polite');
                slider.setAttribute('aria-atomic', 'false');

            }

            //-------------------------------------------------
            // Slides
            //-------------------------------------------------

            var slides = carousel.querySelectorAll('.slick__slide:not(.slick-cloned)');
            var total = slides.length;

            slides.forEach(function (slide, index) {

                var container = slide.querySelector('.paragraph');

                if (!container) return;

                container.setAttribute('role', 'group');
                container.setAttribute('aria-roledescription', 'slide');

                container.setAttribute(
                    'aria-label',
                    (index + 1) + ' of ' + total
                );

            });

            //-------------------------------------------------
            // Hide cloned slides
            //-------------------------------------------------

            carousel.querySelectorAll('.slick-cloned').forEach(function (clone) {

                clone.setAttribute('aria-hidden', 'true');

                clone.querySelectorAll('a, button, input, select, textarea').forEach(function (el) {

                    el.setAttribute('tabindex', '-1');

                });

            });

            //-------------------------------------------------
            // Previous / Next Buttons
            //-------------------------------------------------

            var prev = carousel.querySelector('.slick-prev');
            var next = carousel.querySelector('.slick-next');

            if (prev) {

                prev.type = "button";
                prev.setAttribute('aria-label', 'Previous slide');
                prev.setAttribute('aria-controls', 'carousel-' + carouselIndex);

            }

            if (next) {

                next.type = "button";
                next.setAttribute('aria-label', 'Next slide');
                next.setAttribute('aria-controls', 'carousel-' + carouselIndex);

            }

            carousel.id = 'carousel-' + carouselIndex;

            //-------------------------------------------------
            // Rotation Button (if autoplay)
            //-------------------------------------------------

            if (!carousel.querySelector('.carousel-rotation-toggle')) {

                var toggle = document.createElement('button');

                toggle.type = "button";
                toggle.className = "carousel-rotation-toggle";
                toggle.textContent = "Pause";
                toggle.setAttribute('aria-label', 'Pause automatic slide rotation');

                var paused = false;

                toggle.addEventListener('click', function () {

                    paused = !paused;

                    if (window.jQuery) {

                        var slick = window.jQuery(carousel).find('.slick__slider');

                        if (paused) {

                            slick.slick('slickPause');

                            toggle.textContent = "Play";
                            toggle.setAttribute(
                                'aria-label',
                                'Resume automatic slide rotation'
                            );

                        } else {

                            slick.slick('slickPlay');

                            toggle.textContent = "Pause";
                            toggle.setAttribute(
                                'aria-label',
                                'Pause automatic slide rotation'
                            );

                        }

                    }

                });

                var nav = carousel.querySelector('.slick__arrow');

                if (nav) {

                    nav.appendChild(toggle);

                }

            }

            //-------------------------------------------------
            // Update Active Slide
            //-------------------------------------------------

            function updateSlides() {

                carousel.querySelectorAll('.slick__slide').forEach(function (slide) {

                    var container = slide.querySelector('.paragraph');

                    if (!container) return;

                    var active = slide.classList.contains('slick-active') &&
                                 !slide.classList.contains('slick-cloned');

                    container.setAttribute(
                        'aria-hidden',
                        active ? 'false' : 'true'
                    );

                    container.querySelectorAll('a, button, input, textarea, select').forEach(function (el) {

                        if (active) {

                            el.removeAttribute('tabindex');

                        } else {

                            el.setAttribute('tabindex', '-1');

                        }

                    });

                });

            }

            updateSlides();

            //-------------------------------------------------
            // Watch for slide changes
            //-------------------------------------------------

            var track = carousel.querySelector('.slick-track');

            if (track) {

                new MutationObserver(function () {

                    updateSlides();

                }).observe(track, {

                    attributes: true,
                    subtree: true,
                    attributeFilter: ['class']

                });

            }

        });

    }

    //---------------------------------------------------------
    // Wait until Slick loads
    //---------------------------------------------------------

    function waitForSlick() {

        if (document.querySelector('.slick-initialized')) {

            initCarouselAccessibility();

        } else {

            setTimeout(waitForSlick, 300);

        }

    }

    if (document.readyState === "loading") {

        document.addEventListener("DOMContentLoaded", waitForSlick);

    } else {

        waitForSlick();

    }

})();




************************************************
DPM-22795
**************************************************
(function () {

  // Prevent duplicate execution
  if (window.removeRedundantAnchorTabindex) return;
  window.removeRedundantAnchorTabindex = true;

  function removeAnchorTabindex() {

    document.querySelectorAll('a[href][tabindex="0"]').forEach(function (link) {
      link.removeAttribute('tabindex');
    });

  }

  // Initial run
  removeAnchorTabindex();

  // Observe dynamically added content
  const observer = new MutationObserver(function () {
    removeAnchorTabindex();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

})();

*******************************************************************************

(function () {

    // Prevent duplicate execution
    if (window.removeHeadingParagraphTabindex) return;
    window.removeHeadingParagraphTabindex = true;

    function removeTabindex() {

        // Remove tabindex only from headings and paragraphs inside Slick
        document.querySelectorAll(
            '.slick-list h1[tabindex], ' +
            '.slick-list h2[tabindex], ' +
            '.slick-list h3[tabindex], ' +
            '.slick-list h4[tabindex], ' +
            '.slick-list h5[tabindex], ' +
            '.slick-list h6[tabindex], ' +
            '.slick-list p[tabindex]'
        ).forEach(function (element) {
            element.removeAttribute('tabindex');
        });

    }

    function init() {

        removeTabindex();

        // Watch for Slick updates
        const observer = new MutationObserver(removeTabindex);

        document.querySelectorAll('.slick-list').forEach(function (slickList) {
            observer.observe(slickList, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ['tabindex']
            });
        });

    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();


*********************************************************

(function () {

    // Prevent duplicate execution
    if (window.removeHeadingParagraphTabindex) return;
    window.removeHeadingParagraphTabindex = true;

    function removeTabindex() {

        // Remove tabindex from all H1-H6 and P elements
        document.querySelectorAll('h1[tabindex], h2[tabindex], h3[tabindex], h4[tabindex], h5[tabindex], h6[tabindex], p[tabindex]').forEach(function (element) {
            element.removeAttribute('tabindex');
        });

    }

    function init() {

        removeTabindex();

        // Watch for Drupal AJAX / Slick updates
        const observer = new MutationObserver(function () {
            removeTabindex();
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['tabindex']
        });

    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
******************************************************************************
DPM-22794  -4
********************************************************************************

(function () {

  // Prevent duplicate execution
  if (window.slickRemoveTabindexInit) return;
  window.slickRemoveTabindexInit = true;

  function removeTabindex() {
    document.querySelectorAll('.slick__slide a[tabindex]').forEach(function (link) {
      link.removeAttribute('tabindex');
    });
  }

  function init() {

    removeTabindex();

    // Watch for Slick DOM updates
    const observer = new MutationObserver(function () {
      removeTabindex();
    });

    document.querySelectorAll('.slick').forEach(function (slider) {
      observer.observe(slider, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['class', 'tabindex']
      });
    });

  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();



(function () {

    function removeTabindex() {
        document.querySelectorAll('.slick__slide a[tabindex]').forEach(function (link) {
            link.removeAttribute('tabindex');
        });
    }

    removeTabindex();

    // Re-run if Slick updates the DOM
    const observer = new MutationObserver(removeTabindex);

    document.querySelectorAll('.slick').forEach(function (slider) {
        observer.observe(slider, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['class']
        });
    });

})();
******************************************************************************
DPM-22794  -3
********************************************************************************

(function ($, Drupal) {

  Drupal.behaviors.slickAccessibilityFix = {
    attach: function (context) {

      $('.slick', context).each(function () {

        var $slider = $(this);

        // Prevent duplicate initialization
        if ($slider.data('slickAccessibilityInitialized')) {
          return;
        }
        $slider.data('slickAccessibilityInitialized', true);

        function updateAccessibility() {

          // Remove unnecessary tabindex from slide containers
          $slider.find('.slick__slide[role="tabpanel"]').removeAttr('tabindex');

          $slider.find('.slick__slide[role="tabpanel"]').each(function () {

            var $slide = $(this);
            var active = $slide.hasClass('slick-active') &&
              $slide.attr('aria-hidden') === 'false';

            // Manage focusable elements
            $slide.find('a, button, input, select, textarea, iframe').each(function () {

              if (active) {

                // Native links/buttons should use default browser behavior
                if (this.tagName.toLowerCase() === 'a') {
                  $(this).removeAttr('tabindex');
                } else if (this.tagName.toLowerCase() !== 'button') {
                  $(this).attr('tabindex', '0');
                } else {
                  $(this).removeAttr('tabindex');
                }

              } else {

                $(this).attr('tabindex', '-1');

              }

            });

          });

          // Update carousel dots
          $slider.find('.slick-dots li').each(function () {

            var $li = $(this);
            var $btn = $li.find('[role="tab"]');

            if (!$btn.length) {
              return;
            }

            if ($li.hasClass('slick-active')) {
              $btn.attr({
                'aria-selected': 'true',
                'tabindex': '0'
              });
            } else {
              $btn.attr({
                'aria-selected': 'false',
                'tabindex': '-1'
              });
            }

          });

          // Remove hidden Previous/Next buttons from tab order
          $slider.find('.slick-prev.visually-hidden, .slick-next.visually-hidden').attr({
            'tabindex': '-1',
            'aria-hidden': 'true'
          });

        }

        // Initial execution
        updateAccessibility();

        // Slick event
        $slider.on('afterChange', function () {
          setTimeout(updateAccessibility, 50);
        });

        // Observe slide changes
        var observer = new MutationObserver(function () {
          updateAccessibility();
        });

        $slider.find('.slick__slide').each(function () {
          observer.observe(this, {
            attributes: true,
            attributeFilter: ['class', 'aria-hidden']
          });
        });

        $slider.find('.slick-dots li').each(function () {
          observer.observe(this, {
            attributes: true,
            attributeFilter: ['class']
          });
        });

        // Keyboard support for dots
        $slider.find('.slick-dots [role="tab"]').on('keydown', function (e) {

          var $tabs = $slider.find('.slick-dots [role="tab"]');
          var index = $tabs.index(this);
          var next;

          switch (e.key) {

            case 'ArrowRight':
            case 'ArrowDown':
              e.preventDefault();
              next = (index + 1) % $tabs.length;
              $tabs.eq(next).trigger('click').focus();
              break;

            case 'ArrowLeft':
            case 'ArrowUp':
              e.preventDefault();
              next = (index - 1 + $tabs.length) % $tabs.length;
              $tabs.eq(next).trigger('click').focus();
              break;

            case 'Home':
              e.preventDefault();
              $tabs.eq(0).trigger('click').focus();
              break;

            case 'End':
              e.preventDefault();
              $tabs.eq($tabs.length - 1).trigger('click').focus();
              break;

            case 'Enter':
            case ' ':
            case 'Spacebar':
              e.preventDefault();
              $(this).trigger('click');
              break;
          }

        });

      });

    }
  };

})(jQuery, Drupal);

******************************************************************************
DPM-22794
********************************************************************************
(function ($, Drupal) {

  Drupal.behaviors.slickAccessibilityFix = {
    attach: function (context) {

      $('.slick', context).each(function () {

        var $slider = $(this);

        // Prevent duplicate initialization
        if ($slider.data('slickAccessibilityInitialized')) {
          return;
        }
        $slider.data('slickAccessibilityInitialized', true);

        function updateAccessibility() {

          // Remove unnecessary tabindex from slide containers
          $slider.find('.slick__slide[role="tabpanel"]').removeAttr('tabindex');

          $slider.find('.slick__slide[role="tabpanel"]').each(function () {

            var $slide = $(this);
            var active = $slide.hasClass('slick-active') &&
                         $slide.attr('aria-hidden') === 'false';

            // Manage all focusable elements
            $slide.find('a, button, input, select, textarea, iframe').each(function () {

              if (active) {

                if (this.tagName.toLowerCase() === 'a') {
                  $(this).removeAttr('tabindex');
                } else {
                  $(this).attr('tabindex', '0');
                }

              } else {

                $(this).attr('tabindex', '-1');

              }

            });

          });

          // Update carousel dots
          $slider.find('.slick-dots li').each(function () {

            var $li = $(this);
            var $btn = $li.find('[role="tab"]');

            if (!$btn.length) {
              return;
            }

            if ($li.hasClass('slick-active')) {
              $btn.attr({
                'aria-selected': 'true',
                'tabindex': '0'
              });
            } else {
              $btn.attr({
                'aria-selected': 'false',
                'tabindex': '-1'
              });
            }

          });

          // Remove hidden Previous/Next buttons from tab order
          $slider.find('.slick-prev.visually-hidden, .slick-next.visually-hidden').attr({
            'tabindex': '-1',
            'aria-hidden': 'true'
          });

        }

        // Initial execution
        updateAccessibility();

        // After every slide change
        $slider.on('afterChange', function () {
          setTimeout(updateAccessibility, 50);
        });

        // Keyboard support for carousel dots
        $slider.find('.slick-dots [role="tab"]').on('keydown', function (e) {

          var $tabs = $slider.find('.slick-dots [role="tab"]');
          var index = $tabs.index(this);
          var next;

          switch (e.key) {

            case 'ArrowRight':
            case 'ArrowDown':
              e.preventDefault();
              next = (index + 1) % $tabs.length;
              $tabs.eq(next).trigger('click').focus();
              break;

            case 'ArrowLeft':
            case 'ArrowUp':
              e.preventDefault();
              next = (index - 1 + $tabs.length) % $tabs.length;
              $tabs.eq(next).trigger('click').focus();
              break;

            case 'Home':
              e.preventDefault();
              $tabs.eq(0).trigger('click').focus();
              break;

            case 'End':
              e.preventDefault();
              $tabs.eq($tabs.length - 1).trigger('click').focus();
              break;

            case 'Enter':
            case ' ':
              e.preventDefault();
              $(this).trigger('click');
              break;
          }

        });

      });

    }
  };

})(jQuery, Drupal);
****************************************************************************
DPM-22794
********************************************************************************
(function ($, Drupal) {

  Drupal.behaviors.slickAccessibilityFix = {
    attach: function (context) {

      $('.slick', context).once('slickAccessibilityFix').each(function () {

        var $slider = $(this);

        function updateAccessibility() {

          // Remove unnecessary tabindex from all slide containers
          $slider.find('.slick__slide[role="tabpanel"]').removeAttr('tabindex');

          $slider.find('.slick__slide[role="tabpanel"]').each(function () {

            var $slide = $(this);
            var active = $slide.hasClass('slick-active') &&
                         $slide.attr('aria-hidden') === 'false';

            // Manage focusable elements
            $slide.find('a, button, iframe, input, select, textarea').each(function () {

              if (active) {

                if (this.tagName.toLowerCase() === 'a') {
                  $(this).removeAttr('tabindex');
                } else {
                  this.tabIndex = 0;
                }

              } else {

                this.tabIndex = -1;

              }

            });

          });

          // Update dot buttons
          $slider.find('.slick-dots li').each(function () {

            var $li = $(this);
            var $btn = $li.find('[role="tab"]');

            if (!$btn.length) {
              return;
            }

            if ($li.hasClass('slick-active')) {
              $btn.attr({
                'aria-selected': 'true',
                'tabindex': '0'
              });
            } else {
              $btn.attr({
                'aria-selected': 'false',
                'tabindex': '-1'
              });
            }

          });

        }

        // Initial run
        updateAccessibility();

        // Run after Slick changes slides
        $slider.on('afterChange', function () {
          setTimeout(updateAccessibility, 50);
        });

        // Keyboard support for carousel dots
        $slider.find('.slick-dots [role="tab"]').on('keydown', function (e) {

          var $tabs = $slider.find('.slick-dots [role="tab"]');
          var index = $tabs.index(this);
          var next;

          switch (e.key) {

            case 'ArrowRight':
              e.preventDefault();
              next = (index + 1) % $tabs.length;
              $tabs.eq(next).trigger('click').focus();
              break;

            case 'ArrowLeft':
              e.preventDefault();
              next = (index - 1 + $tabs.length) % $tabs.length;
              $tabs.eq(next).trigger('click').focus();
              break;

            case 'Home':
              e.preventDefault();
              $tabs.eq(0).trigger('click').focus();
              break;

            case 'End':
              e.preventDefault();
              $tabs.eq($tabs.length - 1).trigger('click').focus();
              break;
          }

        });

      });

    }
  };

})(jQuery, Drupal);


*****************************************************************************************


(function ($, Drupal, once) {
  Drupal.behaviors.verticalTabsAccessibility = {
    attach: function (context) {

      once('verticalTabsAccessibility', '[role="tablist"]', context).forEach(function (tablist) {

        // Label the tablist
        const heading = tablist.parentElement.querySelector('h2');

        if (heading) {
          if (!heading.id) {
            heading.id = 'tablist-heading-' + Math.random().toString(36).substr(2, 9);
          }
          tablist.setAttribute('aria-labelledby', heading.id);
        }

        const tabs = Array.from(tablist.querySelectorAll('[role="tab"]'));

        if (!tabs.length) return;

        function activateTab(tab, focusTab) {

          tabs.forEach(function (t) {
            t.setAttribute('aria-selected', 'false');
            t.setAttribute('tabindex', '-1');
            t.classList.remove('active');
          });

          tab.setAttribute('aria-selected', 'true');
          tab.setAttribute('tabindex', '0');
          tab.classList.add('active');

          // Bootstrap Tab
          if (window.bootstrap && bootstrap.Tab) {
            bootstrap.Tab.getOrCreateInstance(tab).show();
          } else {
            tab.click();
          }

          // Update panel if present
          const panelId = tab.getAttribute('aria-controls');

          if (panelId) {
            const panel = document.getElementById(panelId);

            if (panel) {
              panel.setAttribute('role', 'tabpanel');
              panel.setAttribute('aria-labelledby', tab.id);

              if (!panel.hasAttribute('tabindex')) {
                panel.tabIndex = 0;
              }
            }
          }

          if (focusTab) {
            tab.focus();
          }
        }

        tabs.forEach(function (tab) {

          tab.setAttribute(
            'tabindex',
            tab.getAttribute('aria-selected') === 'true' ? '0' : '-1'
          );

          tab.addEventListener('click', function () {
            activateTab(tab, false);
          });

          tab.addEventListener('keydown', function (e) {

            const current = tabs.indexOf(tab);
            let next = current;

            switch (e.key) {

              case 'ArrowDown':
              case 'ArrowRight':
                e.preventDefault();
                next = (current + 1) % tabs.length;
                activateTab(tabs[next], true);
                break;

              case 'ArrowUp':
              case 'ArrowLeft':
                e.preventDefault();
                next = (current - 1 + tabs.length) % tabs.length;
                activateTab(tabs[next], true);
                break;

              case 'Home':
                e.preventDefault();
                activateTab(tabs[0], true);
                break;

              case 'End':
                e.preventDefault();
                activateTab(tabs[tabs.length - 1], true);
                break;
            }

          });

        });

      });

    }
  };
})(jQuery, Drupal, once);

**********************************************************************

Investigated the issue and implemented keyboard accessibility for the vertical tablist as per WCAG/WAI-ARIA Authoring Practices. Added support for Tab, Arrow Up/Down, Home, and End key navigation, while updating aria-selected and tabindex dynamically. Further validation identified that the corresponding tabpanel elements referenced by aria-controls are not present in the current DOM, which must be available in the markup to fully satisfy the accessibility requirements.
**********************************************************************************************
DPM-22793
**********************************************************************************************

The error confirms that the tab panels (`#419796sendmoney-pane`, etc.) are **not present in the DOM** when your script runs. So the JavaScript should **not depend on them**. Below is a WCAG-compliant solution that:

* ✅ Supports **Tab** key (only the active tab is tabbable).
* ✅ Supports **Arrow Up/Down** (vertical tablist).
* ✅ Supports **Home/End**.
* ✅ Updates `aria-selected` and `tabindex`.
* ✅ Works with Bootstrap Tabs.
* ✅ Doesn't throw an error if the tab panel doesn't exist yet.
* ✅ Updates the `role="tabpanel"` and `aria-labelledby` if the panel exists.

```javascript
(function () {

    document.querySelectorAll('[role="tablist"]').forEach(function (tablist) {

        // Label the tablist
        const heading = tablist.parentElement.querySelector('h2');

        if (heading) {
            if (!heading.id) {
                heading.id = 'tablist-heading-' + Math.random().toString(36).substr(2, 9);
            }
            tablist.setAttribute('aria-labelledby', heading.id);
        }

        const tabs = Array.from(tablist.querySelectorAll('[role="tab"]'));

        if (!tabs.length) return;

        function activateTab(tab, focusTab) {

            tabs.forEach(function (t) {

                t.setAttribute('aria-selected', 'false');
                t.setAttribute('tabindex', '-1');
                t.classList.remove('active');

            });

            tab.setAttribute('aria-selected', 'true');
            tab.setAttribute('tabindex', '0');
            tab.classList.add('active');

            // Bootstrap Tab
            if (window.bootstrap && bootstrap.Tab) {
                bootstrap.Tab.getOrCreateInstance(tab).show();
            } else {
                tab.click();
            }

            // Update panel if present
            const panelId = tab.getAttribute('aria-controls');

            if (panelId) {

                const panel = document.getElementById(panelId);

                if (panel) {
                    panel.setAttribute('role', 'tabpanel');
                    panel.setAttribute('aria-labelledby', tab.id);
                }

            }

            if (focusTab) {
                tab.focus();
            }

        }

        tabs.forEach(function (tab) {

            // Initial tabindex
            tab.setAttribute(
                'tabindex',
                tab.getAttribute('aria-selected') === 'true'
                    ? '0'
                    : '-1'
            );

            // Initialize panel if it exists
            const panelId = tab.getAttribute('aria-controls');

            if (panelId) {

                const panel = document.getElementById(panelId);

                if (panel) {

                    panel.setAttribute('role', 'tabpanel');
                    panel.setAttribute('aria-labelledby', tab.id);

                    if (!panel.hasAttribute('tabindex')) {
                        panel.tabIndex = 0;
                    }

                }

            }

            tab.addEventListener('click', function () {
                activateTab(tab, false);
            });

            tab.addEventListener('keydown', function (e) {

                const current = tabs.indexOf(tab);

                let next = current;

                switch (e.key) {

                    case 'ArrowDown':
                        e.preventDefault();
                        next = (current + 1) % tabs.length;
                        activateTab(tabs[next], true);
                        break;

                    case 'ArrowUp':
                        e.preventDefault();
                        next = (current - 1 + tabs.length) % tabs.length;
                        activateTab(tabs[next], true);
                        break;

                    case 'ArrowRight':
                        e.preventDefault();
                        next = (current + 1) % tabs.length;
                        activateTab(tabs[next], true);
                        break;

                    case 'ArrowLeft':
                        e.preventDefault();
                        next = (current - 1 + tabs.length) % tabs.length;
                        activateTab(tabs[next], true);
                        break;

                    case 'Home':
                        e.preventDefault();
                        activateTab(tabs[0], true);
                        break;

                    case 'End':
                        e.preventDefault();
                        activateTab(tabs[tabs.length - 1], true);
                        break;
                }

            });

        });

    });

})();
```

### One important note

From the HTML you posted, the **desktop tab panels are missing**. A Bootstrap tab component should have something like:

```html
<div class="tab-content">
    <div id="419796sendmoney-pane" class="tab-pane">...</div>
    <div id="419796receivemoney-pane" class="tab-pane">...</div>
    ...
</div>
```

Without those elements, the Accessibility Scanner will still report **missing `role="tabpanel"`**, because JavaScript cannot add attributes to elements that don't exist.

If this is a **Drupal/Bootstrap page**, the missing HTML is probably in another template file.

If your goal is to **pass the entire DPM-22793 accessibility ticket**, I can provide a **single JavaScript file** that also dynamically creates any missing ARIA relationships and fully follows the WAI-ARIA Authoring Practices for Tabs. That version is suitable for production and accessibility testing.



***************************************************************************************************************




Here are a few LinkedIn post options you can use with your certificate:

Option 1 (Professional)

🎉 Excited to share that I have successfully earned a Certificate of Participation in Semicolons 2026 by Persistent.

It was a great opportunity to learn, collaborate, and enhance my AI knowledge. Looking forward to applying these learnings to future projects and continuing my growth in technology.

Thank you, Persistent, for this wonderful opportunity!

#Persistent #Semicolons2026 #AI #Learning #Technology #ProfessionalGrowth

⸻

Option 2 (Short & Simple)

Happy to share that I have received my Certificate of Participation for Semicolons 2026 by Persistent.

Grateful for the opportunity to learn, explore AI, and be part of this amazing experience.

#Persistent #Semicolons2026 #AI #Learning #Growth

⸻

Option 3 (More Engaging)

Thrilled to share my Certificate of Participation from Persistent’s Semicolons 2026! 🚀

This experience gave me valuable insights into AI, innovation, and teamwork. Every learning opportunity helps me grow professionally, and I’m excited to continue building my skills.

A big thank you to Persistent and everyone involved in organizing this event!

#Persistent #Semicolons2026 #ArtificialIntelligence #CareerGrowth #ContinuousLearning #Innovation



***************************************************************************************************
DPM-22553
***************************************************************************************************
(function () {

  if (window.decorativeImagesAccessibilityFixed) return;
  window.decorativeImagesAccessibilityFixed = true;

  function fixDecorativeImages() {

    document.querySelectorAll('img').forEach(function (img) {

      // Skip meaningful images
      if (img.closest('[role="img"]')) return;

      // Button arrows
      if (img.classList.contains('button-arrow')) {
        img.setAttribute('alt', '');
        img.setAttribute('aria-hidden', 'true');
        img.setAttribute('role', 'presentation');
        return;
      }

      // Images already marked decorative
      if (img.getAttribute('alt') === '') {
        img.setAttribute('aria-hidden', 'true');
        img.setAttribute('role', 'presentation');
      }

    });

    // Decorative inline SVGs
    document.querySelectorAll('svg').forEach(function (svg) {

      if (
        svg.closest('button') ||
        svg.closest('a') ||
        svg.classList.contains('button-arrow')
      ) {
        svg.setAttribute('aria-hidden', 'true');
        svg.setAttribute('focusable', 'false');
        svg.setAttribute('role', 'presentation');
      }

    });

  }

  fixDecorativeImages();

  new MutationObserver(fixDecorativeImages).observe(document.body, {
    childList: true,
    subtree: true
  });

})();

***************************************************************************************************
***************************************************************************************************
***************************************************************************

(function () {

  if (window.resourceAccessibilityInitialized) return;
  window.resourceAccessibilityInitialized = true;

  // Focus styles
  const style = document.createElement('style');
  style.innerHTML = `
    .a11y-focus {
      outline: none !important;
    }

    .a11y-focus:focus:not(:focus-visible) {
      outline: none !important;
    }

    .a11y-focus:focus-visible {
      outline: 3px solid #000 !important;
      outline-offset: 2px !important;
      border-radius: 4px !important;
    }
  `;
  document.head.appendChild(style);

  function openDropdown(dropdown, trigger, menu) {
    dropdown.classList.add('w--open');
    menu.classList.add('w--open');
    menu.style.display = 'block';
    trigger.setAttribute('aria-expanded', 'true');
  }

  function closeDropdown(dropdown, trigger, menu) {
    dropdown.classList.remove('w--open');
    menu.classList.remove('w--open');
    menu.style.display = 'none';
    trigger.setAttribute('aria-expanded', 'false');
  }

  function initDropdown(dropdown) {

    const trigger = dropdown.querySelector('.resource-dropdown-toggle');
    const menu = dropdown.querySelector('.resource-dropdown-navigation');

    if (!trigger || !menu) return;

    trigger.classList.add('a11y-focus');
    trigger.setAttribute('role', 'button');
    trigger.setAttribute('tabindex', '0');

    const labels = menu.querySelectorAll('.filter-button-option');

    labels.forEach(label => {

      const radio = label.querySelector('input[type="radio"]');

      if (!radio) return;

      label.classList.add('a11y-focus');
      label.setAttribute('tabindex', '0');

      label.addEventListener('click', () => {

        setTimeout(() => {
          closeDropdown(dropdown, trigger, menu);
          trigger.focus();
        }, 300);

      });

      label.addEventListener('keydown', e => {

        switch (e.key) {

          case 'Enter':
          case ' ':
            e.preventDefault();
            label.click();
            break;

          case 'Escape':
            e.preventDefault();
            closeDropdown(dropdown, trigger, menu);
            trigger.focus();
            break;
        }

      });

    });

    trigger.addEventListener('keydown', e => {

      if (e.key === 'Enter' || e.key === ' ') {

        e.preventDefault();

        const expanded =
          trigger.getAttribute('aria-expanded') === 'true';

        if (expanded) {

          closeDropdown(dropdown, trigger, menu);

        } else {

          openDropdown(dropdown, trigger, menu);

          const firstOption =
            menu.querySelector('.filter-button-option');

          if (firstOption) {
            firstOption.focus();
          }

        }

      }

    });

  }

  // Initialize dropdowns
  document
    .querySelectorAll('.resource-filter-dropdown')
    .forEach(initDropdown);

  function initAppliedFilters() {

    // Remove filter buttons (.div-block-24)
    document
      .querySelectorAll('.div-block-24')
      .forEach(btn => {

        if (btn.dataset.a11yInitialized) return;
        btn.dataset.a11yInitialized = 'true';

        btn.classList.add('a11y-focus');
        btn.setAttribute('role', 'button');
        btn.setAttribute('tabindex', '0');

        const tag = btn.closest('[fs-list-element="tag"]');

        if (tag) {

          const field =
            tag.querySelector('[fs-list-element="tag-field"]')
              ?.textContent.trim() || '';

          const value =
            tag.querySelector('[fs-list-element="tag-value"]')
              ?.textContent.trim() || '';

          btn.setAttribute(
            'aria-label',
            `Remove filter ${field}: ${value}`
          );

        }

        const svg = btn.querySelector('svg');

        if (svg) {
          svg.setAttribute('aria-hidden', 'true');
          svg.setAttribute('focusable', 'false');
        }

        btn.addEventListener('keydown', e => {

          if (e.key === 'Enter' || e.key === ' ') {

            e.preventDefault();
            btn.click();

          }

        });

      });

    // Clear filters button
    document
      .querySelectorAll('[fs-list-element="clear"]')
      .forEach(btn => {

        if (btn.dataset.a11yInitialized) return;
        btn.dataset.a11yInitialized = 'true';

        btn.classList.add('a11y-focus');
        btn.setAttribute('role', 'button');
        btn.setAttribute('tabindex', '0');
        btn.setAttribute('aria-label', 'Clear all filters');

        btn.addEventListener('keydown', e => {

          if (e.key === 'Enter' || e.key === ' ') {

            e.preventDefault();
            btn.click();

          }

        });

      });

  }

  // Initial run
  initAppliedFilters();

  // Watch for Finsweet re-rendering filters
  const observer = new MutationObserver(() => {
    initAppliedFilters();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

})();

****************************************************************

DPM-22544
(function () {

  if (window.resourceAccessibilityInitialized) return;
  window.resourceAccessibilityInitialized = true;

  // Focus styles
  const style = document.createElement('style');
  style.innerHTML = `
    .a11y-focus {
      outline: none !important;
    }

    .a11y-focus:focus:not(:focus-visible) {
      outline: none !important;
    }

    .a11y-focus:focus-visible {
      outline: 3px solid #000 !important;
      outline-offset: 2px !important;
      border-radius: 4px !important;
    }
  `;
  document.head.appendChild(style);

  function openDropdown(dropdown, trigger, menu) {
    dropdown.classList.add('w--open');
    menu.classList.add('w--open');
    menu.style.display = 'block';
    trigger.setAttribute('aria-expanded', 'true');
  }

  function closeDropdown(dropdown, trigger, menu) {
    dropdown.classList.remove('w--open');
    menu.classList.remove('w--open');
    menu.style.display = 'none';
    trigger.setAttribute('aria-expanded', 'false');
  }

  function initDropdown(dropdown) {

    const trigger = dropdown.querySelector('.resource-dropdown-toggle');
    const menu = dropdown.querySelector('.resource-dropdown-navigation');

    if (!trigger || !menu) return;

    trigger.classList.add('a11y-focus');
    trigger.setAttribute('role', 'button');
    trigger.setAttribute('tabindex', '0');

    const labels = menu.querySelectorAll('.filter-button-option');

    labels.forEach(label => {

      const radio = label.querySelector('input[type="radio"]');

      if (!radio) return;

      label.classList.add('a11y-focus');
      label.setAttribute('tabindex', '0');

      // Mouse click
      label.addEventListener('click', () => {

        setTimeout(() => {

          closeDropdown(dropdown, trigger, menu);

          trigger.focus();

        }, 300);

      });

      // Keyboard support
      label.addEventListener('keydown', e => {

        switch (e.key) {

          case 'Enter':
          case ' ':

            e.preventDefault();

            // Let Finsweet handle the filter
            label.click();

            break;

          case 'Escape':

            e.preventDefault();

            closeDropdown(dropdown, trigger, menu);

            trigger.focus();

            break;
        }

      });

    });

    // Open/Close dropdown
    trigger.addEventListener('keydown', e => {

      if (e.key === 'Enter' || e.key === ' ') {

        e.preventDefault();

        const expanded =
          trigger.getAttribute('aria-expanded') === 'true';

        if (expanded) {

          closeDropdown(dropdown, trigger, menu);

        } else {

          openDropdown(dropdown, trigger, menu);

          const firstOption =
            menu.querySelector('.filter-button-option');

          if (firstOption) {
            firstOption.focus();
          }
        }
      }
    });

  }

  // Initialize dropdowns
  document
    .querySelectorAll('.resource-filter-dropdown')
    .forEach(initDropdown);

  // Applied filter remove buttons
  document
    .querySelectorAll('[fs-list-element="tag-remove"]')
    .forEach(btn => {

      btn.classList.add('a11y-focus');
      btn.setAttribute('role', 'button');
      btn.setAttribute('tabindex', '0');

      btn.addEventListener('keydown', e => {

        if (e.key === 'Enter' || e.key === ' ') {

          e.preventDefault();
          btn.click();

        }

      });

    });

  // Clear filters button
  document
    .querySelectorAll('[fs-list-element="clear"]')
    .forEach(btn => {

      btn.classList.add('a11y-focus');
      btn.setAttribute('role', 'button');
      btn.setAttribute('tabindex', '0');

      btn.addEventListener('keydown', e => {

        if (e.key === 'Enter' || e.key === ' ') {

          e.preventDefault();
          btn.click();

        }

      });

    });

})();

*****************************************************************************************************


DPM-22544
(function () {

  function initAccessibility() {

    // ==========================
    // Clear All Filters
    // ==========================
    document
      .querySelectorAll('[fs-list-element="clear"]')
      .forEach(btn => {

        btn.setAttribute('role', 'button');
        btn.setAttribute('tabindex', '0');
        btn.setAttribute('aria-label', 'Clear all filters');

        btn.addEventListener('keydown', function (e) {

          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            this.click();
          }
        });
      });

    // ==========================
    // Applied Filter Remove Buttons
    // ==========================
    document
      .querySelectorAll('[fs-list-element="tag-remove"]')
      .forEach(removeBtn => {

        removeBtn.setAttribute('role', 'button');
        removeBtn.setAttribute('tabindex', '0');

        const tag = removeBtn.closest('[fs-list-element="tag"]');

        const value =
          tag?.querySelector('[fs-list-element="tag-value"]')
            ?.textContent
            ?.trim();

        if (value) {
          removeBtn.setAttribute(
            'aria-label',
            'Remove filter ' + value
          );
        }

        removeBtn.addEventListener('keydown', function (e) {

          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            this.click();
          }
        });
      });

    // ==========================
    // Dropdown Toggle Accessibility
    // ==========================
    document
      .querySelectorAll('.resource-dropdown-toggle')
      .forEach(toggle => {

        toggle.setAttribute('role', 'button');
        toggle.setAttribute('tabindex', '0');

        toggle.addEventListener('keydown', function (e) {

          if (
            e.key === 'Enter' ||
            e.key === ' '
          ) {

            e.preventDefault();

            this.click();

            setTimeout(() => {

              const menuId =
                this.getAttribute('aria-controls');

              const menu =
                document.getElementById(menuId);

              if (!menu) return;

              const firstOption =
                menu.querySelector(
                  'input[type="radio"]'
                );

              if (firstOption) {
                firstOption.focus();
              }

            }, 150);
          }

          // Down Arrow opens dropdown
          if (e.key === 'ArrowDown') {

            e.preventDefault();

            this.click();

            setTimeout(() => {

              const menu =
                document.getElementById(
                  this.getAttribute('aria-controls')
                );

              const firstOption =
                menu?.querySelector(
                  'input[type="radio"]'
                );

              if (firstOption) {
                firstOption.focus();
              }

            }, 150);
          }
        });
      });

    // ==========================
    // Radio Buttons
    // ==========================
    document
      .querySelectorAll(
        '.resource-dropdown-navigation input[type="radio"]'
      )
      .forEach(radio => {

        radio.setAttribute('tabindex', '0');

        radio.addEventListener('keydown', function (e) {

          const radios =
            Array.from(
              document.querySelectorAll(
                'input[name="' + this.name + '"]'
              )
            );

          const currentIndex =
            radios.indexOf(this);

          // Select with Enter/Space
          if (
            e.key === 'Enter' ||
            e.key === ' '
          ) {

            e.preventDefault();

            this.checked = true;

            this.dispatchEvent(
              new Event('change', {
                bubbles: true
              })
            );
          }

          // Arrow Down
          if (e.key === 'ArrowDown') {

            e.preventDefault();

            const next =
              radios[currentIndex + 1];

            if (next) {
              next.focus();
            }
          }

          // Arrow Up
          if (e.key === 'ArrowUp') {

            e.preventDefault();

            const prev =
              radios[currentIndex - 1];

            if (prev) {
              prev.focus();
            }
          }

          // Escape closes dropdown
          if (e.key === 'Escape') {

            const dropdown =
              this.closest('.w-dropdown-list');

            const toggle =
              document.getElementById(
                dropdown?.getAttribute('aria-labelledby')
              );

            if (toggle) {
              toggle.focus();
              toggle.click();
            }
          }
        });
      });
  }

  initAccessibility();

  // Reapply after filtering updates
  const observer = new MutationObserver(() => {
    initAccessibility();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

})();






*************************************************************************************************************************
DPM-22552
*************************************************************************************************************************

For the HTML you provided, the tabs are currently just `<div>` elements with no tab semantics. The following **Drupal JS Injector** code will add all required ARIA roles, states, and relationships to meet the acceptance criteria.

```javascript
(function () {

  function initAccessibleTabs() {

    const tabList = document.querySelector('.tabs-pagination');

    if (!tabList || tabList.dataset.tabsA11yApplied) {
      return;
    }

    tabList.dataset.tabsA11yApplied = 'true';

    /* ---------------------------
       TABLIST
    ---------------------------- */

    tabList.setAttribute('role', 'tablist');
    tabList.setAttribute('aria-label', 'Industry Categories');

    const tabs = tabList.querySelectorAll('.category-tab');

    tabs.forEach(function (tab, index) {

      const slideIndex = tab.getAttribute('data-slide');

      const label =
        tab.querySelector('.category-tab-label')?.textContent.trim() ||
        ('Tab ' + (index + 1));

      const tabId = 'industry-tab-' + slideIndex;
      const panelId = 'industry-panel-' + slideIndex;

      /* ---------------------------
         TAB
      ---------------------------- */

      tab.setAttribute('role', 'tab');
      tab.setAttribute('id', tabId);
      tab.setAttribute('aria-controls', panelId);
      tab.setAttribute('tabindex', '-1');

      const isSelected =
        tab.classList.contains('is-active');

      tab.setAttribute(
        'aria-selected',
        isSelected ? 'true' : 'false'
      );

      if (isSelected) {
        tab.setAttribute('tabindex', '0');
      }

      /* ---------------------------
         PANEL
      ---------------------------- */

      const slide = document.querySelector(
        '.swiper-slide[aria-label^="' + (Number(slideIndex) + 1) + ' /"]'
      );

      if (slide) {

        slide.setAttribute('role', 'tabpanel');
        slide.setAttribute('id', panelId);
        slide.setAttribute('aria-labelledby', tabId);

        if (isSelected) {
          slide.removeAttribute('hidden');
        } else {
          slide.setAttribute('hidden', '');
        }
      }

      /* ---------------------------
         CLICK SUPPORT
      ---------------------------- */

      tab.addEventListener('click', function () {

        updateTabs(tabList);

      });

      /* ---------------------------
         KEYBOARD SUPPORT
      ---------------------------- */

      tab.addEventListener('keydown', function (e) {

        const currentIndex = [...tabs].indexOf(tab);

        let nextIndex = null;

        switch (e.key) {

          case 'ArrowRight':
          case 'ArrowDown':
            nextIndex = (currentIndex + 1) % tabs.length;
            break;

          case 'ArrowLeft':
          case 'ArrowUp':
            nextIndex = (currentIndex - 1 + tabs.length) % tabs.length;
            break;

          case 'Home':
            nextIndex = 0;
            break;

          case 'End':
            nextIndex = tabs.length - 1;
            break;

          default:
            return;
        }

        e.preventDefault();

        tabs[nextIndex].focus();
        tabs[nextIndex].click();

      });

    });

    observeActiveTab(tabList);

  }

  function updateTabs(tabList) {

    const tabs = tabList.querySelectorAll('.category-tab');

    tabs.forEach(function (tab) {

      const selected =
        tab.classList.contains('is-active');

      tab.setAttribute(
        'aria-selected',
        selected ? 'true' : 'false'
      );

      tab.setAttribute(
        'tabindex',
        selected ? '0' : '-1'
      );

      const panelId = tab.getAttribute('aria-controls');

      const panel = document.getElementById(panelId);

      if (panel) {

        if (selected) {
          panel.removeAttribute('hidden');
        } else {
          panel.setAttribute('hidden', '');
        }

      }

    });

  }

  function observeActiveTab(tabList) {

    const observer = new MutationObserver(function () {

      updateTabs(tabList);

    });

    tabList.querySelectorAll('.category-tab').forEach(function (tab) {

      observer.observe(tab, {
        attributes: true,
        attributeFilter: ['class']
      });

    });

  }

  initAccessibleTabs();

  new MutationObserver(initAccessibleTabs).observe(
    document.body,
    {
      childList: true,
      subtree: true
    }
  );

})();
```

### What this fixes

✅ `role="tablist"` on `.tabs-pagination`

✅ `role="tab"` on each `.category-tab`

✅ `role="tabpanel"` on corresponding `.swiper-slide`

✅ `aria-controls` on every tab

✅ `aria-labelledby` on every panel

✅ `aria-selected="true"` only on active tab

✅ `aria-selected="false"` on inactive tabs

✅ Proper roving tabindex (`0` for selected tab, `-1` for others)

✅ Arrow key navigation (Left/Right/Up/Down)

✅ Home/End key support

✅ Updates automatically when `.is-active` changes

This implementation aligns with the WCAG/EAP tab pattern requirements listed in your acceptance criteria.

*************************************************************************************************************************
*************************************************************************************************************************


*************************************************************************************************************************
DPM - 22551
*************************************************************************************************************************
Based on the HTML you provided, this is a **Swiper carousel** that currently has:

* `role="list"` on `.swiper-wrapper`
* `role="group"` on slides
* Missing `aria-roledescription="carousel"`
* Missing carousel label
* Missing slide labels based on actual card title
* Missing `aria-hidden` management for inactive slides
* Missing live region settings

Use the following **Drupal JS Injector** code to meet the accessibility acceptance criteria:

```javascript
(function () {

  function initAccessibleCarousel() {

    document.querySelectorAll('.tabs-with-cards-swipper-wrapper').forEach(function (carousel, index) {

      if (carousel.dataset.a11yProcessed) {
        return;
      }

      carousel.dataset.a11yProcessed = 'true';

      /* --------------------------
         Carousel Container
      --------------------------- */

      carousel.setAttribute('role', 'region');
      carousel.setAttribute('aria-roledescription', 'carousel');

      const activeTitle =
        carousel.querySelector('.swiper-slide-active .big-cta-card-titel');

      const carouselLabel =
        activeTitle ?
        activeTitle.textContent.trim() + ' Solutions' :
        'Industry Solutions';

      carousel.setAttribute('aria-label', carouselLabel);

      carousel.setAttribute('aria-live', 'polite');
      carousel.setAttribute('aria-atomic', 'false');

      /* --------------------------
         Slides
      --------------------------- */

      const slides = carousel.querySelectorAll('.swiper-slide');

      slides.forEach(function (slide, slideIndex) {

        slide.setAttribute('role', 'group');
        slide.setAttribute('aria-roledescription', 'slide');

        const title = slide.querySelector('.big-cta-card-titel');

        const slideName = title
          ? title.textContent.trim()
          : 'Item ' + (slideIndex + 1);

        slide.setAttribute(
          'aria-label',
          slideName + ' (' + (slideIndex + 1) + ' of ' + slides.length + ')'
        );

        if (
          slide.classList.contains('swiper-slide-active')
        ) {
          slide.setAttribute('aria-hidden', 'false');
        } else {
          slide.setAttribute('aria-hidden', 'true');
        }
      });

      /* --------------------------
         Observe Active Slide Changes
      --------------------------- */

      const observer = new MutationObserver(function () {

        slides.forEach(function (slide) {

          if (
            slide.classList.contains('swiper-slide-active')
          ) {

            slide.setAttribute('aria-hidden', 'false');

            const title = slide.querySelector('.big-cta-card-titel');

            if (title) {
              carousel.setAttribute(
                'aria-label',
                title.textContent.trim() + ' Solutions'
              );
            }

          } else {

            slide.setAttribute('aria-hidden', 'true');

          }

        });

      });

      slides.forEach(function (slide) {

        observer.observe(slide, {
          attributes: true,
          attributeFilter: ['class']
        });

      });

    });

  }

  initAccessibleCarousel();

  new MutationObserver(initAccessibleCarousel)
    .observe(document.body, {
      childList: true,
      subtree: true
    });

})();
```

### This fixes

✅ `role="region"` on carousel container
✅ `aria-roledescription="carousel"`
✅ Accessible carousel name using visible heading
✅ `role="group"` on each slide
✅ `aria-roledescription="slide"` on each slide
✅ Slide label like:

```html
aria-label="Financial Institutions (1 of 6)"
```

✅ `aria-hidden="false"` only on active slide
✅ `aria-hidden="true"` on inactive slides
✅ `aria-live="polite"`
✅ `aria-atomic="false"`
✅ Automatically updates when Swiper changes slides

This should satisfy the CERTOS acceptance criteria for **"Ensure custom controls provide proper name, role, and state information"** for the carousel portion.


*************************************************************************************************************************

*************************************************************************************************************************







DPM-20920

(function (Drupal) {

  Drupal.behaviors.ampAccessibilityFix = {
    attach: function (context) {

      if (context !== document) {
        return;
      }

      // Hide cloned slides from AT and keyboard.
      document.querySelectorAll('.slick-cloned').forEach(function (slide) {

        slide.setAttribute('aria-hidden', 'true');

        slide.querySelectorAll(
          'a, button, input, select, textarea, iframe, [tabindex]'
        ).forEach(function (el) {
          el.setAttribute('tabindex', '-1');
        });
      });

      // Email link.
      const emailLink = document.querySelector(
        'a[href^="mailto:reportphishing@apwg.org"]'
      );

      // First visible video in Related Videos carousel.
      const firstVideo =
        document.querySelector(
          '.paragraph--type--video-carousel .slick-slide.slick-current iframe'
        ) ||
        document.querySelector(
          '.paragraph--type--video-carousel .slick-slide.slick-active iframe'
        ) ||
        document.querySelector(
          '.paragraph--type--video-carousel iframe'
        );

      if (!emailLink || !firstVideo) {
        return;
      }

      firstVideo.setAttribute('tabindex', '0');

      // Move focus directly to video.
      emailLink.addEventListener('keydown', function (e) {

        if (e.key === 'Tab' && !e.shiftKey) {
          e.preventDefault();
          firstVideo.focus();
        }

      });

    }
  };

})(Drupal);




Normal JS

(function () {

  // Hide cloned/hidden slides from keyboard and screen readers
  document.querySelectorAll('.slick-cloned').forEach(slide => {
    slide.setAttribute('aria-hidden', 'true');

    slide.querySelectorAll(
      'a, button, input, select, textarea, iframe, [tabindex]'
    ).forEach(el => {
      el.setAttribute('tabindex', '-1');
    });
  });

  // Find APWG email link
  const emailLink = document.querySelector(
    'a[href^="mailto:reportphishing@apwg.org"]'
  );

  // First visible YouTube video in Related Videos section
  const firstVisibleVideo = document.querySelector(
    '.slick-slide.slick-current iframe'
  );

  if (!emailLink || !firstVisibleVideo) {
    console.log('Email link or video not found');
    return;
  }

  firstVisibleVideo.setAttribute('tabindex', '0');

  // Force focus from email link directly to video
  emailLink.addEventListener('keydown', function (e) {
    if (e.key === 'Tab' && !e.shiftKey) {
      e.preventDefault();
      firstVisibleVideo.focus();
    }
  });

  console.log(
    'Accessibility fix applied: hidden slides removed from tab order and focus moves from reportphishing@apwg.org to first visible YouTube video.'
  );

})();



*******************************************************************************
DPM -22393

(function (Drupal) {

  Drupal.behaviors.amp29AccessibilityFix = {
    attach(context) {

      // Process each paragraph content once.
      context.querySelectorAll('.paragraph-content:not([data-amp29-fixed])')
        .forEach(section => {

          section.setAttribute('data-amp29-fixed', 'true');

          const heading = section.querySelector(
            '.paragraph-title, .paragraph-subtitle'
          );

          const headingText = heading
            ? heading.textContent.replace(/\s+/g, ' ').trim()
            : '';

          section.querySelectorAll('.paragraph-cta a').forEach(link => {

            const visibleLabel = link.textContent
              .replace(/\s+/g, ' ')
              .trim();

            // =====================================
            // Shape what's next in financial trust
            // Learn More
            // =====================================
            if (
              visibleLabel === 'Learn More' &&
              headingText.includes("Shape what's next in financial trust")
            ) {

              link.setAttribute(
                'aria-label',
                'Learn More about careers at Early Warning'
              );
            }

            // =====================================
            // Meet Paze
            // Paze.com
            // =====================================
            if (visibleLabel === 'Paze.com') {

              link.setAttribute(
                'aria-label',
                'Paze.com'
              );
            }

            // =====================================
            // Meet Certos
            // Learn More
            // =====================================
            if (
              visibleLabel === 'Learn More' &&
              headingText.toLowerCase().includes('certos')
            ) {

              link.setAttribute(
                'aria-label',
                'Learn More about Certos ℠'
              );
            }

          });
        });

      // =====================================
      // Fix CertosSM pronunciation
      // =====================================

      context.querySelectorAll(
        '.paragraph-title sup, .paragraph-subtitle sup'
      ).forEach(sup => {

        if (
          sup.textContent.trim().toUpperCase() === 'SM' &&
          !sup.hasAttribute('data-certos-fixed')
        ) {

          sup.setAttribute('data-certos-fixed', 'true');

          // Add space before SM if missing.
          const previousNode = sup.previousSibling;

          if (
            previousNode &&
            previousNode.nodeType === Node.TEXT_NODE &&
            !previousNode.textContent.endsWith(' ')
          ) {
            previousNode.textContent += ' ';
          }

          // Improve screen reader announcement.
          sup.setAttribute(
            'aria-label',
            'service mark'
          );
        }

      });

    }
  };

})(Drupal);

*****************************************************************************

(function (Drupal) {

  Drupal.behaviors.wcagLabelInNameFix = {
    attach(context) {

      // Prevent duplicate processing
      context.querySelectorAll('.paragraph-content:not([data-wcag-fixed])')
        .forEach(section => {

          section.setAttribute('data-wcag-fixed', 'true');

          const heading = section.querySelector(
            '.paragraph-title, .paragraph-subtitle'
          );

          const headingText = heading
            ? heading.textContent.replace(/\s+/g, ' ').trim()
            : '';

          section.querySelectorAll('.paragraph-cta a').forEach(link => {

            const visibleText = link.textContent
              .replace(/\s+/g, ' ')
              .trim();

            // ==========================================
            // Shape what's next in financial trust
            // ==========================================
            if (
              visibleText === 'Learn More' &&
              headingText.includes("Shape what's next in financial trust")
            ) {

              link.setAttribute(
                'aria-label',
                'Learn More about careers at Early Warning'
              );
            }

            // ==========================================
            // Meet Paze
            // Reviewer specifically requested that
            // accessible name match visible text
            // ==========================================
            else if (
              visibleText === 'Paze.com'
            ) {

              link.removeAttribute('aria-label');
            }

            // ==========================================
            // Zelle record article
            // ==========================================
            else if (
              visibleText === 'Read More' &&
              headingText.includes('Zelle')
            ) {

              link.setAttribute(
                'aria-label',
                'Read More about Zelle shattering records with $1 trillion sent in a single year'
              );
            }

            // ==========================================
            // About Zelle
            // ==========================================
            else if (
              visibleText.includes('About Zelle')
            ) {

              link.setAttribute(
                'aria-label',
                'About Zelle'
              );
            }

            // ==========================================
            // Certos Learn More
            // ==========================================
            else if (
              visibleText === 'Learn More' &&
              headingText.toLowerCase().includes('certos')
            ) {

              link.setAttribute(
                'aria-label',
                'Learn More about Certos ℠'
              );
            }

          });
        });

      // ==========================================
      // Fix SM pronunciation
      // CertosSM -> Certos SM
      // ==========================================
      context.querySelectorAll(
        '.paragraph-title sup, .paragraph-subtitle sup'
      ).forEach(sup => {

        if (
          sup.textContent.trim().toUpperCase() === 'SM' &&
          !sup.hasAttribute('data-sm-fixed')
        ) {

          sup.setAttribute('data-sm-fixed', 'true');
          sup.setAttribute('aria-label', 'service mark');

          const prev = sup.previousSibling;

          if (
            prev &&
            prev.nodeType === Node.TEXT_NODE &&
            !prev.textContent.endsWith(' ')
          ) {
            prev.textContent += ' ';
          }
        }
      });

    }
  };

})(Drupal);




&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

(() => {

  function initDropdown(dropdown) {

    if (dropdown.dataset.keyboardInit === "true") return;
    dropdown.dataset.keyboardInit = "true";

    const trigger = dropdown.querySelector('.dropdown-selected');
    const listbox = dropdown.querySelector('.dropdown-options');

    if (!trigger || !listbox) return;

    trigger.setAttribute('tabindex', '0');
    trigger.setAttribute('role', 'combobox');
    trigger.setAttribute('aria-haspopup', 'listbox');
    trigger.setAttribute('aria-expanded', 'false');

    let currentIndex = 0;

    function getOptions() {
      return [...listbox.querySelectorAll('.dropdown-option')];
    }

    function updateOptions() {

      const options = getOptions();

      options.forEach((option, index) => {

        option.setAttribute('role', 'option');
        option.tabIndex = index === currentIndex ? 0 : -1;

        if (!option.dataset.keyboardBound) {

          option.dataset.keyboardBound = "true";

          option.addEventListener('keydown', e => {

            const opts = getOptions();

            switch (e.key) {

              case 'ArrowDown':
                e.preventDefault();
                currentIndex =
                  currentIndex < opts.length - 1
                    ? currentIndex + 1
                    : 0;

                updateOptions();
                opts[currentIndex].focus();
                break;

              case 'ArrowUp':
                e.preventDefault();
                currentIndex =
                  currentIndex > 0
                    ? currentIndex - 1
                    : opts.length - 1;

                updateOptions();
                opts[currentIndex].focus();
                break;

              case 'Home':
                e.preventDefault();
                currentIndex = 0;
                updateOptions();
                opts[0].focus();
                break;

              case 'End':
                e.preventDefault();
                currentIndex = opts.length - 1;
                updateOptions();
                opts[currentIndex].focus();
                break;

              case 'Enter':
              case ' ':
                e.preventDefault();
                option.click();
                trigger.focus();
                break;

              case 'Escape':
                e.preventDefault();

                listbox.hidden = true;

                trigger.setAttribute(
                  'aria-expanded',
                  'false'
                );

                trigger.focus();
                break;
            }
          });

          option.addEventListener('click', () => {

            currentIndex = getOptions().indexOf(option);

            getOptions().forEach(opt => {
              opt.setAttribute(
                'aria-selected',
                'false'
              );
            });

            option.setAttribute(
              'aria-selected',
              'true'
            );

            updateOptions();

            listbox.hidden = true;

            trigger.setAttribute(
              'aria-expanded',
              'false'
            );

            trigger.focus();
          });
        }
      });
    }

    updateOptions();

    trigger.addEventListener('keydown', e => {

      const expanded =
        trigger.getAttribute('aria-expanded') === 'true';

      switch (e.key) {

        case 'Enter':
        case ' ':
        case 'ArrowDown':

          e.preventDefault();

          if (!expanded) {

            trigger.click();

            setTimeout(() => {

              updateOptions();

              const options = getOptions();

              if (options.length) {
                options[currentIndex].focus();
              }

            }, 150);
          }

          break;

        case 'Escape':

          if (expanded) {

            e.preventDefault();

            listbox.hidden = true;

            trigger.setAttribute(
              'aria-expanded',
              'false'
            );
          }

          break;
      }
    });

    const observer = new MutationObserver(() => {
      updateOptions();
    });

    observer.observe(listbox, {
      childList: true,
      subtree: true
    });
  }

  function initAllDropdowns() {

    document
      .querySelectorAll('.custom-dropdown')
      .forEach(initDropdown);
  }

  initAllDropdowns();

  new MutationObserver(() => {
    initAllDropdowns();
  }).observe(document.body, {
    childList: true,
    subtree: true
  });

  /* --------------------------
     Accordion Keyboard Support
  --------------------------- */

  document
    .querySelectorAll(
      '[data-value="validate-transfers-and-account-linking-requests"]'
    )
    .forEach(item => {

      item.setAttribute('tabindex', '0');
      item.setAttribute('role', 'button');

      item.addEventListener('keydown', e => {

        if (
          e.key === 'Enter' ||
          e.key === ' '
        ) {

          e.preventDefault();

          item.click();
        }
      });
    });

})();





&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

(() => {

  function initFilterActions() {

    // Remove filter buttons
    document
      .querySelectorAll('[fs-list-element="tag-remove"]')
      .forEach(btn => {

        btn.setAttribute('tabindex', '0');
        btn.setAttribute('role', 'button');

        const filterItem = btn.closest('[fs-list-element="tag"]');

        const field = filterItem
          ?.querySelector('[fs-list-element="tag-field"]')
          ?.textContent
          ?.trim();

        const value = filterItem
          ?.querySelector('[fs-list-element="tag-value"]')
          ?.textContent
          ?.trim();

        if (field && value) {
          btn.setAttribute(
            'aria-label',
            `Remove filter ${field} ${value}`
          );
        }

        btn.addEventListener('keydown', e => {

          if (
            e.key === 'Enter' ||
            e.key === ' '
          ) {

            e.preventDefault();
            btn.click();
          }
        });
      });

    // Clear All Filters button
    document
      .querySelectorAll('[fs-list-element="clear"]')
      .forEach(btn => {

        btn.setAttribute('tabindex', '0');
        btn.setAttribute('role', 'button');

        btn.setAttribute(
          'aria-label',
          'Clear all filters'
        );

        btn.addEventListener('keydown', e => {

          if (
            e.key === 'Enter' ||
            e.key === ' '
          ) {

            e.preventDefault();
            btn.click();
          }
        });
      });
  }

  initFilterActions();

  // Reapply if Finsweet rebuilds the filter tags
  const observer = new MutationObserver(() => {
    initFilterActions();
  });

  const wrapper = document.querySelector('.applied-filters-wrapper');

  if (wrapper) {
    observer.observe(wrapper, {
      childList: true,
      subtree: true
    });
  }

})();


&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

(() => {

    function initDropdown(dropdown) {

        const toggle = dropdown.querySelector('.resource-dropdown-toggle');

        const options = [
            ...dropdown.querySelectorAll('.filter-button-option')
        ];

        if (!toggle || !options.length) return;

        // Remove radios from keyboard navigation
        dropdown.querySelectorAll('.w-radio-input').forEach(radio => {
            radio.tabIndex = -1;
            radio.setAttribute('tabindex', '-1');
            radio.setAttribute('aria-hidden', 'true');
        });

        let currentIndex = options.findIndex(option =>
            option.classList.contains('is-list-active')
        );

        if (currentIndex < 0) currentIndex = 0;

        function updateRovingTabindex() {

            options.forEach((option, index) => {

                option.tabIndex =
                    index === currentIndex ? 0 : -1;

                option.setAttribute(
                    'aria-selected',
                    index === currentIndex ? 'true' : 'false'
                );
            });
        }

        updateRovingTabindex();

        function focusOption(index) {

            currentIndex = index;

            updateRovingTabindex();

            options[index].focus();
        }

        function selectOption(index) {

            currentIndex = index;

            const option = options[index];

            const radio =
                option.querySelector('.w-radio-input');

            options.forEach(opt => {
                opt.classList.remove('is-list-active');
            });

            option.classList.add('is-list-active');

            updateRovingTabindex();

            if (radio && !radio.checked) {

                radio.checked = true;

                radio.dispatchEvent(
                    new Event('change', {
                        bubbles: true
                    })
                );
            }
        }

        options.forEach((option, index) => {

            option.setAttribute('role', 'radio');

            option.addEventListener('keydown', e => {

                switch (e.key) {

                    case 'ArrowDown':
                        e.preventDefault();

                        focusOption(
                            index === options.length - 1
                                ? 0
                                : index + 1
                        );

                        break;

                    case 'ArrowUp':
                        e.preventDefault();

                        focusOption(
                            index === 0
                                ? options.length - 1
                                : index - 1
                        );

                        break;

                    case 'Home':
                        e.preventDefault();
                        focusOption(0);
                        break;

                    case 'End':
                        e.preventDefault();
                        focusOption(options.length - 1);
                        break;

                    case 'Enter':
                    case ' ':
                    case 'Spacebar':
                        e.preventDefault();
                        selectOption(index);
                        break;
                }
            });

            option.addEventListener('click', () => {
                selectOption(index);
            });
        });

        toggle.addEventListener('keydown', e => {

            if (
                e.key === 'Enter' ||
                e.key === ' ' ||
                e.key === 'ArrowDown'
            ) {

                e.preventDefault();

                if (
                    toggle.getAttribute('aria-expanded') === 'false'
                ) {
                    toggle.click();
                }

                setTimeout(() => {
                    options[currentIndex].focus();
                }, 150);
            }
        });

        function handleDropdownState() {

            const expanded =
                toggle.getAttribute('aria-expanded') === 'true';

            options.forEach((option, index) => {

                if (!expanded) {

                    option.tabIndex = -1;

                } else {

                    option.tabIndex =
                        index === currentIndex ? 0 : -1;
                }
            });

            // Ensure radios never get focus
            dropdown.querySelectorAll('.w-radio-input')
                .forEach(radio => {
                    radio.tabIndex = -1;
                    radio.setAttribute('tabindex', '-1');
                });
        }

        handleDropdownState();

        new MutationObserver(handleDropdownState)
            .observe(toggle, {
                attributes: true,
                attributeFilter: ['aria-expanded']
            });
    }

    document
        .querySelectorAll('.resource-filter-dropdown')
        .forEach(initDropdown);

})();


&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


(() => {

  // Remove filter buttons
  document.querySelectorAll('[fs-list-element="tag-remove"]').forEach(btn => {

    btn.setAttribute('tabindex', '0');
    btn.setAttribute('role', 'button');

    // Optional accessible name
    const filterItem = btn.closest('[fs-list-element="tag"]');
    const value = filterItem?.querySelector('[fs-list-element="tag-value"]')?.textContent?.trim();

    if (value) {
      btn.setAttribute('aria-label', `Remove filter ${value}`);
    }

    btn.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        btn.click();
      }
    });

  });

  // Clear all filters button
  document.querySelectorAll('[fs-list-element="clear"]').forEach(btn => {

    btn.setAttribute('tabindex', '0');
    btn.setAttribute('role', 'button');

    btn.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        btn.click();
      }
    });
  });
})();



&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

(() => {

  document.querySelectorAll('.custom-dropdown').forEach(dropdown => {

    const trigger = dropdown.querySelector('.dropdown-selected');

    if (!trigger) return;

    trigger.setAttribute('tabindex', '0');
    trigger.setAttribute('role', 'button');

    trigger.addEventListener('keydown', e => {

      if (
        e.key === 'Enter' ||
        e.key === ' ' ||
        e.key === 'ArrowDown'
      ) {
        e.preventDefault();

        trigger.click();

        setTimeout(() => {

          const options = [
            ...dropdown.querySelectorAll('.dropdown-option')
          ];

          options.forEach(opt => {
            opt.setAttribute('tabindex', '-1');
          });

          if (options.length) {
            options[0].setAttribute('tabindex', '0');
            options[0].focus();
          }

        }, 200);
      }
    });

    dropdown.addEventListener('keydown', e => {

      const active = document.activeElement;

      if (!active.classList.contains('dropdown-option')) return;

      const options = [
        ...dropdown.querySelectorAll('.dropdown-option')
      ];

      const currentIndex = options.indexOf(active);

      switch (e.key) {

        case 'ArrowDown':
          e.preventDefault();

          if (currentIndex < options.length - 1) {

            options[currentIndex].setAttribute('tabindex', '-1');

            options[currentIndex + 1].setAttribute('tabindex', '0');

            options[currentIndex + 1].focus();
          }
          break;

        case 'ArrowUp':
          e.preventDefault();

          if (currentIndex > 0) {

            options[currentIndex].setAttribute('tabindex', '-1');

            options[currentIndex - 1].setAttribute('tabindex', '0');

            options[currentIndex - 1].focus();
          }
          break;

        case 'Home':
          e.preventDefault();

          options[currentIndex].setAttribute('tabindex', '-1');
          options[0].setAttribute('tabindex', '0');
          options[0].focus();

          break;

        case 'End':
          e.preventDefault();

          options[currentIndex].setAttribute('tabindex', '-1');
          options[options.length - 1].setAttribute('tabindex', '0');
          options[options.length - 1].focus();

          break;

        case 'Enter':
        case ' ':
          e.preventDefault();

          active.click();

          setTimeout(() => {
            trigger.focus();
          }, 100);

          break;

        case 'Escape':
          e.preventDefault();

          trigger.focus();
          document.body.click();

          break;
      }
    });
  });

})();

(function () {

  const accordionItems = document.querySelectorAll('.accordion-item');

  if (!accordionItems.length) return;

  accordionItems.forEach((item, index) => {

    const header = item.querySelector('.accordion-header');
    const content = item.querySelector('.accordion-content');

    if (!header || !content) return;

    const baseId = item.id || `accordion-item-${index}`;
    const headerId = `accordion-header-${baseId}`;
    const contentId = `accordion-panel-${baseId}`;

    header.id = headerId;
    content.id = contentId;

    header.setAttribute('role', 'button');
    header.setAttribute('tabindex', '0');
    header.setAttribute('aria-controls', contentId);

    content.setAttribute('role', 'region');
    content.setAttribute('aria-labelledby', headerId);

    const isInitiallyOpen =
      window.getComputedStyle(content).display !== 'none' &&
      !content.hasAttribute('hidden');

    header.setAttribute(
      'aria-expanded',
      isInitiallyOpen ? 'true' : 'false'
    );

    const arrowWrapper = header.querySelector('.arrow-icon-wrapper');

    if (arrowWrapper) {
      arrowWrapper.setAttribute('aria-hidden', 'true');
    }

    header.addEventListener('keydown', function (event) {

      switch (event.key) {

        case 'Enter':
        case ' ':
          event.preventDefault();
          event.stopPropagation();

          header.dispatchEvent(
            new MouseEvent('click', {
              bubbles: true,
              cancelable: true,
              view: window
            })
          );

          break;

        case 'ArrowDown':
          event.preventDefault();

          if (index < accordionItems.length - 1) {
            accordionItems[index + 1]
              .querySelector('.accordion-header')
              ?.focus();
          }

          break;

        case 'ArrowUp':
          event.preventDefault();

          if (index > 0) {
            accordionItems[index - 1]
              .querySelector('.accordion-header')
              ?.focus();
          }

          break;

        case 'Home':
          event.preventDefault();

          accordionItems[0]
            .querySelector('.accordion-header')
            ?.focus();

          break;

        case 'End':
          event.preventDefault();

          accordionItems[accordionItems.length - 1]
            .querySelector('.accordion-header')
            ?.focus();

          break;
      }
    });

    const observer = new MutationObserver(() => {

      const isVisible =
        window.getComputedStyle(content).display !== 'none';

      header.setAttribute(
        'aria-expanded',
        isVisible ? 'true' : 'false'
      );

      content.setAttribute(
        'aria-hidden',
        isVisible ? 'false' : 'true'
      );

      const focusables = content.querySelectorAll(
        'a, button, input, select, textarea, [tabindex]'
      );

      focusables.forEach(el => {

        if (isVisible) {

          if (el.dataset.originalTabindex !== undefined) {

            if (el.dataset.originalTabindex === '') {
              el.removeAttribute('tabindex');
            } else {
              el.setAttribute(
                'tabindex',
                el.dataset.originalTabindex
              );
            }
          }

        } else {

          if (el.dataset.originalTabindex === undefined) {
            el.dataset.originalTabindex =
              el.getAttribute('tabindex') || '';
          }

          el.setAttribute('tabindex', '-1');
        }

      });

    });

    observer.observe(content, {
      attributes: true,
      attributeFilter: ['style', 'class']
    });

  });

})();

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&














(function (Drupal, once) {

  Drupal.behaviors.oneTrustModalFocus = {
    attach: function (context) {

      once('ot-modal-focus', '.paze-cookie-preferences', context)
      .forEach(function(trigger){

        let previousFocus = null;
        let disabledItems = [];

        trigger.addEventListener('click', function(){

          previousFocus = document.activeElement;

          const interval = setInterval(function(){

            const modal = document.querySelector('#onetrust-pc-sdk');

            if (
              modal &&
              !modal.classList.contains('ot-hide')
            ) {

              clearInterval(interval);

              // Focus Cookie dialog
              const dialog = modal.querySelector('[role="dialog"]');

              if(dialog){
                setTimeout(function(){
                  dialog.focus();
                },200);
              }

              // Disable all focusable elements outside popup
              disabledItems = [];

              const focusables = document.querySelectorAll(
                'a,button,input,select,textarea,[tabindex]'
              );

              focusables.forEach(function(el){

                if(!modal.contains(el)){

                  disabledItems.push({
                    element: el,
                    tabindex: el.getAttribute('tabindex')
                  });

                  el.setAttribute('tabindex','-1');

                }

              });

              // Watch for close
              const closeInterval = setInterval(function(){

                if(modal.classList.contains('ot-hide')){

                  clearInterval(closeInterval);

                  // Restore tabindex values
                  disabledItems.forEach(function(item){

                    if(item.tabindex === null){
                      item.element.removeAttribute('tabindex');
                    } else {
                      item.element.setAttribute(
                        'tabindex',
                        item.tabindex
                      );
                    }

                  });

                  disabledItems=[];

                  // Return focus
                  if(previousFocus){
                    previousFocus.focus();
                  }

                }

              },100);

            }

          },100);

        });

      });

    }
  };

})(Drupal, once);


LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL


(function (Drupal, once) {
  Drupal.behaviors.oneTrustFocusRestore = {
    attach: function (context) {

      once('ot-focus-restore', '.paze-cookie-preferences', context)
      .forEach(function(trigger){

        let previousFocus = null;

        trigger.addEventListener('click', function(){

          previousFocus = document.activeElement;

          const openWatcher = setInterval(function(){

            const modal = document.querySelector('#onetrust-pc-sdk');
            const dialog = modal?.querySelector('[role="dialog"]');

            if (
              modal &&
              dialog &&
              !modal.classList.contains('ot-hide')
            ) {

              clearInterval(openWatcher);

              // Focus Cookie Preference Center
              setTimeout(function(){
                dialog.focus();
              },200);

              // Watch for modal close
              const closeWatcher = setInterval(function(){

                if(modal.classList.contains('ot-hide')){

                  clearInterval(closeWatcher);

                  // Return focus to footer link
                  if(previousFocus){
                    previousFocus.focus();
                  }

                }

              },100);

            }

          },100);

        });

      });

    }
  };
})(Drupal, once);
_______________________________________________



(function (Drupal, once) {
  Drupal.behaviors.oneTrustInertFix = {
    attach: function (context) {

      once('ot-inert-fix', '.paze-cookie-preferences', context)
      .forEach(function(trigger){

        let previousFocus = null;

        trigger.addEventListener('click', function(){

          previousFocus = document.activeElement;

          const timer = setInterval(function(){

            const modal = document.querySelector('#onetrust-pc-sdk');

            if (
              modal &&
              !modal.classList.contains('ot-hide')
            ) {

              clearInterval(timer);

              // Make everything except OneTrust inert
              [...document.body.children].forEach(function(el){

                if (el.id !== 'onetrust-pc-sdk') {
                  el.setAttribute('inert', '');
                  el.setAttribute('aria-hidden', 'true');
                }

              });

              // Focus inside popup
              const dialog = modal.querySelector('[role="dialog"]');

              setTimeout(function(){
                if(dialog){
                  dialog.focus();
                }
              },200);

              // Watch close
              const closeTimer = setInterval(function(){

                if(modal.classList.contains('ot-hide')){

                  clearInterval(closeTimer);

                  // Restore page
                  [...document.body.children].forEach(function(el){

                    if(el.id !== 'onetrust-pc-sdk'){
                      el.removeAttribute('inert');
                      el.removeAttribute('aria-hidden');
                    }

                  });

                  // Restore original focus
                  if(previousFocus){
                    previousFocus.focus();
                  }

                }

              },100);

            }

          },100);

        });

      });
    }
  };
})(Drupal, once);



(function (Drupal, once) {
  Drupal.behaviors.oneTrustFocusFix = {
    attach: function (context) {

      once('ot-focus-fix', '.paze-cookie-preferences', context)
        .forEach(function (trigger) {

          let previousFocus = null;
          let disabledElements = [];

          trigger.addEventListener('click', function () {

            previousFocus = document.activeElement;

            const observer = setInterval(function () {

              const modal = document.querySelector('#onetrust-pc-sdk');

              if (
                modal &&
                !modal.classList.contains('ot-hide')
              ) {
                clearInterval(observer);

                // Focus the dialog
                const dialog = modal.querySelector('[role="dialog"]');

                setTimeout(function () {
                  if (dialog) {
                    dialog.focus();
                  }
                }, 200);

                // Disable focus outside modal
                const outsideFocusable = document.querySelectorAll(
                  'a, button, input, select, textarea, [tabindex]'
                );

                outsideFocusable.forEach(function(el){

                  // Skip modal elements
                  if (!modal.contains(el)) {

                    disabledElements.push({
                      element: el,
                      tabindex: el.getAttribute('tabindex')
                    });

                    el.setAttribute('tabindex', '-1');
                  }
                });

                // Watch for close
                const closeWatcher = setInterval(function(){

                  if(modal.classList.contains('ot-hide')){

                    clearInterval(closeWatcher);

                    // Restore tabindex values
                    disabledElements.forEach(function(item){

                      if(item.tabindex === null){
                        item.element.removeAttribute('tabindex');
                      } else {
                        item.element.setAttribute(
                          'tabindex',
                          item.tabindex
                        );
                      }

                    });

                    disabledElements=[];

                    // Return focus
                    if(previousFocus){
                      previousFocus.focus();
                    }

                  }

                },100);

              }

            },100);

          });

        });

    }
  };
})(Drupal, once);







(function (Drupal, once) {
  Drupal.behaviors.oneTrustAccessibilityFix = {
    attach: function (context) {

      once('ot-accessibility-fix', '.paze-cookie-preferences', context)
      .forEach(function (trigger) {

        let footerLink = trigger;

        trigger.addEventListener('click', function () {

          const interval = setInterval(function () {

            const modal = document.querySelector('#onetrust-pc-sdk');
            const dialog = modal ? modal.querySelector('[role="dialog"]') : null;

            if (
              modal &&
              dialog &&
              !modal.classList.contains('ot-hide')
            ) {
              clearInterval(interval);

              // Move focus into Cookie Preference Center
              setTimeout(function () {
                dialog.focus();
              }, 200);

            }

          }, 100);

        });

      });

      // Focus handling while modal is open
      document.addEventListener('keydown', function (e) {

        const modal = document.querySelector('#onetrust-pc-sdk');

        if (
          !modal ||
          modal.classList.contains('ot-hide')
        ) {
          return;
        }

        const dialog = modal.querySelector('[role="dialog"]');

        if (!dialog || e.key !== 'Tab') {
          return;
        }

        const focusable = [
          ...modal.querySelectorAll(
            'button, a, input, select, textarea, [tabindex="0"]'
          )
        ].filter(el =>
          el.offsetParent !== null &&
          !el.disabled
        );

        if (!focusable.length) return;

        const first = focusable[0];

        // Shift+Tab from first element
        if (
          e.shiftKey &&
          document.activeElement === first
        ) {
          e.preventDefault();

          document
            .querySelector('.paze-cookie-preferences')
            .focus();
        }

        // Tab from footer link
        if (
          !e.shiftKey &&
          document.activeElement.classList.contains(
            'paze-cookie-preferences'
          )
        ) {
          e.preventDefault();

          dialog.focus();
        }

      }, true);

    }
  };
})(Drupal, once);


oooooooooooooooooooooooooooooooooooooooo


(function (Drupal, once) {
  Drupal.behaviors.oneTrustFocusFix = {
    attach: function (context) {

      once('ot-focus-fix', '.paze-cookie-preferences', context)
        .forEach(function (trigger) {

          let footerLink = trigger;

          trigger.addEventListener('click', function () {

            const observer = new MutationObserver(function () {

              const modal = document.querySelector('#onetrust-pc-sdk');

              if (modal && !modal.classList.contains('ot-hide')) {

                observer.disconnect();

                // Focus first element after modal opens
                setTimeout(function () {
                  const firstFocusable = modal.querySelector(
                    '#close-pc-btn-handler, button, input, [tabindex="0"]'
                  );

                  if (firstFocusable) {
                    firstFocusable.focus();
                  }
                }, 300);

              }
            });

            observer.observe(document.body, {
              childList: true,
              subtree: true,
              attributes: true
            });

          });

          // Global capture listener
          document.addEventListener('keydown', function (e) {

            const modal = document.querySelector('#onetrust-pc-sdk');

            if (
              !modal ||
              modal.classList.contains('ot-hide')
            ) {
              return;
            }

            if (e.key !== 'Tab') return;

            const focusables = [...modal.querySelectorAll(
              'button, a, input, select, textarea, [tabindex="0"]'
            )].filter(el =>
              el.offsetParent !== null
            );

            if (!focusables.length) return;

            const first = focusables[0];
            const last = focusables[focusables.length - 1];

            // Shift+Tab from first item
            if (
              e.shiftKey &&
              document.activeElement === first
            ) {
              e.preventDefault();
              e.stopImmediatePropagation();

              footerLink.focus();

              return false;
            }

            // Tab from footer link back into popup
            if (
              !e.shiftKey &&
              document.activeElement === footerLink
            ) {
              e.preventDefault();
              e.stopImmediatePropagation();

              first.focus();

              return false;
            }

            // Prevent escaping forward
            if (
              !e.shiftKey &&
              document.activeElement === last
            ) {
              e.preventDefault();
              first.focus();

              return false;
            }

          }, true); // IMPORTANT: capture=true

        });
    }
  };
})(Drupal, once);




))))))))))))))))))))))))))))))))))))))))
(function (Drupal, once) {
  Drupal.behaviors.oneTrustFocusTrap = {
    attach: function (context) {

      once('ot-focus-trap', '.paze-cookie-preferences', context)
        .forEach(function (trigger) {

          let previousFocus = null;

          trigger.addEventListener('click', function () {

            previousFocus = document.activeElement;

            const observer = new MutationObserver(function () {

              const modal = document.querySelector('#onetrust-pc-sdk');

              if (modal && !modal.classList.contains('ot-hide')) {

                observer.disconnect();

                // Get all visible focusable items in popup
                function getFocusable() {
                  return [...modal.querySelectorAll(
                    'button, a, input, select, textarea, [tabindex="0"]'
                  )].filter(el =>
                    el.offsetWidth > 0 &&
                    el.offsetHeight > 0 &&
                    !el.disabled
                  );
                }

                let focusable = getFocusable();

                let first = focusable[0];
                let last = focusable[focusable.length - 1];

                // Initial focus
                setTimeout(() => {
                  first.focus();
                }, 100);

                // Trap keyboard navigation
                modal.addEventListener('keydown', function (e) {

                  if (e.key !== 'Tab') return;

                  focusable = getFocusable();
                  first = focusable[0];
                  last = focusable[focusable.length - 1];

                  // Shift+Tab on first item
                  if (
                    e.shiftKey &&
                    document.activeElement === first
                  ) {
                    e.preventDefault();

                    // move outside popup to footer link
                    previousFocus.focus();
                  }

                  // Tab on last item
                  else if (
                    !e.shiftKey &&
                    document.activeElement === last
                  ) {
                    e.preventDefault();

                    // cycle back inside popup
                    first.focus();
                  }

                });

                // Restore focus after close
                const closeObserver = new MutationObserver(function () {

                  if (modal.classList.contains('ot-hide')) {

                    closeObserver.disconnect();

                    if (previousFocus) {
                      previousFocus.focus();
                    }

                  }

                });

                closeObserver.observe(modal,{
                  attributes:true,
                  attributeFilter:['class']
                });

              }

            });

            observer.observe(document.body,{
              childList:true,
              subtree:true
            });

          });

        });

    }
  };
})(Drupal, once);

**************************************************|||||||||||||

(function (Drupal, once) {
  Drupal.behaviors.oneTrustFocusManagement = {
    attach: function (context) {

      once('ot-focus', '.paze-cookie-preferences', context)
        .forEach(function (trigger) {

          let previousFocus = null;

          trigger.addEventListener('click', function () {

            previousFocus = document.activeElement;

            const observer = new MutationObserver(function () {

              const modal = document.querySelector('#onetrust-pc-sdk');

              if (
                modal &&
                !modal.classList.contains('ot-hide')
              ) {
                observer.disconnect();

                // Focus first meaningful control in popup
                const firstFocusable =
                  modal.querySelector(
                    '#close-pc-btn-handler,' +
                    '.category-menu-switch-handler,' +
                    'button,' +
                    'input,' +
                    '[tabindex="0"]'
                  );

                if (firstFocusable) {
                  setTimeout(function () {
                    firstFocusable.focus();
                  }, 100);
                }

                // Watch modal closing
                const closeObserver = new MutationObserver(function () {

                  if (modal.classList.contains('ot-hide')) {
                    closeObserver.disconnect();

                    // Return focus to original footer link
                    if (previousFocus) {
                      previousFocus.focus();
                    }
                  }
                });

                closeObserver.observe(modal, {
                  attributes: true,
                  attributeFilter: ['class']
                });
              }
            });

            observer.observe(document.body, {
              childList: true,
              subtree: true
            });

          });
        });
    }
  };
})(Drupal, once);


**********************************************************************


(function (Drupal, once) {
  Drupal.behaviors.cookiePreferenceFocus = {
    attach: function (context) {

      once(
        'cookie-focus',
        '.paze-cookie-preferences',
        context
      ).forEach(function (trigger) {

        let previousFocus = null;

        trigger.addEventListener('click', function () {

          // Store current focused element
          previousFocus = document.activeElement;

          // Wait for Cookie Preference Center to render
          const observer = new MutationObserver(function () {

            // Replace selector with actual cookie modal selector
            const cookieModal = document.querySelector(
              '#onetrust-pc-sdk, .cookie-preference-center'
            );

            if (cookieModal) {
              observer.disconnect();

              // Make modal programmatically focusable
              cookieModal.setAttribute('tabindex', '-1');

              // Focus first interactive item
              const firstFocusable = cookieModal.querySelector(
                'button, a, input, select, textarea, [tabindex]:not([tabindex="-1"])'
              );

              if (firstFocusable) {
                firstFocusable.focus();
              } else {
                cookieModal.focus();
              }

              // Watch for close event
              const closeObserver = new MutationObserver(function () {
                const isHidden =
                  cookieModal.offsetParent === null ||
                  cookieModal.getAttribute('aria-hidden') === 'true';

                if (isHidden) {
                  closeObserver.disconnect();

                  // Restore focus back to trigger
                  if (previousFocus) {
                    previousFocus.focus();
                  }
                }
              });

              closeObserver.observe(cookieModal, {
                attributes: true,
                attributeFilter: ['style', 'class', 'aria-hidden']
              });
            }
          });

          observer.observe(document.body, {
            childList: true,
            subtree: true
          });

        });

      });
    }
  };
})(Drupal, once);





Perfect 👍
Below is a detailed 2–3 page resume (long-form, professional, ATS-friendly) built entirely new and focused strictly on SQL, PostgreSQL, OOP concepts, JavaScript, PHP, and UNIX experience.
You can later trim or format it in Word/PDF as needed.

⸻

OMKAR GAONKAR

Senior Software / Backend Developer

📍 India
📞 +91-XXXXXXXXXX
📧 omkargaonkar@email.com
🔗 GitHub | LinkedIn (optional)

⸻

PROFESSIONAL SUMMARY

Results-driven Software Developer with strong expertise in PHP, JavaScript, SQL, and PostgreSQL, and a deep understanding of Object-Oriented Programming (OOP) principles. Experienced in developing, enhancing, and maintaining database-driven web applications in UNIX/Linux environments. Proven ability to design scalable backend systems, optimize database performance, and write clean, maintainable code following industry best practices. Adept at collaborating with cross-functional teams and delivering reliable software solutions.

⸻

CORE TECHNICAL SKILLS

Programming & Scripting
	•	PHP (OOP-based development)
	•	JavaScript (client-side validation, DOM manipulation, AJAX)

Database Technologies
	•	SQL (complex queries, joins, subqueries, indexes)
	•	PostgreSQL (schema design, optimization, performance tuning)

Software Engineering Concepts
	•	Object-Oriented Programming (OOP)
	•	Encapsulation
	•	Inheritance
	•	Polymorphism
	•	Abstraction
	•	MVC Architecture
	•	Code Reusability & Design Patterns

Operating Systems
	•	UNIX / Linux
	•	Shell commands
	•	File & directory permissions
	•	Cron jobs
	•	Process monitoring

Web & Backend Technologies
	•	RESTful API development
	•	Server-side validation
	•	Session & authentication handling
	•	Basic Apache / Nginx configuration

Tools & Utilities
	•	Git (version control)
	•	pgAdmin, phpMyAdmin
	•	Linux command-line utilities
	•	Debugging & logging tools

⸻

PROFESSIONAL EXPERIENCE

Software Developer

Company Name, India
MM/YYYY – Present
	•	Designed, developed, and maintained backend applications using PHP with strong OOP principles.
	•	Implemented modular and reusable code using object-oriented design patterns.
	•	Developed and optimized PostgreSQL database schemas, tables, and relationships.
	•	Wrote advanced SQL queries involving joins, subqueries, functions, and indexing to improve application performance.
	•	Integrated JavaScript for dynamic UI behavior, form validation, and asynchronous data handling.
	•	Worked extensively in UNIX/Linux environments for application deployment and server maintenance.
	•	Managed application logs, cron jobs, and file permissions to ensure system reliability.
	•	Collaborated with QA and frontend teams to debug issues and enhance application stability.
	•	Refactored legacy codebases to improve maintainability, readability, and execution speed.

⸻

DETAILED PROJECT EXPERIENCE

Enterprise Web Application
	•	Developed a scalable backend using PHP and PostgreSQL.
	•	Implemented OOP-based architecture following MVC principles.
	•	Designed normalized database schemas and optimized queries for large datasets.
	•	Implemented user authentication, authorization, and role-based access control.
	•	Improved performance by optimizing SQL queries and database indexing.

Database Management & Reporting System
	•	Built reporting modules using complex SQL and PostgreSQL functions.
	•	Created stored queries for data analysis and operational reporting.
	•	Ensured data integrity and consistency across multiple modules.

UNIX-Based Automation & Maintenance
	•	Created shell scripts for:
	•	Automated database backups
	•	Log rotation
	•	System health monitoring
	•	Scheduled jobs using cron to reduce manual operational effort.
	•	Managed server-level configurations and permissions.

⸻

KEY RESPONSIBILITIES & ACHIEVEMENTS
	•	Successfully delivered multiple backend modules within project deadlines.
	•	Reduced database query execution time through optimization techniques.
	•	Improved application stability by implementing proper exception handling and logging.
	•	Actively participated in code reviews to ensure coding standards and best practices.
	•	Provided technical support and documentation for deployed applications.

⸻

EDUCATION

Bachelor’s Degree / Diploma in Computer Science / IT
Institute / University Name
Year of Completion

⸻

SOFT SKILLS
	•	Strong problem-solving abilities
	•	Analytical thinking
	•	Effective communication
	•	Team collaboration
	•	Time management

⸻

DECLARATION

I hereby declare that the information furnished above is true and complete to the best of my knowledge and belief.

Omkar Gaonkar

⸻

✅ Next Options (Tell me what you want)

I can:
	•	Convert this into exact 2-page or 3-page Word/PDF
	•	Tailor it for PHP Developer / Backend Engineer / Full Stack roles
	•	Adjust language for MNC / Product-based companies
	•	Add years of experience (Fresher / 3+ / 5+ years)
	•	Make it 100% ATS-optimized

Just say the word 🚀
