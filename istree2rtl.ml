open Rtltree
open Ops

type register = Register.t

let graph = ref Label.M.empty
let locals = Hashtbl.create 53

let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l

let rec expr (destr : register) (e : Istree.expr) (destl : label) : label =
  match e with
  | Istree.Econst n ->
     generate (Econst (n, destr, destl))

  | Istree.Embinop (op, e1, e2) ->
     let tmp = Register.fresh () in
     expr destr e1
     @@ expr tmp e2
     @@ generate (Embinop (op, tmp, destr, destl))

  | Istree.Emunop (op, e) ->
     expr destr e
     @@ generate (Emunop (op, destr, destl))

  | Istree.Eaccess_local x ->
     let rx = Hashtbl.find locals x in
     generate (Embinop (Mmov, rx, destr, destl))

  | Istree.Eassign_local (x, e) ->
     let rx = Hashtbl.find locals x in
     expr rx e
     @@ generate (Embinop (Mmov, rx, destr, destl))

  | Istree.Eload (addr, offset) ->
     let tmp = Register.fresh () in
     expr tmp addr
     @@ generate (Eload (tmp, offset, destr, destl))

  | Istree.Estore (addr, offset, src) ->
     let tmp = Register.fresh () in
     expr tmp addr
     @@ expr destr src
     @@ generate (Estore (destr, tmp, offset, destl))

  | Istree.Ecall (id, exprs) ->
     if exprs = [] then
       generate (Ecall (destr, id, [], destl))
     else begin
       let entry_fun = Label.fresh () in
       let params =
         List.map (fun _ -> Register.fresh ()) exprs
       in
       let setup_params =
         List.fold_right2
           (fun e r label ->
             expr r e label)
           exprs
           params
           entry_fun
       in
       graph := Label.M.add entry_fun (Ecall (destr, id, params, destl)) !graph;
       setup_params
       end

  | Istree.Eand (e1, e2) ->
     let falsel =
       expr destr (Istree.Econst 0l) destl
     in
     let truel =
       expr destr (Istree.Econst 1l) destl
     in
     condition e1 (condition e2 truel falsel) falsel

  | Istree.Eor (e1, e2) ->
     let falsel =
       expr destr (Istree.Econst 0l) destl
     in
     let truel =
       expr destr (Istree.Econst 1l) destl
     in
     condition e1 truel (condition e2 truel falsel)


and mbinop_to_mbbranch = function
  | Msetle ->
     Mjle

  | Msetl  ->
     Mjl

  | _      ->
     failwith "mbinop_to_mbbranch: not supported"


and munop_to_mubranch = function
  | Msetlei n ->
     Mjlei n

  | Msetgi n  ->
     Mjgi n

  | _      ->
     failwith "munop_to_mubranch: not supported"


and condition (e : Istree.expr) (truel : label) (falsel : label) : label =
  match e with
  | Istree.Eand (e1, e2) ->
     condition e1 (condition e2 truel falsel) falsel

  | Istree.Eor (e1, e2) ->
     condition e1 truel (condition e2 truel falsel)

  | Istree.Embinop (Msetle | Msetl as op, e1, e2) ->
     let tmp1 = Register.fresh () in
     let tmp2 = Register.fresh () in
     expr tmp1 e1
     @@ expr tmp2 e2
     @@ generate (Embbranch (mbinop_to_mbbranch op, tmp2, tmp1, truel, falsel))

  | Istree.Emunop (Msetlei n | Msetgi n as op, e) ->
     let tmp = Register.fresh () in
     expr tmp e
     @@ generate (Emubranch (munop_to_mubranch op, tmp, truel, falsel))

  | e ->
     let tmp = Register.fresh () in
     expr tmp e
     @@ generate (Emubranch (Mjz, tmp, falsel, truel))


let all_locals = ref Register.S.empty


let rec instr (retr : register) (s : Istree.stmt) (exitl : label) (destl : label) : label =
  match s with
  | Istree.Sskip ->
     destl

  | Istree.Sexpr e ->
     expr (Register.fresh ()) e destl

  | Istree.Sif (e, s1, s2) ->
     condition e
       (instr retr s1 exitl destl)
       (instr retr s2 exitl destl)

  | Istree.Swhile (e, s) ->
     let l = Label.fresh () in
     let entry = condition e (instr retr s exitl l) destl in
     graph := Label.M.add l (Egoto entry) !graph;
     entry

  | Istree.Sblock (decls, stmts) ->
     let local_reg_assoc =
       List.map (fun id -> id, Register.fresh ()) decls
     in
     List.iter (fun (id, reg) ->
         Hashtbl.add locals id reg;
         all_locals := Register.S.add reg !all_locals)
       local_reg_assoc;
     let entry =
       List.fold_right
         (fun stmt label -> instr retr stmt exitl label)
         stmts
         destl
     in
     List.iter (fun (id, _) -> Hashtbl.remove locals id) local_reg_assoc;
     entry

  | Istree.Sreturn e ->
     expr retr e exitl


let deffun (deffun : Istree.deffun) : deffun =
  match deffun with
  | {
       Istree.fun_name    = name;
       Istree.fun_formals = formals;
       Istree.fun_locals  = fun_locals;
       Istree.fun_body    = stmts
    } ->
     let retr   = Register.fresh () in
     let exitl  = Label.fresh () in
     graph := Label.M.empty;
     Hashtbl.clear locals;
     let formal_reg_assoc =
       List.map (fun id -> id, Register.fresh ()) formals
     in
     List.iter (fun (id, reg) -> Hashtbl.add locals id reg) formal_reg_assoc;
     let local_reg_assoc =
       List.map (fun id -> id, Register.fresh ()) fun_locals
     in
     List.iter (fun (id, reg) -> Hashtbl.add locals id reg) local_reg_assoc;
     all_locals :=
       List.map snd local_reg_assoc
       |> Register.set_of_list;
     let entryl =
       List.fold_right
         (fun stmt label -> instr retr stmt exitl label)
         stmts
         exitl
     in
     {
       fun_name    = name;
       fun_formals = List.map snd formal_reg_assoc;
       fun_result  = retr;
       fun_locals  = !all_locals;
       fun_entry   = entryl;
       fun_exit    = exitl;
       fun_body    = !graph;
     }


let program (file : Istree.file) : file =
  match file with
  | { Istree.funs = deffuns } ->
     {
       funs = List.map deffun deffuns
     }
