require 'mkmf'

pkg_config("babeltrace")
pkg_config("babeltrace-ctf")
pkg_config("glib-2.0")

dir_config("babeltrace")
create_makefile("babeltrace_c")
