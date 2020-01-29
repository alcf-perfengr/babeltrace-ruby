#include "ruby.h"
#include "babeltrace/babeltrace.h"
#include "babeltrace/ctf/events.h"
#include "./babeltrace/types.h"


static VALUE m_babeltrace;
static VALUE m_ctf;
static VALUE m_internal;
static VALUE c_definition;
static VALUE c_declaration;
static VALUE c_internal_declaration;
static VALUE c_internal_definition;
static VALUE c_ctf_declaration;
static VALUE c_ctf_array_declaration;
static VALUE c_ctf_sequence_declaration;

static VALUE m_ffi;
static VALUE c_ffi_pointer;
static VALUE c_ffi_struct;

static VALUE babeltrace_ctf_array_decl_elem(VALUE self) {

  VALUE decl = rb_ivar_get(self, rb_intern("@declaration"));
  VALUE p = rb_funcall(decl, rb_intern("pointer"), 0);
  VALUE address = rb_funcall(p, rb_intern("address"), 0);

  const struct declaration_array *ptr = sizeof(ptr) == 4 ? (const struct declaration_array *) NUM2ULONG(address) : (const struct declaration_array *) NUM2ULL(address);
  struct bt_declaration *elem = ptr->elem;

  VALUE ffi_ptr = rb_funcall(c_ffi_pointer, rb_intern("new"), 1, ULL2NUM( sizeof(ptr) == 4 ? (unsigned long long int) (unsigned long int) elem : (unsigned long long int) elem ));

  VALUE idecl = rb_funcall(c_internal_declaration, rb_intern("new"), 1, ffi_ptr);
  VALUE arr_decl = rb_funcall(c_ctf_array_declaration, rb_intern("create"), 1, idecl);
  return arr_decl;
}

static VALUE babeltrace_ctf_sequence_decl_elem(VALUE self) {

  VALUE decl = rb_ivar_get(self, rb_intern("@declaration"));
  VALUE p = rb_funcall(decl, rb_intern("pointer"), 0);
  VALUE address = rb_funcall(p, rb_intern("address"), 0);

  const struct declaration_sequence *ptr = sizeof(ptr) == 4 ? (const struct declaration_sequence *) NUM2ULONG(address) : (const struct declaration_sequence *) NUM2ULL(address);
  struct bt_declaration *elem = ptr->elem;

  VALUE ffi_ptr = rb_funcall(c_ffi_pointer, rb_intern("new"), 1, ULL2NUM( sizeof(ptr) == 4 ? (unsigned long long int) (unsigned long int) elem : (unsigned long long int) elem ));

  VALUE idecl = rb_funcall(c_internal_declaration, rb_intern("new"), 1, ffi_ptr);
  VALUE seq_decl = rb_funcall(c_ctf_sequence_declaration, rb_intern("create"), 1, idecl);
  return seq_decl;
}

static VALUE babeltrace_ctf_internal_definition_get_char_sequence(VALUE self) {
  VALUE p = rb_funcall(self, rb_intern("pointer"), 0);
  VALUE address = rb_funcall(p, rb_intern("address"), 0);
  const struct definition_sequence *ptr = sizeof(ptr) == 4 ? (const struct definition_sequence *) NUM2ULONG(address) : (const struct definition_sequence *) NUM2ULL(address);

  char *str = ptr->string->str;
  VALUE ffi_ptr = rb_funcall(c_ffi_pointer, rb_intern("new"), 1, ULL2NUM( sizeof(ptr) == 4 ? (unsigned long long int) (unsigned long int) str : (unsigned long long int) str ));
  return ffi_ptr;
}

void Init_babeltrace_c() {
  m_babeltrace = rb_define_module("Babeltrace");
  m_ctf = rb_define_module_under(m_babeltrace, "CTF");
  m_internal = rb_define_module_under(m_ctf, "Internal");
  m_ffi = rb_const_get(rb_cObject, rb_intern("FFI"));
  c_ffi_pointer = rb_const_get(m_ffi, rb_intern("Pointer"));
  c_ffi_struct = rb_const_get(m_ffi, rb_intern("Struct"));
  c_definition = rb_define_class_under(m_babeltrace, "Definition", c_ffi_struct);
  c_declaration = rb_define_class_under(m_babeltrace, "Declaration", c_ffi_struct);
  c_internal_declaration = rb_define_class_under(m_internal, "Declaration", c_declaration);
  c_internal_definition = rb_define_class_under(m_internal, "Definition", c_definition);
  c_ctf_declaration = rb_define_class_under(m_ctf, "Declaration", rb_cObject);
  c_ctf_array_declaration = rb_define_class_under(m_ctf, "ArrayDecl", c_ctf_declaration);
  c_ctf_sequence_declaration = rb_define_class_under(m_ctf, "SequenceDecl", c_ctf_declaration);
  rb_define_method(c_ctf_array_declaration, "elem", babeltrace_ctf_array_decl_elem, 0);
  rb_define_method(c_ctf_sequence_declaration, "elem", babeltrace_ctf_sequence_decl_elem, 0);
  rb_define_method(c_internal_definition, "get_char_sequence", babeltrace_ctf_internal_definition_get_char_sequence, 0);
}
