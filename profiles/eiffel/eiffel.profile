<?php

/**
 * @file
 * Enables modules and site configuration for a eiffel site installation.
 */

 // Add any custom code here like hook implementations.
 function eiffel_install_tasks(&$install_state) {
  $tasks = array();
  $tasks['eiffel_default_users'] = array();
  return $tasks;
 }

 /**
 *  Function for creating default users.
 */
 function eiffel_default_users() {
  $user = \Drupal\user\Entity\User::create();
  $user->setPassword('callblogger');
  $user->enforceIsNew();
  $user->setEmail('omkargaonkar14@gmail.com');
  $user->setUsername('callbloggerr');
  $user->addRole('call_blogger');
  $user->set("status",1);
  $res = $user->save();
 }
