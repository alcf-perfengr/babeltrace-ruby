require 'mkmf'

pkg_config("babeltrace")
pkg_config("babeltrace-ctf")

dir_config("babeltrace")
create_makefile("babeltrace_c")
