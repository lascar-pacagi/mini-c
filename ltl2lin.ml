open Ltltree
open X86_64
open Ops

let visited = Hashtbl.create 53


type instr = Code of X86_64.text | Label of Label.t


let code = ref []


let emit l i = code := Code i :: Label l :: !code


let emit_wl i = code := Code i :: !code


let labels = Hashtbl.create 53


let need_label l = Hashtbl.add labels l ()


let register (r : Register.t) =
  match (r :> string) with
  | "%rax" -> rax
  | "%rbx" -> rbx
  | "%rcx" -> rcx
  | "%rdx" -> rdx
  | "%rdi" -> rdi
  | "%rsi" -> rsi
  | "%rbp" -> rbp
  | "%rsp" -> rsp
  | "%r8"  -> r8
  | "%r9"  -> r9
  | "%r10" -> r10
  | "%r11" -> r11
  | "%r12" -> r12
  | "%r13" -> r13
  | "%r14" -> r14
  | "%r15" -> r15
  | _ -> assert false


let r64_to_r8 (r : Register.t) =
  match (r :> string) with
  | "%rax" -> al
  | "%rbx" -> bl
  | "%rcx" -> cl
  | "%rdx" -> dl
  | "%rdi" -> dil
  | "%rsi" -> sil
  | "%rbp" -> bpl
  | "%rsp" -> spl
  | "%r8"  -> r8b
  | "%r9"  -> r9b
  | "%r10" -> r10b
  | "%r11" -> r11b
  | "%r12" -> r12b
  | "%r13" -> r13b
  | "%r14" -> r14b
  | "%r15" -> r15b
  | _ -> assert false


let operand = function
  | Reg r -> reg (register r)
  | Spilled offset -> ind ~ofs:offset rbp


let operand8 = function
  | Reg r -> reg (r64_to_r8 r)
  | Spilled offset -> ind ~ofs:offset rbp


let rec lin g l =
  if not (Hashtbl.mem visited l) then
    begin
      Hashtbl.add visited l ();
      instr g l (Label.M.find l g)
    end
  else
    begin
      need_label l;
      emit_wl (jmp (l :> string))
    end

and munop op r =
  let r8 = operand8 r in
  let r = operand r in
  let zero = imm32 Int32.zero in
  match op with
  | Maddi n   -> addq (imm32 n) r
  | Msetei n  -> cmpq (imm32 n) r ++ movq zero r ++ sete r8
  | Msetnei n -> cmpq (imm32 n) r ++ movq zero r ++ setne r8
  | Msetlei n -> cmpq (imm32 n) r ++ movq zero r ++ setle r8
  | Msetgi n  -> cmpq (imm32 n) r ++ movq zero r ++ setg r8


and mbinop op r1 r2 =
  let r8 = operand8 r2 in
  let r1 = operand r1 in
  let r2 = operand r2 in
  let zero = imm32 Int32.zero in
  match op with
  | Mmov   -> movq r1 r2
  | Madd   -> addq r1 r2
  | Msub   -> subq r1 r2
  | Mmul   -> imulq r1 r2
  | Mdiv   -> cqto ++ idivq r1
  | Msete  -> cmpq r1 r2 ++ movq zero r2 ++ sete r8
  | Msetne -> cmpq r1 r2 ++ movq zero r2 ++ setne r8
  | Msetl  -> cmpq r1 r2 ++ movq zero r2 ++ setl r8
  | Msetle -> cmpq r1 r2 ++ movq zero r2 ++ setle r8
  | Msetg  -> cmpq r1 r2 ++ movq zero r2 ++ setg r8
  | Msetge -> cmpq r1 r2 ++ movq zero r2 ++ setge r8


and mubranch br r (l : Label.t) =
  let r = operand r in
  let l = (l :> string) in
  match br with
  | Mjz     -> testq r r ++ jz l
  | Mjnz    -> testq r r ++ jnz l
  | Mjlei n -> cmpq (imm32 n) r ++ jle l
  | Mjgi n  -> cmpq (imm32 n) r ++ jg l


and inv_mubranch = function
  | Mjz     -> Mjnz
  | Mjnz    -> Mjz
  | Mjlei n -> Mjgi n
  | Mjgi n  -> Mjlei n


and mbbranch br r1 r2 (l : Label.t) =
  let r1 = operand r1 in
  let r2 = operand r2 in
  let l = (l :> string) in
  match br with
  | Mjl  -> cmpq r1 r2 ++ jl l
  | Mjle -> cmpq r1 r2 ++ jle l


and instr g l = function
  | Econst (n, r, l') ->
     emit l (movq (imm32 n) (operand r));
     lin g l'

  | Emunop (op, r, l') ->
     emit l (munop op r);
     lin g l'

  | Embinop (op, r1, r2, l') ->
     emit l (mbinop op r1 r2);
     lin g l'

  | Eload (addr_reg, offset, dst, l') ->
     emit l (movq (ind ~ofs:offset (register addr_reg)) (reg (register dst)));
     lin g l'

  | Estore (src, addr_reg, offset, l') ->
     emit l (movq (reg (register src)) (ind ~ofs:offset (register addr_reg)));
     lin g l'

  | Epush (r, l') ->
     emit l (pushq (operand r));
     lin g l'

  | Epop (r, l') ->
     emit l (popq (register r));
     lin g l'

  | Emubranch (br, r, lt, lf)
       when not (Hashtbl.mem visited lf) ->
     need_label lt;
     emit l (mubranch br r lt);
     lin g lf;
     lin g lt

  | Emubranch (br, r, lt, lf)
       when not (Hashtbl.mem visited lt) ->
     instr g l (Emubranch (inv_mubranch br, r, lf, lt))

  | Emubranch (br, r, lt, lf) ->
     need_label lt;
     need_label lf;
     emit l (mubranch br r lt);
     emit l (jmp (lf :> string))

  | Embbranch (br, r1, r2, lt, lf)
       when not (Hashtbl.mem visited lf) ->
     need_label lt;
     emit l (mbbranch br r1 r2 lt);
     lin g lf;
     lin g lt

  (* | Embbranch (br, r1, r2, lt, lf)
   *      when not (Hashtbl.mem visited lt) ->
   *    instr g l (Emubranch (inv_mbbranch br, r1, r2, lf, lt)) *)

  | Embbranch (br, r1, r2, lt, lf) ->
     need_label lt;
     need_label lf;
     emit l (mbbranch br r1 r2 lt);
     emit l (jmp (lf :> string))

  | Egoto l' ->
     if Hashtbl.mem visited l' then
       begin
         need_label l';
         emit l (jmp (l' :> string))
       end
     else
       begin
         emit l nop;
         lin g l'
       end

  | Ecall (id, l') ->
     emit l (call (id :> string));
     lin g l'

  | Ereturn ->
     emit l ret


let instr_to_code = function
  | Code i  -> i
  | Label l -> label (l :> string)

let deffun f =
  code := [];
  Hashtbl.clear visited;
  Hashtbl.clear labels;
  if f.fun_name = "main" then
    emit_wl (globl "main");
  emit_wl (label (f.fun_name :> string));
  lin f.fun_body f.fun_entry;
  List.filter
    (function
     | Label l -> Hashtbl.mem labels l
     | _       -> true)
    !code
  |> List.map instr_to_code
  |> List.fold_left
       (fun acc i -> i ++ acc)
       nop

let program p =
  { text =
      List.rev p.funs
      |> List.fold_left
           (fun acc f ->
             deffun f ++ acc)
           nop;
    data = nop;
  }
