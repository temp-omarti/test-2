# Class to apply common role module and
# instance role module by role parameter
class instance_roles($role='') {
	# Include common config
	include instance_roles::roles::common

	# Include role specific config
	notify{"Applying instance role: '${role}'": }
	include "instance_roles::roles::${role}"
}
