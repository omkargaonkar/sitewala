jQuery(document).ready(function ($) {
    'use strict';

    var $contactForm = $('.contact-form form, form.contact-form').not('.contact-message-support-form-salesforce-scam'),
        inputSelector = 'input[type=text], input[type=email], input[type=tel], textarea, select, input[type=checkbox]',
        parentWrapperClass = 'form-item';

    if ($contactForm.length) {
        $contactForm.attr('novalidate', 'novalidate');

        var _validateField = function ($input) {
            var value = $input.val(),
                type = $input.attr('type'),
                $fieldWrapper = $input.closest('.' + parentWrapperClass),
                valid = true;

            // Remove previous error
            $fieldWrapper.removeClass('has-error');
            $fieldWrapper.find('.error-msg').remove();

            // Checkbox validation
            if (type === 'checkbox' && $input.prop('required') && !$input.is(':checked')) {
                valid = false;
                $fieldWrapper.addClass('has-error')
                    .append('<span class="error-msg">This checkbox is required.</span>');
                return valid;
            }

            // Required fields
            if ($input.prop('required') && (!value || value.trim() === '')) {
                valid = false;
                var label = $("label[for='" + $input.attr('id') + "']").text() || 'This field';
                $fieldWrapper.addClass('has-error')
                    .append('<span class="error-msg">' + label + ' is required.</span>');
                return valid;
            }

            // Email validation
            if (type === 'email' && value) {
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(value)) {
                    valid = false;
                    $fieldWrapper.addClass('has-error')
                        .append('<span class="error-msg">Please enter a valid email address.</span>');
                }
            }

            // Phone validation
            if (type === 'tel' && value) {
                var phoneRegex = /^\(?([0-9]{3})\)?[-.]?([0-9]{3})[-.]?([0-9]{4})$/;
                if (!phoneRegex.test(value)) {
                    valid = false;
                    $fieldWrapper.addClass('has-error')
                        .append('<span class="error-msg">Please enter a valid phone number.</span>');
                }
            }

            return valid;
        };

        // Validate on blur/change/keyup
        $contactForm.find(inputSelector).on('blur change keyup', function () {
            _validateField($(this));
        });

        // Form submit
        $contactForm.on('submit', function (e) {
            var $form = $(this),
                isValid = true;

            $form.find(inputSelector).each(function () {
                if (!_validateField($(this))) {
                    isValid = false;
                }
            });

            // Terms and conditions
            var $terms = $form.find('fieldset.terms-and-conditions-fieldset');
            if ($terms.length) {
                if (!$terms.hasClass('terms-scrolled')) {
                    isValid = false;
                    $terms.find('.terms-and-conditions-wrapper').css('border-color', 'red');
                    $terms.find('.terms-error-wrapper').text('Please review the terms and conditions before submitting.');
                } else if (!$terms.find('#edit-terms-accept').is(':checked')) {
                    isValid = false;
                    $terms.find('.terms-error-wrapper').text('Please accept the terms and conditions before submitting.');
                } else {
                    $terms.find('.terms-error-wrapper').hide();
                }
            }

            // reCAPTCHA validation
            var $captchaContainer = $form.find('div.captcha');
            if ($captchaContainer.length) {
                var recaptchaResponse = $('[name="g-recaptcha-response"]').val();
                if (!recaptchaResponse) {
                    isValid = false;
                    $captchaContainer.addClass('has-error')
                        .append('<span class="error-msg">Please complete reCaptcha challenge.</span>');
                } else {
                    $captchaContainer.removeClass('has-error');
                }
            }

            if (!isValid) {
                e.preventDefault();
                return false;
            }

            // Form submitting state
            $form.addClass('submitting');
            $form.find('input[type="submit"]').val('Submitting...').attr('disabled', 'disabled');
        });
    }
});