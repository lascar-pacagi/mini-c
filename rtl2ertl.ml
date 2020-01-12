open Ertltree
open Ops

let graph = ref Label.M.empty


let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l


let binop op r1 r2 destl =
  Embinop (op, r1, r2, destl)


let binopg op r1 r2 destl =
  generate (binop op r1 r2 destl)


let unop op r destl =
  Emunop (op, r, destl)


let unopg op r destl =
  generate (unop op r destl)


let goto destl = Egoto destl


let assoc_formals formals =
  let rec assoc = function
    | []     , _       -> [], []
    | pl     , []      -> [], pl
    | p :: pl, r :: rl ->
       let a, pl = assoc (pl, rl) in
       (p, r) :: a, pl
  in
  assoc (formals, Register.parameters)


let move_formals_to_registers formal_to_reg destl =
  List.fold_right
    (fun (f, r) label -> binopg Mmov f r label)
    formal_to_reg
    destl

let rec push_remaining_formals formals destl =
  List.fold_right
    (fun p label -> generate (Epush_param (p, label)))
    (List.rev formals)
    destl


let call id n destl =
  generate (Ecall (id, n, destl))


let pop n destl =
  if n = 0 then destl
  else unopg (Maddi (Int32.of_int n)) Register.rsp destl


let rec instr (s : Rtltree.instr) : instr =
  match s with
  | Rtltree.Embinop (Mdiv, r1, r2, l) -> (* r2 / r1 -> r2 *)
     binop Mmov r2 Register.result
     @@ binopg Mdiv r1 Register.result
     @@ binopg Mmov Register.result r2 l

  | Rtltree.Ecall (ret, id, formals, l) ->
     let formal_to_reg, remaining_formals =
       assoc_formals formals
     in
     let n = List.length formal_to_reg in
     goto
     @@ move_formals_to_registers formal_to_reg
     @@ push_remaining_formals remaining_formals
     @@ call id n
     @@ binopg Mmov Register.result ret
     @@ pop (Memory.word_size * List.length remaining_formals) l

  | Rtltree.Econst (i, r, label) ->
     Econst (i, r, label)

  | Rtltree.Eload (addr_reg, offset, dst, label) ->
     Eload (addr_reg, offset, dst, label)

  | Rtltree.Estore (src, addr_reg, offset, label) ->
     Estore (src, addr_reg, offset, label)

  | Rtltree.Emunop (op, reg, label) ->
     Emunop (op, reg, label)

  | Rtltree.Embinop (op, r1, r2, label) ->
     Embinop (op, r1, r2, label)

  | Rtltree.Emubranch (b, reg, truel, falsel) ->
     Emubranch (b, reg, truel, falsel)

  | Rtltree.Embbranch (b, r1, r2, truel, falsel) ->
     Embbranch (b, r1, r2, truel, falsel)

  | Rtltree.Egoto label ->
     Egoto label


let alloc_frame destl =
  generate (Ealloc_frame destl)


let save_callee_saved_registers savers destl =
  List.fold_right
    (fun (reg, tmp) label -> binopg Mmov reg tmp label)
    savers
    destl


let get_params_from_regs formal_to_reg destl =
  List.fold_right
    (fun (f, r) label -> binopg Mmov r f label)
    formal_to_reg
    destl


let get_param formal offset destl =
  generate (Eget_param (offset, formal, destl))


let get_params_from_stack offset remaining_formals destl =
    List.fold_left
      (fun label f ->
        let ofs = !offset in
        offset := !offset + Memory.word_size;
        get_param f ofs label)
      destl
      remaining_formals


let fun_entry savers formals entry =
  let formal_to_reg, remaining_formals = assoc_formals formals in
  let offset = ref (2 * Memory.word_size) in
  alloc_frame
  @@ save_callee_saved_registers savers
  @@ get_params_from_regs formal_to_reg
  @@ get_params_from_stack offset remaining_formals entry


let restore_callee_saved_registers savers destl =
  List.fold_right
    (fun (reg, tmp) label -> binopg Mmov tmp reg label)
    savers
    destl

let delete_frame destl =
  generate (Edelete_frame destl)


let fun_exit savers retr exitl =
  let epilog =
    binopg Mmov retr Register.result
    @@ restore_callee_saved_registers savers
    @@ delete_frame
    @@ generate Ereturn
  in
  graph := Label.M.add exitl (Egoto epilog) !graph


let deffun (f : Rtltree.deffun) : deffun =
  graph := Label.M.empty;
  Label.M.iter
    (fun l i -> graph := Label.M.add l i !graph)
    (Label.M.map instr f.Rtltree.fun_body);
  let savers =
    List.map (fun r -> r, Register.fresh()) Register.callee_saved
  in
  let entry =
    fun_entry savers f.Rtltree.fun_formals f.Rtltree.fun_entry
  in
  fun_exit savers f.Rtltree.fun_result f.Rtltree.fun_exit;
  {
    fun_name    = f.Rtltree.fun_name;
    fun_formals = List.length f.Rtltree.fun_formals;
    fun_locals  = Register.S.union
                    (Register.set_of_list (List.map snd savers))
                    f.Rtltree.fun_locals;
    fun_entry   = entry;
    fun_body    = !graph;
  }

let program (p : Rtltree.file) : file =
  {
    funs = List.map deffun p.Rtltree.funs
  }
