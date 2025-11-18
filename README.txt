jQuery(document).ready(function () {

    'use strict';

    var $ = jQuery,
        $contactForm = $('.contact-form form, form.contact-form'),
        $inputs,
        $captchaContainer,
        parentWrapperClass = 'form-item',
        inputSelector = 'input[type=text], input[type=email], input[type=tel], textarea, select',
        _validateField;

    if ($contactForm.length) {

        // Disable native validation
        $contactForm.attr('novalidate', 'novalidate');
        $inputs = $contactForm.find(inputSelector);
        $captchaContainer = $contactForm.find('div.captcha');

        // Trigger blur on load to show errors early
        $inputs.blur();

        // Build required-field error messages
        $inputs.each(function (index, item) {
            var $input = $(item),
                $fieldWrapper = $input.closest('.' + parentWrapperClass),
                errorMsg = '',
                currentFieldErrMsg = '';

            if ($("label[for='" + $input.attr('id') + "']").length) {
                currentFieldErrMsg = $("label[for='" + $input.attr('id') + "']").text() + ' field is required.';
            } else {
                currentFieldErrMsg = 'Please complete this mandatory field.';
            }

            if ($input.attr('required') === 'required') {

                if ($input.attr('type') === 'email') {
                    errorMsg = 'Please enter a valid email address.';
                } else {
                    errorMsg = currentFieldErrMsg;
                }

                $fieldWrapper.append('<span class="error-msg">' + errorMsg + '</span>');
            }
        });

        // Default dropdown placeholder
        $contactForm.find('select option[value="_none"]').text('-- Select --');

        // Add captcha error message
        if ($captchaContainer.length) {
            $captchaContainer.append('<span class="error-msg">Please complete reCaptcha challenge.</span>');
        }

        // Run validation on keyup
        $inputs.keyup(function (e) {
            _validateField($(e.target));
        });

        // Run validation on change
        $inputs.change(function (e) {
            var $target = $(e.target);
            if ($target.val()) {
                _validateField($target);
            }
        });

        // FORM SUBMIT VALIDATION
        $contactForm.on('submit', function (e) {
            var errors = false,
                recaptchaResponse = $('[name="g-recaptcha-response"]').val(),
                $requiredInputs = $(e.target).find('input[required], textarea[required], select[required]');

            // Validate all required fields
            $requiredInputs.each(function (index, item) {
                if (!_validateField($(item))) {
                    errors = true;
                }
            });

            // CAPTCHA check
            if ($captchaContainer.length) {
                if (recaptchaResponse && recaptchaResponse.length) {
                    $captchaContainer.removeClass('has-error');
                } else {
                    $captchaContainer.addClass('has-error');
                    errors = true;
                }
            }

            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            // >>> NEW CODE – YES/NO CHECKBOX VALIDATION (JIRA REQUIREMENT) >>>
            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

            var $ynCheckboxes = $('input[name="field_ar[0]"]'),
                $ynWrapper = $ynCheckboxes.closest('.form-item');

            // Remove old error
            $ynWrapper.find('.error-msg').remove();

            if (!$ynCheckboxes.is(':checked')) {

                $ynWrapper.addClass('has-error');

                $ynWrapper.append(
                    '<span class="error-msg" role="alert">Please select a valid option for "Are you a registered Diversity Supplier?".</span>'
                );

                errors = true;
            } else {
                $ynWrapper.removeClass('has-error');
            }

            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            // >>> END NEW CODE FOR JIRA >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

            if (errors) {
                e.preventDefault();
                return false;
            }

        }); // END SUBMIT HANDLER

    } // END if $contactForm.length

    // MAIN VALIDATION FUNCTION
    _validateField = function (ctx) {

        var $input = $(ctx),
            value = $input.val(),
            type = $input.attr('type'),
            $fieldWrapper = $input.closest('.' + parentWrapperClass),
            regex = {
                'email': /[a-zA-Z0-9]\S+[a-zA-Z0-9]@[a-zA-Z0-9]+\.[a-zA-Z]+(\.[a-zA-Z]+)?/,
                'tel': /^$begin:math:text$\?\(\[0\-9\]\{3\}\)$end:math:text$?[-.]?([0-9]{3})[-]?([0-9]{4})$/
            },
            valid = false;

        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        // >>> NEW CODE – VALIDATION ON BLUR/KEYUP FOR YES/NO FIELD >>>>>>
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        if ($input.attr('name') === 'field_ar[0]') {

            var $checkboxes = $('input[name="field_ar[0]"]'),
                $wrapper = $checkboxes.closest('.form-item');

            $wrapper.find('.error-msg').remove();

            if (!$checkboxes.is(':checked')) {

                $wrapper.addClass('has-error');

                $wrapper.append(
                    '<span class="error-msg" role="alert">Please select a valid option for "Are you a registered Diversity Supplier?".</span>'
                );

                return false;

            } else {
                $wrapper.removeClass('has-error');
                return true;
            }
        }

        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        // >>> END NEW YES/NO VALIDATION BLOCK >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        // Standard text/email/phone validation
        if (value && value.length) {
            $fieldWrapper.removeClass('has-error');
            valid = true;
        } else {
            $fieldWrapper.addClass('has-error');
            valid = false;
        }

        // EMAIL validation
        if (type === 'email') {
            valid = regex['email'].test(value);
            $fieldWrapper.toggleClass('has-error', !valid);
        }

        // PHONE validation
        if ($input.attr('id').indexOf('phone') !== -1) {
            if (value) {
                $input.val($input.val().replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3'));
            }
            valid = regex['tel'].test(value);
            $fieldWrapper.toggleClass('has-error', !valid);
        }

        return valid;
    };

});