type color = Ltltree.operand
type coloring = color Register.map

exception Found_george_criterion of Register.t * Register.t

let offset_spilled = ref (-8)
let nb_locals = ref 0

let get_spilled () =
  let offset = !offset_spilled in
  incr nb_locals;
  offset_spilled := !offset_spilled - 8;
  Ltltree.Spilled offset


module I = Interference
module RS = Register.S
module RM = Register.M

let k = RS.cardinal Register.allocatable


let rec color (uses : Register.t -> int) (ig : I.igraph) : coloring * int =
  offset_spilled := -8;
  nb_locals := 0;
  let coloring = simplify uses ig in
  (coloring, !nb_locals)


and find ig test =
  let bindings =
    RM.bindings ig
    |> List.filter (fun (r, arcs) -> Register.is_pseudo r && test arcs)
    |> List.sort (fun (_, arcs1) (_, arcs2) ->
           compare (RS.cardinal arcs1.I.intfs) (RS.cardinal arcs2.I.intfs))
  in
  try
    List.hd bindings
    |> fst
  with _ ->
    raise Not_found


and find_trivial_with_no_preference uses ig =
  find ig
    (fun arcs ->
      RS.cardinal arcs.I.prefs = 0
      && RS.cardinal arcs.I.intfs < k)


and find_trivial uses ig =
  find ig
    (fun arcs ->
      RS.cardinal arcs.I.intfs < k)


and simplify uses ig =
  try
    find_trivial_with_no_preference uses ig
    |> select uses ig
  with Not_found ->
    coalesce uses ig


and degree ig r =
  (RM.find r ig).I.intfs
  |> RS.cardinal


and find_george_criterion ig =
  let test intfs r =
    if Register.is_hw r then RS.mem r intfs
    else degree ig r < k || RS.mem r intfs
  in
  try
    RM.iter
      (fun r1 arcs ->
        if Register.is_pseudo r1 then
          let intfs_r1 = (RM.find r1 ig).I.intfs in
          RS.iter
            (fun r2 ->
              let intfs_r2 = (RM.find r2 ig).I.intfs in
              if RS.for_all (test intfs_r2) intfs_r1 then
                raise (Found_george_criterion (r1, r2))
            )
            arcs.I.prefs
      ) ig;
    raise Not_found
  with Found_george_criterion (r1, r2) ->
    (r1, r2)


and merge ig (r1: Register.t) r2 =
  let replace r arcs =
    let prefs = RS.remove r1 arcs.I.prefs in
    let intfs = RS.remove r1 arcs.I.intfs in
    { I.prefs = if RS.mem r1 arcs.I.prefs then RS.add r2 prefs else prefs;
      I.intfs = if RS.mem r1 arcs.I.intfs then RS.add r2 intfs else intfs }
  in
  let intfs_r1 = (RM.find r1 ig).I.intfs in
  let arcs_r2 = (RM.find r2 ig) in
  let arcs_r2' =
    { I.prefs = RS.remove r1 arcs_r2.I.prefs;
      I.intfs = RS.union arcs_r2.I.intfs intfs_r1 }
  in
  RM.fold
    (fun r arcs acc ->
      let arcs = replace r arcs in
      RM.add r arcs acc
    )
    (RM.remove r1 ig |> RM.remove r2)
    (RM.add r2 arcs_r2' RM.empty)


and choose_color ig coloring r =
  let already_used_colors =
    let intfs = (RM.find r ig).I.intfs in
    RS.fold
      (fun r' acc ->
        match RM.find_opt r' coloring with
        | Some (Ltltree.Reg reg) -> RS.add reg acc
        | _ -> acc
      )
      intfs
      (RS.filter Register.is_hw intfs)
  in
  try
    Register.allocatable
    |> RS.filter
         (fun r' ->
           not (RS.mem r' already_used_colors))
    |> RS.choose
  with _ ->
    raise Not_found


and coalesce uses ig =
  try
    let r1, r2 = find_george_criterion ig in
    let ig' = merge ig r1 r2 in
    let coloring = simplify uses ig' in
    let find_color r =
      if Register.is_hw r then Ltltree.Reg r
      else RM.find r coloring
    in
    RM.update r1 (fun _ -> Some (find_color r2)) coloring
  with Not_found ->
    freeze uses ig


and remove_preference ig r =
  RM.update r
    (function
     | None -> assert false
     | Some arcs ->
        Some { arcs with I.prefs = RS.empty })
    ig


and freeze uses ig =
  try
    find_trivial uses ig
    |> remove_preference ig
    |> simplify uses
  with Not_found ->
    spill uses ig


and minimal_cost uses ig =
  RM.bindings ig
  |> List.map
       (fun (r, arcs) ->
         let h =
           float_of_int (uses r)
           /. float_of_int (degree ig r)
         in
         h, r)
  |> List.sort compare
  |> List.hd
  |> snd


and spill uses ig =
  if RM.is_empty ig then
    RM.empty
  else
    minimal_cost uses ig
    |> select uses ig


and select uses ig r =
  let coloring =
    RM.remove r ig
    |> simplify uses
  in
  if Register.is_hw r then
    RM.add r (Ltltree.Reg r) coloring
  else
    try
      RM.add r
        (Ltltree.Reg (choose_color ig coloring r))
        coloring
    with Not_found ->
      RM.add r (get_spilled ()) coloring


open Format

let print_set = Register.print_set


let print_color fmt = function
  | Ltltree.Reg hr    -> fprintf fmt "%a" Register.print hr
  | Ltltree.Spilled n -> fprintf fmt "stack %d" n


let print_coloring fmt coloring =
  RM.iter
    (fun r cr -> fprintf fmt "%a -> %a@\n" Register.print r print_color cr) coloring


let print_graph fmt =
  Ertltree.visit
    (fun l i ->
      fprintf fmt "%a: %a *** %a@\n"
        Label.print l
        Ertltree.print_instr i
    )


let print_deffun fmt f =
  fprintf fmt "%s(%d)@\n" f.Ertltree.fun_name f.Ertltree.fun_formals;
  fprintf fmt "  @[";
  print_graph fmt f.Ertltree.fun_body f.Ertltree.fun_entry;
  let live_info_map = Liveness.analyze f.Ertltree.fun_body in
  print_coloring fmt
    (live_info_map
     |> I.make
     |> color (Liveness.uses live_info_map)
     |> fst
     |> RM.filter (fun r _ -> Register.is_pseudo r));
  fprintf fmt "@]@."


let print_file fmt p =
  fprintf fmt "=== COLORING =============================================@\n";
  List.iter (print_deffun fmt) p.Ertltree.funs
