jQuery(document).ready(function () {

  'use strict';

  var $ = jQuery,

    $contactForm = $('.contact-form form, form.contact-form'),
    $inputs,
    $captchaContainer,
    inputSelector = 'input[type=text], input[type=email], input[type=tel], textarea, select',
    parentWrapperClass = 'form-item',
    validateField;

  if ($contactForm.length) {

    $contactForm.attr('novalidate', 'novalidate');
    $inputs = $contactForm.find(inputSelector);
    $captchaContainer = $contactForm.find('div.captcha');

    // ADD ERROR SPANS
    $inputs.each(function (index, item) {
      var $input = $(item),
        $fieldWrapper,
        errorMsg,
        currentFieldErrMsg;

      // REQUIRED ERROR MESSAGE
      if ($("label[for='" + $input.attr("id") + "']").length) {
        currentFieldErrMsg =
          $("label[for='" + $input.attr("id") + "']").text() +
          " field is required.";
      } else {
        currentFieldErrMsg = "Please complete this mandatory field.";
      }

      if ($input.attr('required') === 'required') {
        $fieldWrapper = $input.closest("." + parentWrapperClass);
        errorMsg = $input.attr('type') === 'email'
          ? 'Please enter a valid email address.'
          : currentFieldErrMsg;

        $fieldWrapper.append(
          '<span class="error-msg">' + errorMsg + '</span>'
        );
      }
    });

    // Replace default select option
    $contactForm.find('select option[value="_none"]')
      .text('-- Select --')
      .val('');

    if ($captchaContainer.length) {
      $captchaContainer.append(
        '<span class="error-msg">Please complete reCaptcha challenge.</span>'
      );
    }

    // Field validation events
    $inputs.keyup(function (e) {
      validateField($(e.target));
    });

    $inputs.change(function (e) {
      validateField($(e.target));
    });

    // -----------------------------
    // FORM SUBMIT VALIDATION
    // -----------------------------
    $contactForm.on('submit', function (e) {

      var errors = false,
        recaptchaResponse,
        $requiredInputs = $(e.target).find('[required]');

      // Validate normal required fields
      $requiredInputs.each(function (index, item) {
        if (!validateField($(item))) {
          errors = true;
        }
      });

      // Captcha validation
      if ($captchaContainer.length) {
        recaptchaResponse = $("[name='g-recaptcha-response']").val();
        if (recaptchaResponse.length) {
          $captchaContainer.removeClass('has-error');
        } else {
          $captchaContainer.addClass('has-error');
          errors = true;
        }
      }

      // ---------------------------------------------------
      // *** NEW: YES/NO CHECKBOX VALIDATION ***
      // ---------------------------------------------------
      var yesChecked = $('#edit-yes').is(':checked');
      var noChecked = $('#edit-no').is(':checked');

      if (!yesChecked && !noChecked) {
        // show error message
        $(".yesno-error-msg").remove();
        $('#edit-yes').closest('.form-item')
          .append('<span class="error-msg yesno-error-msg">Please select Yes or No.</span>')
          .addClass('has-error');

        e.preventDefault();
        return false;
      } else {
        // Clear error when valid
        $(".yesno-error-msg").remove();
        $('#edit-yes').closest('.form-item').removeClass('has-error');
      }
      // ---------------------------------------------------

      if (errors) {
        e.preventDefault();
        return false;
      }

      // Submit UI state
      $contactForm.addClass('submitting');
      $contactForm.find('input[type="submit"]')
        .attr('value', 'Submitting...')
        .attr('disabled', 'disabled');

      return true;
    });
  }

  // ---------------------------------------------------
  // VALIDATE FIELD FUNCTION
  // ---------------------------------------------------
  validateField = function (ctx) {

    var $input = $(ctx),
      value = $input.val(),
      type = $input.attr('type'),
      $fieldWrapper = $input.closest('.' + parentWrapperClass),
      regex = {
        'email': /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[A-Za-z]{2,}$/,
        'tel': /^\d{10}$/
      },
      valid = true;

    // Required field validation
    if ($input.attr('required') === 'required') {

      if (!value || !value.length) {
        $fieldWrapper.addClass('has-error');
        valid = false;
      } else {
        $fieldWrapper.removeClass('has-error');
      }
    }

    // Email validation
    if (type === 'email' && value.length) {
      if (!regex.email.test(value)) {
        $fieldWrapper.addClass('has-error');
        valid = false;
      } else {
        $fieldWrapper.removeClass('has-error');
      }
    }

    // Phone validation
    if ($input.attr('id') && $input.attr('id').indexOf('phone') !== -1) {
      value = value.replace(/\D/g, '');
      $input.val(value);

      if (!regex.tel.test(value)) {
        $fieldWrapper.addClass('has-error');
        valid = false;
      } else {
        $fieldWrapper.removeClass('has-error');
      }
    }

    return valid;
  };
});