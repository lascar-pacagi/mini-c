type definition_info = {
    instr: Ertltree.instr;
    succ: Label.t list;      (* successeurs *)
    mutable pred: Label.set; (* prédécesseurs *)
    defs: Register.set;      (* définitions *)
    uses: Register.set;      (* utilisations *)
    mutable  ins: Register.set; (* définitions en entrée *)
    mutable outs: Register.set; (* définitions en sortie *)
  }
