open Ops

type ident = string

type unop = Ops.munop

type binop = Ops.mbinop

type expr =
  | Econst of int32
  | Eload of expr * int
  | Estore of expr * int * expr
  | Eaccess_local of ident
  | Eassign_local of ident * expr
  | Emunop of unop * expr
  | Embinop of binop * expr * expr
  | Ecall of ident * expr list
  | Eand of expr * expr
  | Eor  of expr * expr

type stmt =
  | Sskip
  | Sexpr of expr
  | Sif of expr * stmt * stmt
  | Swhile of expr * stmt
  | Sblock of ident list * stmt list
  | Sreturn of expr

and deffun = {
  fun_name   : ident;
  fun_formals: ident list;
  fun_locals : ident list;
  fun_body   : stmt list
}

type file = {
  funs: deffun list;
}
