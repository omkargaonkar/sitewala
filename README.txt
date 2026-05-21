
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
