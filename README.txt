/**
 * Implements hook_form_alter().
 */
function content_type_template_fields_form_alter(&$form, FormStateInterface $form_state, $form_id) {

  // Apply fix only to Supplier Registration contact form.
  if ($form_id == 'contact_message_contact_name_form') {

    // Check field exists.
    if (isset($form['field_ar']['widget'])) {

      // Add custom validation to show accessible error message.
      $form['#validate'][] = 'content_type_template_fields_supplier_validation';
    }
  }
}

/**
 * Custom validation for Supplier Registration field.
 */
function content_type_template_fields_supplier_validation(&$form, FormStateInterface $form_state) {

  // Get submitted field values.
  $values = $form_state->getValue('field_ar');

  // Check if nothing is selected.
  $is_empty = TRUE;
  if (is_array($values)) {
    foreach ($values as $v) {
      if ($v !== 0 && $v !== '' && $v !== NULL) {
        $is_empty = FALSE;
      }
    }
  }

  // Validation fail - add accessible error.
  if ($is_empty) {
    $form_state->setErrorByName(
      'field_ar',
      t('Please select a valid option from "Are you a registered Diversity Supplier?".')
    );
  }
}