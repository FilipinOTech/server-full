<?php

# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is Weave Basic Object Server
#
# The Initial Developer of the Original Code is
# Mozilla Labs.
# Portions created by the Initial Developer are Copyright (C) 2008
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#	Toby Elliott (telliott@mozilla.com)
#	Anant Narayanan (anant@kix.in)
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****
	
require_once 'weave_user/base.php';
require_once 'weave_constants.php';

# Mozilla version of Authentication
class WeaveAuthentication implements WeaveAuthenticationBase
{
	var $_conn;
	var $_username = null;
	var $_alert;
		
 	private function constructUserDN() 
 	{
		
		return WEAVE_LDAP_AUTH_USER_PARAM_NAME . "=" . $this->_username . "," . WEAVE_LDAP_AUTH_DN;
	}
	
	function __construct($username)
	{
		$this->open_connection();
		$this->_username = $username;
	}
	
	function open_connection()
	{
		$this->_conn = ldap_connect(WEAVE_LDAP_AUTH_HOST);
		if (!$this->_conn)
			throw new Exception("Cannot contact LDAP server", 503);

		ldap_set_option($this->_conn, LDAP_OPT_PROTOCOL_VERSION, 3);
		
		return 1;
	}

	function get_connection()
	{
		return $this->_conn;
	}
 	
	function authenticate_user($password)
	{
		$dn = $this->constructUserDN();
		
		if (!ldap_bind($this->_conn, $dn, $password))
			return 0;

		$re = ldap_read($this->_conn, $dn, "objectClass=*", array("uidNumber"));

		$attrs = ldap_get_attributes($this->_conn, ldap_first_entry($this->_conn, $re));
		
		return $attrs['uidNumber'][0];
	}


	function get_user_alert()
	{
		return $this->_alert;
	}
	
}

?>