type arcs = { prefs: Register.set; intfs: Register.set }
type igraph = arcs Register.map

module RS = Register.S
module RM = Register.M

let make (label_to_live_info : Liveness.live_info Label.map) : igraph =
  let graph = ref RM.empty in
  let add f r1 r2 =
    graph := RM.update r1 (f r2) !graph;
    graph := RM.update r2 (f r1) !graph;
  in
  let add_pref r1 r2 =
    add (fun r o ->
        match o with
        | None ->
           Some { prefs = RS.singleton r; intfs = RS.empty }

        | Some arc ->
           if RS.mem r arc.intfs then
             Some arc
           else
             Some { arc with prefs = RS.add r arc.prefs }
      ) r1 r2
  in
  let add_intf r1 r2 =
    add (fun r o ->
        match o with
        | None ->
           Some { prefs = RS.empty; intfs = RS.singleton r }

        | Some arc ->
           if RS.mem r arc.prefs then
             Some { prefs = RS.remove r arc.prefs;
                    intfs = RS.add r arc.intfs }
           else
             Some { arc with intfs = RS.add r arc.intfs }
      ) r1 r2
  in
  let add_intfs defs outs =
    let outs = RS.diff outs defs in
    RS.iter
      (fun r1 ->
        RS.iter (fun r2 -> add_intf r1 r2) outs
      )
      defs
  in
  Label.M.iter
    (fun _ live_info ->
      match live_info.Liveness.instr with
      | Embinop (Mmov, src, dest, _)
           when src <> dest ->
         add_pref src dest;
         add_intfs live_info.Liveness.defs
           (RS.remove src live_info.Liveness.outs)

      | instr ->
         add_intfs live_info.Liveness.defs
           live_info.Liveness.outs
    )
    label_to_live_info;
  !graph


let print_set = Register.print_set

open Format

let print_interference_graph fmt ig =
  RM.iter (fun r arcs ->
      fprintf fmt "%s: prefs=@[%a@] intfs=@[%a@]@." (r :> string)
        print_set arcs.prefs print_set arcs.intfs) ig


let print_live_info fmt li =
  fprintf fmt "d={%a} u={%a} i={%a} o={%a}"
    print_set li.Liveness.defs print_set li.Liveness.uses
    print_set li.Liveness.ins print_set li.Liveness.outs


let print_graph fmt live_info_map =
  Ertltree.visit
    (fun l i ->
      fprintf fmt "%a: %a *** %a@\n"
        Label.print l
        Ertltree.print_instr i
        print_live_info (Label.M.find l live_info_map)
    )


let print_deffun fmt f =
  fprintf fmt "%s(%d)@\n" f.Ertltree.fun_name f.Ertltree.fun_formals;
  fprintf fmt "  @[";
  fprintf fmt "entry : %a@\n" Label.print f.Ertltree.fun_entry;
  fprintf fmt "locals: @[%a@]@\n" Register.print_set f.Ertltree.fun_locals;
  let liveness = Liveness.analyze f.Ertltree.fun_body in
  print_graph fmt liveness f.Ertltree.fun_body f.Ertltree.fun_entry;
  fprintf fmt "@.";
  print_interference_graph fmt (make liveness);
  fprintf fmt "@]@."


let print_file fmt p =
  fprintf fmt "=== INTERFERENCE =========================================@\n";
  List.iter (print_deffun fmt) p.Ertltree.funs
