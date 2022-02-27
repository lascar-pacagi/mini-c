open Integer
open Istree
open Ops

let rec pure (e : expr) : bool =
  match e with
  | Econst _
  | Eload _
  | Eaccess_local _ ->
     true

  | Emunop (_, e) ->
     pure e

  | Eand (e1, e2)
  | Eor (e1, e2)
  | Embinop (_, e1, e2) ->
     pure e1 && pure e2

  | _ ->
     false


let rec mk_add (e1 : expr) (e2 : expr) : expr =
  match e1, e2 with
  | Econst i1, Econst i2 ->
      Econst (i1 + i2)

  | Econst 0l, e
  | e, Econst 0l ->
     e

  | Emunop (Maddi i1, e1), Emunop (Maddi i2, e2) ->
      Emunop (Maddi (i1 + i2), mk_add e1 e2)

  | e1, Emunop (Maddi i, e2)
  | Emunop (Maddi i, e1), e2 ->
      Emunop (Maddi i, mk_add e1 e2)

  | Embinop (Msub, Econst 0l, e1), Embinop (Msub, Econst 0l, e2) ->
      Embinop (Msub, Econst 0l, mk_add e1 e2)

  | e1, Embinop (Msub, Econst 0l, e2) ->
      mk_sub e1 e2

  | Embinop (Msub, Econst 0l, e1), e2
       when pure e1 && pure e2 ->
     mk_sub e2 e1

  | e1, e2 ->
      Embinop (Madd, e1, e2)


and mk_sub (e1 : expr) (e2 : expr) : expr =
  match e1, e2 with
  | Econst i1, Econst i2 ->
      Econst (i1 - i2)

  | Econst i1, Emunop (Maddi i2, e) ->
      mk_sub (Econst (i1 - i2)) e

  | Emunop (Maddi i1, e), Econst i2 ->
      mk_add (Econst (i1 - i2)) e

  | e, Econst 0l ->
      e

  | Econst i, e
       when i <> 0l ->
     Emunop (Maddi i, Embinop (Msub, Econst 0l, e))

  | e, Econst i ->
     Emunop (Maddi (-i), e)

  | Emunop (Maddi i1, e1), Emunop (Maddi i2, e2) ->
     Emunop (Maddi (i1 - i2), mk_sub e1 e2)

  | e1, Emunop (Maddi i, e2) ->
     Emunop (Maddi (-i), mk_sub e1 e2)

  | Emunop (Maddi i, e1), e2 ->
      Emunop (Maddi i, mk_sub e1 e2)

  | Embinop (Msub, Econst 0l, e1), Embinop (Msub, Econst 0l, e2) ->
      mk_neg (mk_sub e1 e2)

  | e1, Embinop (Msub, Econst 0l, e2) ->
      mk_add e1 e2

  | Embinop (Msub, Econst 0l, e1), e2 ->
      mk_neg (mk_add e1 e2)

  | Econst 0l, Embinop (Msub, e1, e2)
       when pure e1 && pure e2 ->
     mk_sub e2 e1

  | e1, e2 ->
     Embinop (Msub, e1, e2)


and mk_neg (e : expr) : expr =
  mk_sub (Econst 0l) e

(* let mksll i1 e =
 *   match e with
 *   | Emunop (Mslli i2, e) ->
 *      Emunop (Mslli (i1 + i2), e)
 *
 *   | e ->
 *      Emunop (Mslli i1, e) *)


let rec mk_mul (e1 : expr) (e2 : expr) =
  match e1, e2 with
  | Econst i1, Econst i2 ->
      Econst (i1 * i2)

  | _, Econst _ ->
     mk_mul e2 e1

  | Econst 0l, e
       when pure e ->
     Econst 0l

  | Econst 1l, e ->
     e

  | Econst (-1l), e ->
     mk_neg e

  | Econst i1, Emunop (Maddi i2, e) ->
     Emunop (Maddi (i1 * i2), mk_mul (Econst i1) e)

  | Embinop (Mmul, Econst i1, e1), Embinop (Mmul, Econst i2, e2) ->
      mk_mul (Econst (i1 * i2)) (mk_mul e1 e2)

  | Econst i1, Embinop (Mmul, Econst i2, e) ->
      mk_mul (Econst (i1 * i2)) e

  (* | Econst i, e
   *      when is_power_of_two i ->
   *    mksll (log2 i) e *)

  (* | Econst i1, Emunop (Mslli i2, e) ->
   *    mk_mul (Econst (i1 * exp2 i2)) e *)

  | _, _ ->
     Embinop (Mmul, e1, e2)


let mk_div (e1 : expr) (e2 : expr) : expr =
  match e1, e2 with
  | Econst i1, Econst i2 when i2 <> 0l ->
     Econst (i1 / i2)

    (* One could invent more rules. For instance, one could exploit the
       properties of [0], [1], and [-1] with respect to division. One could
       notice that dividing by a power of [2] is equivalent to an arithmetic
       shift towards the right (that is, a shift operation that preserves the
       sign bit). One could also attempt to exploit the fact that [x / (y * z)]
       is equal to [x / y / z]. I did not try to write down every possible
       law. *)

  | _, _ ->
     Embinop (Mdiv, e1, e2)


let b2i : bool -> int32 = function
  | true ->
     1l
  | false ->
     0l


let bop2iop (op : int32 -> int32 -> bool) (i1 : int32) (i2 : int32) : int32 =
  b2i (op i1 i2)


let evaluate_cmp : binop -> (int32 -> int32 -> int32) = function
  | Msete ->
     bop2iop (=)

  | Msetne ->
     bop2iop (<>)

  | Msetl ->
     bop2iop (<)

  | Msetle ->
     bop2iop (<=)

  | Msetg ->
     bop2iop (>)

  | Msetge ->
     bop2iop (>=)

  | _ -> assert false


let rec mk_cmp (op : binop) (e1 : expr) (e2 : expr) : expr =
  match op, e1, e2 with
  | _, Econst i1, Econst i2 ->
     Econst (evaluate_cmp op i1 i2)

  | Msete, Econst i, e
  | Msete, e, Econst i ->
     Emunop (Msetei i, e)

  | Msetne, Econst i, e
  | Msetne, e, Econst i ->
     Emunop (Msetnei i, e)

  | Msetle, _, Econst i2 ->
     Emunop (Msetlei i2, e1)

  | Msetle, Econst i1, _ ->
     Emunop (Msetgi i1, e2)

  | Msetg, _, Econst i2 ->
     Emunop (Msetgi i2, e1)

  | Msetg, Econst i1, _ ->
     Emunop (Msetlei i1, e2)

  | _ ->
     Embinop (op, e1, e2)

let mk_not : expr -> expr = function
  | Econst 0l ->
     Econst 1l

  | Econst _  ->
     Econst 0l

  | e ->
     mk_cmp Msete (Econst 0l) e

let ttree_cmp_to_istree_cmp = function
  | Ptree.Beq ->
     Msete

  | Ptree.Bneq ->
     Msetne

  | Ptree.Blt ->
     Msetl

  | Ptree.Ble ->
     Msetle

  | Ptree.Bgt ->
     Msetg

  | Ptree.Bge ->
     Msetge

  | _ -> assert false

open Stdlib

let rec expr (e : Ttree.expr) : expr =
  match e.Ttree.expr_node with
  | Ttree.Econst i ->
     Econst i

  | Ttree.Ebinop (Ptree.Badd, e1, e2) ->
     mk_add (expr e1) (expr e2)

  | Ttree.Ebinop (Ptree.Bsub, e1, e2) ->
     mk_sub (expr e1) (expr e2)

  | Ttree.Ebinop (Ptree.Bmul, e1, e2) ->
     mk_mul (expr e1) (expr e2)

  | Ttree.Ebinop (Ptree.Bdiv, e1, e2) ->
     mk_div (expr e1) (expr e2)

  | Ttree.Ebinop (Ptree.Band, e1, e2) ->
     Eand (expr e1, expr e2)

  | Ttree.Ebinop (Ptree.Bor, e1, e2) ->
     Eor (expr e1, expr e2)

  | Ttree.Ebinop (op, e1, e2) ->
     mk_cmp (ttree_cmp_to_istree_cmp op) (expr e1) (expr e2)

  | Ttree.Eunop (Ptree.Unot, e) ->
     mk_not (expr e)

  | Ttree.Eunop (Ptree.Uminus, e) ->
     mk_neg (expr e)

  | Ttree.Eaccess_local id ->
     Eaccess_local id

  | Ttree.Eassign_local (id, e) ->
     Eassign_local (id, expr e)

  | Ttree.Eaccess_field (e, field) ->
     Eload (expr e, field.Ttree.field_position * Memory.word_size)

  | Ttree.Eassign_field (e1, field, e2) ->
     Estore (expr e1,
             field.Ttree.field_position * Memory.word_size,
             expr e2)

  | Ttree.Ecall (id, args) ->
     Ecall (id, List.map expr args)

  | Ttree.Esizeof structure ->
     Econst (Int32.of_int (structure.Ttree.str_size * Memory.word_size))


let rec stmt (s : Ttree.stmt) : stmt =
  match s with
  | Ttree.Sskip ->
     Sskip

  | Ttree.Sexpr e ->
     Sexpr (expr e)

  | Ttree.Sif (e, s1, s2) ->
     Sif (expr e, stmt s1, stmt s2)

  | Ttree.Swhile (e, s) ->
     Swhile (expr e, stmt s)

  | Ttree.Sblock (decl_vars, stmts) ->
     Sblock (List.map snd decl_vars, List.map stmt stmts)

  | Ttree.Sreturn e ->
     Sreturn (expr e)


let decl_fun (decl_fun : Ttree.decl_fun) : deffun =
  match decl_fun with
  | {
      Ttree.fun_name = name;
      Ttree.fun_formals = formals;
      Ttree.fun_body = (decl_vars, stmts)
    } ->
     {
       fun_name    = name;
       fun_formals = List.map snd formals;
       fun_locals  = List.map snd decl_vars;
       fun_body    = List.map stmt stmts
     }


let program (file : Ttree.file) : file =
  match file with
  | { Ttree.funs = decl_funs } ->
     {
       funs = List.map decl_fun decl_funs
     }
