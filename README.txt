_validateField = function ($input) {
  // $input: jQuery object of the field to validate
  var value = $input.val(),
      type = $input.attr('type'),
      $fieldWrapper = $input.closest('.' + parentWrapperClass),
      emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      phoneRegex = /^\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})$/,
      valid = true;

  // --- CLEAR previous error state for this input ---
  // hide textual error in wrapper (if present)
  $fieldWrapper.removeClass('has-error');
  $fieldWrapper.find('.error-msg').hide();
  $input.removeAttr('aria-invalid');

  // -------------------------------
  // NEW: Checkbox-group handling
  // If the element is a checkbox, validate the whole group by name.
  // -------------------------------
  if ($input.is(':checkbox')) {
    // Group name (checkboxes for one field share the same name, e.g. field_ar[0])
    var groupName = $input.attr('name');
    var $group = $input.closest('form').find('input[name="' + groupName + '"]');

    // Find fieldset wrapper (Drupal renders boolean fields inside a fieldset).
    var $fieldset = $group.first().closest('fieldset');
    if ($fieldset.length === 0) {
      // Fallback to nearest form-item wrapper
      $fieldset = $group.first().closest('.form-item');
    }

    // Remove previous group error
    $fieldset.removeClass('has-error');
    $fieldset.find('.checkbox-error').remove();

    // If none of the checkboxes in this group are checked => invalid
    if (!$group.is(':checked')) {
      valid = false;

      // set aria-invalid on all checkboxes in the group so SR knows
      $group.attr('aria-invalid', 'true');

      // Add an accessible error message inside the fieldset (role=alert so SR announces)
      var labelText = $fieldset.find('.fieldset-legend').first().text().trim() || 'This field';
      var $err = $(
        '<div class="checkbox-error error-msg" role="alert" style="color:red;margin-top:6px;">' +
          'Please select a valid option for "' + labelText + '".' +
        '</div>'
      );
      $fieldset.addClass('has-error').find('.fieldset-wrapper').append($err);

    } else {
      // valid: ensure aria-invalid is removed from group
      $group.removeAttr('aria-invalid');
      $fieldset.removeClass('has-error');
      $fieldset.find('.checkbox-error').remove();
    }

    // Return result for group validation (we've handled checkbox group here)
    return valid;
  }
  // -------------------------------
  // END: Checkbox-group handling
  // -------------------------------

  // Required validation for non-checkbox fields
  if ($input.prop('required')) {
    if (value === null || typeof value === 'undefined' || (String(value).trim && String(value).trim() === '')) {
      $fieldWrapper.addClass('has-error');
      $fieldWrapper.find('.error-msg').text('This field is required.').show();
      $input.attr('aria-invalid', 'true');
      return false;
    }
  }

  // Email validation
  if (type === 'email' && value && value.length) {
    if (!emailRegex.test(value)) {
      $fieldWrapper.addClass('has-error');
      $fieldWrapper.find('.error-msg').text('Please enter a valid email address.').show();
      $input.attr('aria-invalid', 'true');
      return false;
    }
  }

  // Phone validation (simple 10-digit check; adjust regex if needed)
  if (type === 'tel' && value && value.length) {
    var digits = value.replace(/\D/g, '');
    if (!phoneRegex.test(digits)) {
      $fieldWrapper.addClass('has-error');
      $fieldWrapper.find('.error-msg').text('Please enter a valid phone number.').show();
      $input.attr('aria-invalid', 'true');
      return false;
    } else {
      // optionally rewrite formatted value (uncomment if you want)
      // $input.val('(' + digits.substr(0,3) + ') ' + digits.substr(3,3) + '-' + digits.substr(6,4));
    }
  }

  // If we reach here, field is valid
  $fieldWrapper.removeClass('has-error');
  $fieldWrapper.find('.error-msg').hide();
  $input.removeAttr('aria-invalid');

  return true;
};