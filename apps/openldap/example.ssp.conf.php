<?php

// See official documentation for more details: https://self-service-password.readthedocs.io/en/latest/index.html 

$keyphrase = "SOME_LONG_AND_RANDOM_STRING";
$debug = false;

$show_menu = true;
$show_footer = true;
$use_tokens = false;
$use_questions = false;
$use_sms = false;

$ldap_url = "ldap://openldap:389";
$ldap_starttls = false;
$ldap_base = "dc=example,dc=com";
$ldap_binddn = "cn=admin,dc=example,dc=com";
$ldap_bindpw = file_get_contents("/run/secrets/ldap_admin_password");
$ldap_filter = "(|(objectclass=posixAccount))"; // optional

// ## Password policy (optional)
// $pwd_min_length = 8;
// $pwd_min_lower = 1;
// $pwd_min_upper = 1;
// $pwd_min_digit = 1;
// $pwd_min_special = 1;

// ## Mail (optional)
// # LDAP mail attribute
// $mail_attributes = array( "mail", "gosaMailAlternateAddress", "proxyAddresses" );
// # Get mail address directly from LDAP (only first mail entry)
// # and hide mail input field
// # default = false
// $mail_address_use_ldap = false;
// # Who the email should come from
// $mail_from = "admin@example.com";
// $mail_from_name = "Self Service Password";
// $mail_signature = "";
// # Notify users anytime their password is changed
// $notify_on_change = false;
// # PHPMailer configuration (see https://github.com/PHPMailer/PHPMailer)
// $mail_sendmailpath = '/usr/sbin/sendmail';
// $mail_protocol = 'smtp';
// $mail_smtp_debug = 0;
// $mail_debug_format = 'error_log';
// $mail_smtp_host = 'localhost';
// $mail_smtp_auth = false;
// $mail_smtp_user = '';
// $mail_smtp_pass = '';
// $mail_smtp_port = 25;
// $mail_smtp_timeout = 30;
// $mail_smtp_keepalive = false;
// $mail_smtp_secure = 'tls';
// $mail_smtp_autotls = true;
// $mail_smtp_options = array();
// $mail_contenttype = 'text/plain';
// $mail_wordwrap = 0;
// $mail_charset = 'utf-8';
// $mail_priority = 3;

?>