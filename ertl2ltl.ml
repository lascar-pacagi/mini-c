open Ltltree
open Ops

let graph = ref Label.M.empty


let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l


type frame = {
    f_params: int; (* taille paramètres + adresse retour *)
    f_locals: int; (* taille variables locales *)
  }


let lookup = Register.M.find


let binop op r1 r2 destl =
  Embinop (op, r1, r2, destl)


let binopg op r1 r2 destl =
  generate (binop op r1 r2 destl)


let unop op r destl =
  Emunop (op, r, destl)


let unopg op r destl =
  generate (unop op r destl)


let push r destl =
  Epush (r, destl)


let popg r destl =
  generate (Epop (r, destl))


let write coloring r label =
  match lookup r coloring with
  | Reg hw ->
     hw, label

  | Spilled offset ->
     (Register.tmp2,
      binopg Mmov (Reg Register.tmp2) (Spilled offset) label)


let read1 coloring r f =
  match lookup r coloring with
  | Reg hw ->
     f hw

  | Spilled offset ->
     binop Mmov (Spilled offset) (Reg Register.tmp1)
     @@ generate (f Register.tmp1)


let read2 coloring r1 r2 f =
  match lookup r1 coloring with
  | Reg hw1 ->
     read1 coloring r2 (fun hw2 -> f hw1 hw2)

  | Spilled offset ->
     binop Mmov (Spilled offset) (Reg Register.tmp2)
     @@ generate (read1 coloring r2
                    (fun hw2 -> f Register.tmp2 hw2))


let instr coloring frame = function
  | Ertltree.Econst (n, r, label) ->
     Econst (n, lookup r coloring, label)

  | Ertltree.Eload (addr_reg, offset, dst, label) ->
     read1 coloring addr_reg
       (fun hw1 ->
         let hw2, label = write coloring dst label in
         Eload (hw1, offset, hw2, label))

  | Ertltree.Estore (src, addr_reg, offset, label) ->
     read2 coloring src addr_reg
       (fun hw1 hw2 ->
         Estore (hw1, hw2, offset, label))

  | Ertltree.Embinop (op, r1, r2, label) ->
     begin
       match op, lookup r1 coloring, lookup r2 coloring with
       | Mmov, o1, o2 when o1 = o2 ->
          Egoto label

       | Mmov, (Spilled _), (Spilled _ as o2) ->
          read1 coloring r1
            (fun hw -> binop Mmov (Reg hw) o2 label)

       |  _, (Spilled _ as o1), (Spilled _ as o2)
       | Mmul, o1, (Spilled _ as o2) ->
          read1 coloring r2
            (fun hw2 ->
              binop op o1 (Reg hw2)
              @@ binopg Mmov (Reg hw2) o2 label)


       | _, o1, o2 ->
          binop op o1 o2 label
     end

  | Ertltree.Emunop (op, r, label) ->
     unop op (lookup r coloring) label

  | Ertltree.Emubranch (b, r, truel, falsel) ->
     Emubranch (b, lookup r coloring, truel, falsel)

  | Ertltree.Embbranch (b, r1, r2, truel, falsel) ->
     Embbranch (b, lookup r1 coloring, lookup r2 coloring, truel, falsel)

  | Ertltree.Egoto label ->
     Egoto label

  | Ertltree.Ecall (id, n, label) ->
     Ecall (id, label)

  | Ertltree.Eget_param (offset, r, label) ->
     let hw, destl = write coloring r label in
     binop Mmov (Spilled offset) (Reg hw) destl

  | Ertltree.Epush_param (r, label) ->
     Epush (lookup r coloring, label)

  | Ertltree.Ealloc_frame label
    when frame.f_params = 0 && frame.f_locals = 0 ->
     Egoto label

  | Ertltree.Ealloc_frame label
       when frame.f_locals = 0 ->
     push (Reg Register.rbp)
     @@ binopg Mmov (Reg Register.rsp) (Reg Register.rbp) label

  | Ertltree.Ealloc_frame label ->
     let n =
       Int32.of_int frame.f_locals
       |> Int32.neg
     in
     push (Reg Register.rbp)
     @@ binopg Mmov (Reg Register.rsp) (Reg Register.rbp)
     @@ unopg (Maddi n) (Reg Register.rsp) label

  | Ertltree.Edelete_frame label
       when frame.f_params = 0 && frame.f_locals = 0 ->
     Egoto label

  | Ertltree.Edelete_frame label ->
     binop Mmov (Reg Register.rbp) (Reg Register.rsp)
     @@ popg (Register.rbp) label

  | Ertltree.Ereturn ->
     Ereturn


let deffun f =
  let live_info_map =
    Liveness.analyze f.Ertltree.fun_body
  in
  let coloring, nlocals =
    live_info_map
    |> Interference.make
    |> Coloring.color (Liveness.uses live_info_map)
  in
  let n_stack_params =
    max 0 (f.fun_formals - List.length Register.parameters)
  in
  let frame =
    { f_params =
        if n_stack_params = 0 then 0
        else Memory.word_size * (1 + n_stack_params);
      f_locals = Memory.word_size * nlocals }
  in
  graph := Label.M.empty;
  Label.M.mapi
    (fun l i ->
      (Label.M.find l live_info_map).Liveness.instr)
    f.fun_body
  |> Label.M.iter
       (fun l i ->
         let i = instr coloring frame i in
         graph := Label.M.add l i !graph);
  { fun_name  = f.Ertltree.fun_name;
    fun_entry = f.Ertltree.fun_entry;
    fun_body  = !graph; }


let program p = { funs = List.map deffun p.Ertltree.funs }
