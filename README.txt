/**
 * Implements hook_form_alter().
 */
function content_type_template_fields_form_alter(&$form, FormStateInterface $form_state, $form_id) {

  if ($form_id == 'contact_message_contact_name_form') {

    // Add custom validation handler.
    $form['#validate'][] = 'content_type_template_fields_supplier_validation';
  }
}

/**
 * Adds validation + visible error message.
 */
function content_type_template_fields_supplier_validation(&$form, FormStateInterface $form_state) {

  $values = $form_state->getValue('field_ar');

  // Determine if nothing selected.
  $selected = FALSE;
  if (is_array($values)) {
    foreach ($values as $v) {
      if ($v != 0 && $v != '' && $v != NULL) {
        $selected = TRUE;
      }
    }
  }

  if (!$selected) {

    // Add Drupal error (handles aria-invalid, .error class)
    $form_state->setErrorByName(
      'field_ar',
      t('Please select a valid option from "Are you a registered Diversity Supplier?".')
    );

    // Add visible inline error message into field.
    $form['field_ar']['widget']['#suffix'] =
      '<div class="form-item--error-message" role="alert">'
      . t('Please select a valid option from "Are you a registered Diversity Supplier?".')
      . '</div>';
  }
}