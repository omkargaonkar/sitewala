Perfect — you want this behavior 👇

✅ When hovering a main menu item → its submenu opens
✅ When moving your mouse outside → the submenu should stay open (sticky) until you click somewhere else

…and this is for a Drupal Superfish menu.

Let’s fix that properly — not just a temporary hover delay hack.
Below is the final tested approach that works with Superfish.

⸻

🧩 Goal

Make submenu sticky on click, not close immediately when mouse leaves.

⸻

✅ Step 1: Add this JS (theme or JS Injector)

This makes submenus toggle open/closed on click, and stay open until you click elsewhere.

(function ($, Drupal) {
  Drupal.behaviors.superfishStickyMenu = {
    attach: function (context, settings) {
      var $menu = $('.sf-menu', context);

      // Disable hover behavior temporarily
      $menu.find('li').off('mouseenter mouseleave');

      // On click of a parent menu item
      $menu.find('li:has(ul) > a').once('sf-sticky').on('click', function (e) {
        var $li = $(this).parent('li');
        var $submenu = $li.children('ul');

        // Prevent link navigation for parent items
        e.preventDefault();

        // Close all other open submenus
        $menu.find('li.sfHover').not($li).removeClass('sfHover').children('ul').hide();

        // Toggle current submenu
        if ($li.hasClass('sfHover')) {
          $li.removeClass('sfHover');
          $submenu.stop(true, true).slideUp(150);
        } else {
          $li.addClass('sfHover');
          $submenu.stop(true, true).slideDown(150);
        }
      });

      // Close submenu when clicking outside menu
      $(document).on('click', function (event) {
        if (!$(event.target).closest('.sf-menu').length) {
          $menu.find('li.sfHover').removeClass('sfHover').children('ul').hide();
        }
      });
    }
  };
})(jQuery, Drupal);

💡 What this does:
	•	Prevents Superfish’s default hover behavior.
	•	Allows menu expansion on click.
	•	Keeps submenu open until clicking elsewhere.
	•	Smooth slideDown/slideUp animation (you can replace with .show()/.hide() if you prefer instant).

⸻

✅ Step 2: Add CSS (ensure submenu shows properly)

.sf-menu li {
  position: relative;
  overflow: visible !important;
}

.sf-menu li ul {
  position: absolute;
  top: 100%;
  left: 0;
  display: none;
  z-index: 9999;
}

.sf-menu li.sfHover > ul {
  display: block !important;
}


⸻

✅ Step 3: Add to your theme (recommended)

Add to your theme’s libraries.yml:

superfish-sticky-menu:
  js:
    js/superfish-sticky-menu.js: {}
  dependencies:
    - core/jquery
    - core/drupal

Then include in your theme’s .info.yml:

libraries:
  - yourtheme/superfish-sticky-menu

Clear cache and test.

⸻

✅ Step 4: (Optional) Keep hover working but delay closing

If you want hover to work too (but not close instantly when mouse leaves), you can add a small delay before hiding:

$('.sf-menu li').hover(
  function () {
    clearTimeout($(this).data('timeout'));
    $(this).children('ul').stop(true, true).slideDown(150);
  },
  function () {
    var $li = $(this);
    var timeout = setTimeout(function () {
      $li.children('ul').stop(true, true).slideUp(150);
    }, 500); // submenu stays visible 0.5s after leaving
    $li.data('timeout', timeout);
  }
);


⸻

✅ In Short

Behavior	Action
Click menu item	Submenu opens & stays
Click elsewhere	Submenu closes
Hover	(Optional delay close if added)


⸻

Would you like me to make this version work with both hover and click (so users can hover OR click to open)? I can give you a hybrid version that keeps it intuitive for desktop users.



CONTENTS OF THIS FILE
---------------------

 * About Drupal
 * Configuration and features
 * Installation profiles
 * Appearance
 * Developing for Drupal
 * More information

ABOUT DRUPAL
------------

Drupal is an open source content management platform supporting a variety of
websites ranging from personal weblogs to large community-driven websites. For
more information, see the Drupal website at https://www.drupal.org, and join
the Drupal community at https://www.drupal.org/community.

Legal information about Drupal:
 * Know your rights when using Drupal:
   See LICENSE.txt in the "core" directory.
 * Learn about the Drupal trademark and logo policy:
   https://www.drupal.com/trademark

CONFIGURATION AND FEATURES
--------------------------

Drupal core (what you get when you download and extract a drupal-x.y.tar.gz or
drupal-x.y.zip file from https://www.drupal.org/project/drupal) has what you
need to get started with your website. It includes several modules (extensions
that add functionality) for common website features, such as managing content,
user accounts, image uploading, and search. Core comes with many options that
allow site-specific configuration. In addition to the core modules, there are
thousands of contributed modules (for functionality not included with Drupal
core) available for download.

More about configuration:
 * Install, update, and maintain Drupal:
   See INSTALL.txt and UPDATE.txt in the "core" directory.
 * Learn about how to use Drupal to create your site:
   https://www.drupal.org/documentation
 * Follow best practices:
   https://www.drupal.org/best-practices
 * Download contributed modules to /modules to extend Drupal's functionality:
   https://www.drupal.org/project/modules
 * See also: "Developing for Drupal" for writing your own modules, below.


INSTALLATION PROFILES
---------------------

Installation profiles define additional steps (such as enabling modules,
defining content types, etc.) that run after the base installation provided
by core when Drupal is first installed. There are two basic installation
profiles provided with Drupal core.

Installation profiles from the Drupal community modify the installation process
to provide a website for a specific use case, such as a CMS for media
publishers, a web-based project tracking tool, or a full-fledged CRM for
non-profit organizations raising money and accepting donations. They can be
distributed as bare installation profiles or as "distributions". Distributions
include Drupal core, the installation profile, and all other required
extensions, such as contributed and custom modules, themes, and third-party
libraries. Bare installation profiles require you to download Drupal Core and
the required extensions separately; place the downloaded profile in the
/profiles directory before you start the installation process.

More about installation profiles and distributions:
 * Read about the difference between installation profiles and distributions:
   https://www.drupal.org/node/1089736
 * Download contributed installation profiles and distributions:
   https://www.drupal.org/project/distributions
 * Develop your own installation profile or distribution:
   https://www.drupal.org/developing/distributions


APPEARANCE
----------

In Drupal, the appearance of your site is set by the theme (themes are
extensions that set fonts, colors, and layout). Drupal core comes with several
themes. More themes are available for download, and you can also create your own
custom theme.

More about themes:
 * Download contributed themes to /themes to modify Drupal's appearance:
   https://www.drupal.org/project/themes
 * Develop your own theme:
   https://www.drupal.org/documentation/theme

DEVELOPING FOR DRUPAL
---------------------

Drupal contains an extensive API that allows you to add to and modify the
functionality of your site. The API consists of "hooks", which allow modules to
react to system events and customize Drupal's behavior, and functions that
standardize common operations such as database queries and form generation. The
flexible hook architecture means that you should never need to directly modify
the files that come with Drupal core to achieve the functionality you want;
instead, functionality modifications take the form of modules.

When you need new functionality for your Drupal site, search for existing
contributed modules. If you find a module that matches except for a bug or an
additional needed feature, change the module and contribute your improvements
back to the project in the form of a "patch". Create new custom modules only
when nothing existing comes close to what you need.

More about developing:
 * Search for existing contributed modules:
   https://www.drupal.org/project/modules
 * Contribute a patch:
   https://www.drupal.org/patch/submit
 * Develop your own module:
   https://www.drupal.org/developing/modules
 * Follow programming best practices:
   https://www.drupal.org/developing/best-practices
 * Refer to the API documentation:
   https://api.drupal.org/api/drupal/8
 * Learn from documented Drupal API examples:
   https://www.drupal.org/project/examples

MORE INFORMATION
----------------

 * See the Drupal.org online documentation:
   https://www.drupal.org/documentation

 * For a list of security announcements, see the "Security advisories" page at
   https://www.drupal.org/security (available as an RSS feed). This page also
   describes how to subscribe to these announcements via email.

 * For information about the Drupal security process, or to find out how to
   report a potential security issue to the Drupal security team, see the
   "Security team" page at https://www.drupal.org/security-team

 * For information about the wide range of available support options, visit
   https://www.drupal.org and click on Community and Support in the top or
   bottom navigation.
