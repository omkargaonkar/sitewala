

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
