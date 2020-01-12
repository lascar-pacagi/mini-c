open Ttree
open Printf

type function_type = typ * typ list

type structure_env = structure StringMap.t

type function_env = function_type StringMap.t

type variable_env = typ StringMap.t

type environments =
  {
    senv : structure_env;
    fenv : function_env;
    venv : variable_env
  }

exception Error of string

let error (location : Ptree.loc) (msg : string) =
  let positions = Error.positions (fst location) (snd location) in
  raise (Error (sprintf "%s:\n%s" positions msg))

let errors (locations : Ptree.loc list) (msg : string) =
  let all_positions =
    List.fold_right
      (fun location acc ->
        let positions = Error.positions (fst location) (snd location) in
        sprintf "%s:\n%s" positions acc)
      locations ""
  in
  raise (Error (sprintf "%s%s" all_positions msg))

let content { Ptree.id = id } = id

let location { Ptree.id_loc = id_loc } = id_loc

let already_defined_error id =
  error (location id) ((content id) ^ " is already defined")

let lookup (thing : string) (id : Ptree.ident) (env : 'a StringMap.t) =
  try
    StringMap.find (content id) env
  with Not_found ->
    error (location id) (sprintf "%s %s is undefined" thing (content id))

let structure_lookup = lookup "structure"

let function_lookup = lookup "function"

let variable_lookup = lookup "variable"

let field_lookup structure_id field_id str_fields =
  try
    Hashtbl.find str_fields (content field_id)
  with Not_found ->
    error (location field_id)
      (sprintf "field %s is undefined in structure %s"
         (content field_id) structure_id)

let string_of_type = function
  | Tint       -> "int"
  | Tstructp x -> sprintf "struct %s *" x.str_name
  | Tvoidstar  -> "void*"
  | Ttypenull  -> "typenull"

let check_uniqueness idents =
  if List.length idents <> 0 then begin
      let sorted_idents =
        List.sort (fun x y -> compare (content x) (content y)) idents
      in
      let rec find_double prev = function
        | [] -> ()
        | id :: r ->
           if content prev = content id then
             errors [location prev; location id]
               (sprintf "identifier %s must be unique" (content id))
           else
             find_double id r
      in
      find_double (List.hd sorted_idents) (List.tl sorted_idents)
    end

let compatible t1 t2 =
  match t1, t2 with
  | Tstructp s1, Tstructp s2 -> s1.str_name = s2.str_name
  | Ttypenull, (Tint | Tstructp _)
  | (Tint | Tstructp _), Ttypenull -> true
  | Tvoidstar, Tstructp _
  | Tstructp _, Tvoidstar -> true
  | _ -> t1 = t2

let check_compatibility t1 t2 loc =
  if not (compatible t1 t2) then begin
      error loc (sprintf "types %s and %s are not compatible"
                   (string_of_type t1)
                   (string_of_type t2))
    end

let ptree_type_to_ttree_type senv = function
  | Ptree.Tint -> Tint
  | Ptree.Tstructp id -> Tstructp (structure_lookup id senv)

let typing_struct envs id fields =
  if StringMap.mem (content id) envs.senv then already_defined_error id;
  let str_fields = Hashtbl.create 53 in
  let structure = {
      str_name = (content id);
      str_fields = str_fields;
      str_size = List.length fields
    }
  in
  let position = ref 0 in
  List.iter
    (fun (typ, id') ->
      if Hashtbl.mem str_fields (content id') then already_defined_error id';
      Hashtbl.add str_fields (content id')
        {
          field_name = content id';
          field_typ =
            (match typ with
             | Ptree.Tstructp i when content i = content id ->
                Tstructp structure
             | _ -> ptree_type_to_ttree_type envs.senv typ);
          field_position =
            let p = !position in
            position := !position + 1;
            p
        }
    )
    fields;
  let senv' =
    StringMap.add
      (content id)
      structure
      envs.senv
  in
  { envs with senv = senv' }

let rec typing_expr envs { Ptree.expr_node = expr;
                           Ptree.expr_loc = loc } =
  match expr with
  | Ptree.Econst i ->
     { expr_node = Econst i;
       expr_typ = if i = 0l then Ttypenull else Tint }

  | Ptree.Eright (Ptree.Lident id) ->
     { expr_node = Eaccess_local (content id);
       expr_typ = variable_lookup id envs.venv }

  | Ptree.Eright (Ptree.Larrow (e, id)) -> begin
     let e' = typing_expr envs e in
     match e'.expr_typ with
     | Tstructp structure ->
        let field =
          field_lookup structure.str_name id structure.str_fields
        in
        { expr_node = Eaccess_field (e', field);
          expr_typ = field.field_typ }
     | _ -> error loc "struct * expected"
    end

  | Ptree.Eassign (Ptree.Lident id, e) ->
     let e' = typing_expr envs e in
     let typ = variable_lookup id envs.venv in
     check_compatibility typ e'.expr_typ (location id);
     { expr_node = Eassign_local (content id, e'); expr_typ = typ }

  | Ptree.Eassign (Ptree.Larrow (e1, id), e2) -> begin
     let e1' = typing_expr envs e1 in
     match e1'.expr_typ with
     | Tstructp structure ->
        let field =
          field_lookup structure.str_name id structure.str_fields
        in
        let e2' = typing_expr envs e2 in
        check_compatibility field.field_typ e2'.expr_typ (location id);
        { expr_node = Eassign_field (e1', field, e2');
          expr_typ = field.field_typ }
     | _ -> error loc "struct * expected"
    end

  | Ptree.Eunop (op, e) ->
     let e' = typing_expr envs e in
     if op = Ptree.Uminus then begin
         check_compatibility e'.expr_typ Tint e.Ptree.expr_loc
       end;
     { expr_node = Eunop (op, e'); expr_typ = Tint }

  | Ptree.Ebinop (op, e1, e2) ->
     let e1' = typing_expr envs e1 in
     let e2' = typing_expr envs e2 in
     begin
       match op with
       | Ptree.Beq | Ptree.Bneq | Ptree.Blt | Ptree.Ble
       | Ptree.Bgt | Ptree.Bge | Ptree.Band | Ptree.Bor ->
          check_compatibility e1'.expr_typ e2'.expr_typ e1.Ptree.expr_loc;

       | Ptree.Badd | Ptree.Bsub | Ptree.Bmul | Ptree.Bdiv ->
          check_compatibility e1'.expr_typ Tint e1.Ptree.expr_loc;
          check_compatibility e2'.expr_typ Tint e2.Ptree.expr_loc;
     end;
     { expr_node = Ebinop (op, e1', e2'); expr_typ = Tint }

  | Ptree.Ecall (f, params) ->
     let return_type, params_type = function_lookup f envs.fenv in
     let params' =
       List.map (typing_expr envs) params
     in
     if List.length params <> List.length params_type then begin
         error (location f)
           (sprintf "wrong number of arguments for function %s get %d expected %d"
              (content f) (List.length params) (List.length params_type))
       end;
     List.iter2
       (fun (e, typ) e' ->
         check_compatibility e'.expr_typ typ e.Ptree.expr_loc)
       (List.combine params params_type)
       params';
     { expr_node = Ecall (content f, params');
       expr_typ = return_type }

  | Ptree.Esizeof id ->
     { expr_node = Esizeof (structure_lookup id envs.senv);
       expr_typ = Tint }

let rec typing_block envs return_type (vars, stmts) =
  let vars' =
    List.map (fun (typ, id) ->
        ptree_type_to_ttree_type envs.senv typ, (content id))
    vars
  in
  let venv' =
    try
      vars'
      |> List.map (fun (typ, id) -> id, typ)
      |> StringMap.of_association_list
      |> StringMap.addm envs.venv
    with StringMap.Duplicate key ->
      vars
      |> List.find (fun (_, id) -> content id = key)
      |> snd
      |> already_defined_error
  in
  (vars',
   List.map
     (typing_stmt { envs with venv = venv' } return_type)
     stmts)

and typing_stmt envs return_type { Ptree.stmt_node = stmt;
                                   Ptree.stmt_loc = loc } =
  match stmt with
  | Ptree.Sskip -> Sskip

  | Ptree.Sexpr e -> Sexpr (typing_expr envs e)

  | Ptree.Sif (e, s1, s2) ->
     Sif (typing_expr envs e,
          typing_stmt envs return_type s1,
          typing_stmt envs return_type s2)

  | Ptree.Swhile (e, s) ->
     Swhile (typing_expr envs e, typing_stmt envs return_type s)

  | Ptree.Sblock b ->
     Sblock (typing_block envs return_type b)

  | Ptree.Sreturn e ->
     let e' = typing_expr envs e in
     check_compatibility e'.expr_typ return_type loc;
     Sreturn e'

let typing_fun file envs f =
  if StringMap.mem (content f.Ptree.fun_name) envs.fenv then begin
      already_defined_error f.Ptree.fun_name
    end;
  let formals_and_locals =
    List.map snd f.Ptree.fun_formals @
      (fst f.Ptree.fun_body
       |> List.map snd)
  in
  check_uniqueness formals_and_locals;
  let return_type =
    ptree_type_to_ttree_type envs.senv f.Ptree.fun_typ
  in
  let fun_formals =
    List.map
      (fun (typ, id) ->
        ptree_type_to_ttree_type envs.senv typ, (content id))
      f.Ptree.fun_formals
  in
  let fenv' =
    StringMap.add
      (content f.Ptree.fun_name)
      (return_type, List.map fst fun_formals)
      envs.fenv
  in
  if content f.Ptree.fun_name = "main" then begin
      if function_lookup f.Ptree.fun_name fenv' <> (Tint, []) then
        error (location f.Ptree.fun_name) "main must have the signature: () -> int"
    end;

  let venv' =
    fun_formals
    |> List.map (fun (typ, id) -> id, typ)
    |> StringMap.of_association_list
    |> StringMap.addm envs.venv
  in
  let f =
    {
      fun_typ = return_type;
      fun_name = content f.Ptree.fun_name;
      fun_formals = fun_formals;
      fun_body = typing_block
                     { envs with fenv = fenv'; venv = venv' }
                     return_type
                     f.Ptree.fun_body
    }
  in
  (
    { funs = f :: file.funs },
    { envs with fenv = fenv' }
  )

let typing_decl (file, envs) = function
  | Ptree.Dstruct (id, fields) -> (file, typing_struct envs id fields)
  | Ptree.Dfun f -> typing_fun file envs f

let program p =
  let file, envs =
    List.fold_left
      (fun acc decl -> typing_decl acc decl)
      (
        { funs = [] },
        { senv = StringMap.empty;
          fenv =
            [ "putchar", (Tint, [Tint]); "sbrk", (Tvoidstar, [Tint]) ]
            |> StringMap.of_association_list;
          venv = StringMap.empty }
      )
      p
  in
  try
    ignore (StringMap.find "main" envs.fenv);
    { funs = List.rev file.funs }
  with Not_found ->
    raise (Error "no main function in file")
