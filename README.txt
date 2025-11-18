jQuery(document).ready(function () {

    'use strict';

    var $ = jQuery;

    var $contactForm = $('.contact-form form, form.contact-form')
        .not('form.contact-message-support-form-salesforce-scam-form');

    var inputSelector = 'input[type=text], input[type=email], input[type=tel], textarea, select';
    var parentWrapperClass = 'form-item';

    var $inputs, $captchaContainer;

    if ($contactForm.length) {

        $contactForm.attr('novalidate', 'novalidate');

        $inputs = $contactForm.find(inputSelector);
        $captchaContainer = $contactForm.find('div.captcha');

        // --------------------------
        // Add error message to each field
        // --------------------------
        $inputs.each(function () {
            var $input = jQuery(this);
            var $fieldWrapper = $input.closest('.' + parentWrapperClass);

            var labelText = jQuery('label[for="' + $input.attr('id') + '"]').text();
            var msg = labelText ? labelText + ' field is required.' : 'Please complete this mandatory field.';

            // Remove old error first (avoid duplicates)
            $fieldWrapper.find('.error-msg').remove();

            $fieldWrapper.append(
                '<span class="error-msg" style="display:none;">' + msg + '</span>'
            );
        });

        // Default placeholder for empty selects
        $contactForm.find('select option[value="_none"]')
            .text('-- Select --')
            .val('');

        // Add error message for captcha if present
        if ($captchaContainer.length) {
            $captchaContainer.append(
                '<span class="error-msg" style="display:none;">Please complete reCaptcha challenge.</span>'
            );
        }

        // Real-time field validation
        $inputs.on('keyup change blur', function () {
            _validateField(jQuery(this));
        });

        // --------------------------
        // SUBMIT EVENT
        // --------------------------
        $contactForm.on('submit', function (e) {

            var errors = false;

            // Validate required fields
            var $requiredInputs = jQuery(this).find('input[required], textarea[required], select[required]');
            $requiredInputs.each(function () {
                if (!_validateField(jQuery(this))) {
                    errors = true;
                }
            });

            // --------------------------
            // Required Checkbox Group Validation (YES/NO)
            // --------------------------
            var $checkboxGroups = {};

            $contactForm.find('input[type="checkbox"][required]').each(function () {
                var name = jQuery(this).attr('name');
                if (!$checkboxGroups[name]) {
                    $checkboxGroups[name] = $contactForm.find('input[name="' + name + '"]');
                }
            });

            jQuery.each($checkboxGroups, function (name, $group) {

                var $wrapper = $group.first().closest('.form-item');

                // Clean old error
                $wrapper.find('.error-msg-checkbox').remove();
                $wrapper.removeClass('has-error');

                if (!$group.is(':checked')) {
                    errors = true;

                    $wrapper.addClass('has-error');

                    $wrapper.append(
                        '<span class="error-msg error-msg-checkbox">Please select a valid option.</span>'
                    );
                }
            });

            // --------------------------
            // reCAPTCHA validation
            // --------------------------
            if ($captchaContainer.length) {
                var recaptchaResponse = jQuery('[name="g-recaptcha-response"]').val();

                if (!recaptchaResponse) {
                    $captchaContainer.addClass('has-error');
                    $captchaContainer.find('.error-msg').show();
                    errors = true;
                } else {
                    $captchaContainer.removeClass('has-error');
                }
            }

            // --------------------------
            // TERMS & CONDITIONS
            // --------------------------
            var $fieldset = jQuery('fieldset.terms-and-conditions-fieldset');

            if ($fieldset.length) {
                var pass = true;

                if (!$fieldset.hasClass('terms-scrolled')) {
                    e.preventDefault();
                    $fieldset.find('.terms-error-wrapper')
                        .text('Please review the terms and conditions before submitting the form.')
                        .fadeIn(250);
                    pass = false;
                } else if (!$fieldset.find('#edit-terms-accept').is(':checked')) {
                    e.preventDefault();
                    $fieldset.find('.terms-error-wrapper')
                        .text('Please accept the terms and conditions before submitting the form.')
                        .fadeIn(250);
                    pass = false;
                }

                if (!pass) {
                    errors = true;
                }
            }

            // STOP SUBMIT IF ERRORS
            if (errors) {
                e.preventDefault();
                return false;
            }

            // --------------------------
            // SUCCESS – Submit Form Normally
            // --------------------------
            $contactForm.addClass('submitting');
            $contactForm.find('input[type="submit"]')
                .attr('value', 'Submitting...')
                .attr('disabled', 'disabled');

            return true;
        });
    }

    // ******************************************************************
    // FIELD VALIDATION FUNCTION
    // ******************************************************************
    function _validateField($input) {

        var value = $input.val();
        var type = $input.attr('type');
        var $fieldWrapper = $input.closest('.' + parentWrapperClass);

        var regex = {
            email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
            tel: /^\(?([0-9]{3})\)?[-.]?([0-9]{3})[-.]?([0-9]{4})$/
        };

        var valid = true;

        // Hide old error
        $fieldWrapper.removeClass('has-error');
        $fieldWrapper.find('.error-msg').hide();

        // Required field empty
        if ($input.attr('required') && (!value || value.trim() === '')) {
            valid = false;
        }

        // Email validation
        if (type === 'email' && value && !regex.email.test(value)) {
            valid = false;
        }

        // Phone validation
        if (type === 'tel' && value && !regex.tel.test(value)) {
            valid = false;
        }

        if (!valid) {
            $fieldWrapper.addClass('has-error');
            $fieldWrapper.find('.error-msg').show();
        }

        return valid;
    }
});