jQuery(document).ready(function () {

    'use strict';

    var $ = jQuery,
        $contactForm = $('.contact-form form, form.contact-form').not('form.contact-message-support-form-salesforce-scam-form'),
        $inputs,
        $captchaContainer,
        inputSelector = 'input[type=text], input[type=email], input[type=tel], textarea, select',
        parentWrapperClass = 'form-item',
        _validateField;

    if ($contactForm.length) {

        $contactForm.attr('novalidate', 'novalidate');
        $inputs = $contactForm.find(inputSelector);
        $captchaContainer = $contactForm.find('div.captcha');

        // Add default error message placeholders
        $inputs.each(function () {
            var $input = $(this);
            var $wrapper = $input.closest('.' + parentWrapperClass);

            if ($wrapper.find('.error-msg').length === 0) {
                $wrapper.append('<span class="error-msg" style="display:none;"></span>');
            }
        });

        // Add captcha error message
        if ($captchaContainer.length) {
            $captchaContainer.append('<span class="error-msg">Please complete reCaptcha challenge.</span>');
        }

        // Validate on keyup change
        $inputs.on('keyup change', function (e) {
            _validateField($(e.target));
        });

        // *****************************************
        // YES/NO CHECKBOX VALIDATION (REQUIRED GROUP)
        // *****************************************

        function validateCheckboxGroups() {
            var errors = false;

            // Find ANY required checkbox groups
            var $requiredCheckboxes = $contactForm.find('input[type="checkbox"][required]');

            if ($requiredCheckboxes.length === 0) {
                return false; // no required checkbox groups
            }

            // Group them by name
            var groups = {};
            $requiredCheckboxes.each(function () {
                var name = $(this).attr('name');
                if (!groups[name]) {
                    groups[name] = $contactForm.find('input[name="' + name + '"]');
                }
            });

            // Validate each group
            $.each(groups, function (name, $group) {

                var $first = $group.first();
                var $wrapper = $first.closest('fieldset');

                if ($wrapper.length === 0) {
                    $wrapper = $first.closest('.form-item');
                }

                // Remove old errors
                $wrapper.removeClass('has-error');
                $wrapper.find('.checkbox-error').remove();

                // If none checked → Error
                if (!$group.is(':checked')) {
                    errors = true;

                    $wrapper.addClass('has-error')
                            .append('<div class="checkbox-error error-msg" style="color:red;margin-top:5px;">Please select a valid option.</div>');
                }
            });

            return errors;
        }

        // *****************************************
        // FORM SUBMIT VALIDATION
        // *****************************************

        $contactForm.on('submit', function (e) {

            var errors = false;

            // Validate all required fields
            var $requiredInputs = $(this).find('input[required], textarea[required], select[required]');
            $requiredInputs.each(function () {
                if (!_validateField($(this))) {
                    errors = true;
                }
            });

            // Validate required checkboxes
            if (validateCheckboxGroups()) {
                errors = true;
            }

            // Captcha
            if ($captchaContainer.length) {
                var recaptchaResponse = $('[name="g-recaptcha-response"]').val();
                if (!recaptchaResponse) {
                    $captchaContainer.addClass('has-error');
                    errors = true;
                } else {
                    $captchaContainer.removeClass('has-error');
                }
            }

            if (errors) {
                e.preventDefault();
                return false;
            }

            // Submit
            $contactForm.addClass('submitting');
            $contactForm.find('input[type="submit"]').val('Submitting...').attr('disabled', 'disabled');

            return true;
        });
    }

    // *****************************************
    // GENERIC FIELD VALIDATION
    // *****************************************

    _validateField = function ($input) {

        var value = $input.val(),
            type = $input.attr('type'),
            $wrapper = $input.closest('.' + parentWrapperClass),
            emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
            phoneRegex = /^\(?([0-9]{3})\)?[-.]?([0-9]{3})[-.]?([0-9]{4})$/,
            valid = true;

        // Reset
        $wrapper.removeClass('has-error');
        $wrapper.find('.error-msg').hide();

        // Required validation
        if ($input.prop('required') && (!value || value.trim() === '')) {
            $wrapper.addClass('has-error');
            $wrapper.find('.error-msg').text('This field is required.').show();
            return false;
        }

        // Email
        if (type === 'email' && value.length) {
            if (!emailRegex.test(value)) {
                $wrapper.addClass('has-error');
                $wrapper.find('.error-msg').text('Please enter a valid email address.').show();
                return false;
            }
        }

        // Phone
        if (type === 'tel' && value.length) {
            if (!phoneRegex.test(value)) {
                $wrapper.addClass('has-error');
                $wrapper.find('.error-msg').text('Please enter a valid phone number.').show();
                return false;
            }
        }

        return true;
    };
});