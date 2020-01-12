type live_info = {
    instr: Ertltree.instr;
    succ: Label.t list;      (* successeurs *)
    mutable pred: Label.set; (* prédécesseurs *)
    defs: Register.set;      (* définitions *)
    uses: Register.set;      (* utilisations *)
    mutable  ins: Register.set; (* variables vivantes en entrée *)
    mutable outs: Register.set; (* variables vivantes en sortie *)
  }


module RS = Register.S
module LM = Label.M


let rec kildall
          (cfg : Ertltree.cfg)
          (working_set : Label.set)
          (label_to_live_info : live_info Label.map)
        : live_info Label.map =
  if Label.S.is_empty working_set then label_to_live_info
  else begin
      let label = Label.S.choose working_set in
      let live_info = LM.find label label_to_live_info in
      let old_ins = live_info.ins in

      live_info.outs <-
        List.fold_left
          (fun acc l ->
            (LM.find l label_to_live_info).ins
            |> RS.union acc
          )
          RS.empty
          live_info.succ;

      live_info.ins  <-
        RS.diff live_info.outs live_info.defs
        |> RS.union live_info.uses;

      kildall
        cfg
        (if RS.equal old_ins live_info.ins then
           Label.S.remove label working_set
         else
           Label.S.union working_set live_info.pred)
        label_to_live_info
    end


let remove_dead_code (live_info_map : live_info Label.map)
    : live_info Label.map =
  LM.fold
  (fun label live_info acc ->
    let live_info =
      if not (RS.equal RS.empty live_info.defs) &&
           let inter = RS.inter live_info.outs live_info.defs in
           RS.equal inter RS.empty
      then
        { live_info with
          instr = Ertltree.Egoto (List.rev live_info.succ |> List.hd) }
      else live_info
    in
    LM.add label live_info acc
  )
  live_info_map
  LM.empty


let analyze (cfg : Ertltree.cfg) : live_info Label.map =
  let label_to_live_info = Hashtbl.create 271 in
  LM.iter
    (fun label instr ->
      let def, use = Ertltree.def_use instr in
      let li =
        {
          instr = instr;
          succ  = Ertltree.succ instr;
          pred  = Label.S.empty;
          defs  = Register.set_of_list def;
          uses  = Register.set_of_list use;
          ins   = RS.empty;
          outs  = RS.empty;
        }
      in
      Hashtbl.add label_to_live_info label li
    )
    cfg;

  Hashtbl.iter
    (fun label live_info ->
      List.iter
        (fun l ->
          let live_info' = Hashtbl.find label_to_live_info l in
          live_info'.pred <- Label.S.add label live_info'.pred
        )
        live_info.succ
    )
    label_to_live_info;

  kildall
    cfg
    (Hashtbl.fold
       (fun l i acc ->
         Label.S.add l acc
       )
       label_to_live_info
       Label.S.empty)
    (Hashtbl.fold
       LM.add
       label_to_live_info
       LM.empty)
  |> remove_dead_code


let uses live_info_map =
  let incr_count r map =
    Register.M.update r
      (function None   -> Some 0
              | Some v -> Some (v + 1))
      map
  in
  let m =
    LM.fold
      (fun l live_info res ->
        let res = RS.fold incr_count live_info.defs res in
        RS.fold incr_count live_info.uses res
      )
      live_info_map
      Register.M.empty
  in
  fun r -> Register.M.find r m


open Format

let print_set = Register.print_set


let print_live_info fmt li =
  fprintf fmt "d={%a} u={%a} i={%a} o={%a}"
    print_set li.defs print_set li.uses print_set li.ins print_set li.outs


let print_graph fmt live_info_map =
  Ertltree.visit
    (fun l i ->
      fprintf fmt "%a: %a *** %a@\n"
        Label.print l
        Ertltree.print_instr i
        print_live_info (LM.find l live_info_map)
    )


let print_deffun fmt f =
  fprintf fmt "%s(%d)@\n" f.Ertltree.fun_name f.Ertltree.fun_formals;
  fprintf fmt "  @[";
  fprintf fmt "entry : %a@\n" Label.print f.Ertltree.fun_entry;
  fprintf fmt "locals: @[%a@]@\n" Register.print_set f.Ertltree.fun_locals;
  print_graph fmt (analyze f.Ertltree.fun_body) f.Ertltree.fun_body f.Ertltree.fun_entry;
  fprintf fmt "@]@."


let print_file fmt p =
  fprintf fmt "=== LIVENESS =============================================@\n";
  List.iter (print_deffun fmt) p.Ertltree.funs
