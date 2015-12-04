(*
   Copyright 2008-2014 Nikhil Swamy and Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
#light "off"

module FStar.Tc.Env

open FStar
open FStar.Absyn
open FStar.Absyn.Syntax
open FStar.Absyn.Util
open FStar.Util
open FStar.Absyn.Util

type binding =
  | Binding_var of bvvdef * typ
  | Binding_typ of btvdef * knd
  | Binding_lid of lident * typ
  | Binding_sig of sigelt

type sigtable = Util.smap<sigelt>
let default_table_size = 200
let strlid_of_sigelt se = match lid_of_sigelt se with
  | None -> None
  | Some l -> Some (text_of_lid l)
let signature_to_sigtables s =
  let ht = Util.smap_create default_table_size in
  let _ = List.iter (fun se ->
    let lids = lids_of_sigelt se in
    List.iter (fun l -> Util.smap_add ht l.str se) lids) s in
  ht

let modules_to_sigtables mods =
  signature_to_sigtables (List.collect (fun (_,m) -> m.declarations) mods)

type level =
  | Expr
  | Type
  | Kind

type mlift = typ -> typ -> typ
type edge = {
  msource:lident;
  mtarget:lident;
  mlift:mlift
}
type effects = {
  decls: list<eff_decl>;
  order: list<edge>;                                       (* transitive closure of the order in the signature *)
  joins: list<(lident * lident * lident * mlift * mlift)>; (* least upper bounds *)
}

type env = {
  solver: solver_t;
  range:Range.range;             (* the source location of the term being checked *)
  curmodule: lident;             (* Name of this module *)
  gamma:list<binding>;           (* Local typing environment and signature elements *)
  modules:list<modul>;           (* already fully type checked modules *)
  expected_typ:option<typ>;      (* type expected by the context *)
  level:level;                   (* current term being checked is at level *)
  sigtab:list<sigtable>;         (* a dictionary of long-names to sigelts *)
  is_pattern:bool;               (* is the current term being checked a pattern? *)
  instantiate_targs:bool;        (* instantiate implicit type arguments? default=true *)
  instantiate_vargs:bool;        (* instantiate implicit value agruments? default=true *)
  effects:effects;               (* effect partial order *)
  generalize:bool;               (* generalize let-binding *)
  letrecs:list<(lbname * typ)>;  (* mutually recursive names and their types (for termination checking) *)
  top_level:bool;                (* is this a top-level term? if so, then discharge guards *)
  check_uvars:bool;              (* paranoid: re-typecheck unification variables *)
  use_eq:bool;                   (* generate an equality constraint, rather than subtyping/subkinding *)
  is_iface:bool;                 (* is the module we're currently checking an interface? *)
  admit:bool;                    (* admit VCs in the current module *)
  default_effects:list<(lident * lident)>
}
and solver_t = {
    init: env -> unit;
    push: string -> unit;
    pop:  string -> unit;
    mark: string -> unit;
    reset_mark: string -> unit;
    commit_mark: string -> unit;
    encode_modul:env -> modul -> unit;
    encode_sig:env -> sigelt -> unit;
    solve:env -> typ -> unit;//(bool * list<string>);
    is_trivial: env -> typ -> bool;
    finish: unit -> unit;
    refresh: unit -> unit;
}

let bound_vars env =
    env.gamma |> List.collect (function
        | Binding_typ(a,k) -> [Inl <| Util.bvd_to_bvar_s a k]
        | Binding_var(x,t) -> [Inr <| Util.bvd_to_bvar_s x t]
        | Binding_lid _ -> []
        | Binding_sig _ -> [])

let has_interface env l =
  env.modules |> Util.for_some (fun m -> m.is_interface && lid_equals m.name l)

let debug env (l:Options.debug_level_t) =
       !Options.debug |> Util.for_some (fun x -> env.curmodule.str = x)
    && Options.debug_level_geq l
let show env = !Options.show_signatures |> Util.for_some (fun x -> env.curmodule.str = x)

let new_sigtab () = Util.smap_create default_table_size
let sigtab env = List.hd env.sigtab
let push env msg =
    env.solver.push msg;
    {env with sigtab=Util.smap_copy (sigtab env)::env.sigtab}
let mark env =
    env.solver.mark "USER MARK";
    {env with sigtab=Util.smap_copy (sigtab env)::env.sigtab}
let commit_mark env =
    env.solver.commit_mark "USER MARK";
    let sigtab = match env.sigtab with
        | hd::_::tl -> hd::tl
        | _ -> failwith "Impossible" in
    {env with sigtab=sigtab}
let reset_mark env =
    env.solver.reset_mark "USER MARK";
    {env with sigtab=List.tl env.sigtab}
let pop env msg = match env.sigtab with
    | []
    | [_] -> failwith "Too many pops"
    | _::tl ->
        env.solver.pop msg;
        {env with sigtab=tl}

let initial_env solver module_lid =
  { solver=solver;
    range=Syntax.dummyRange;
    curmodule=module_lid;
    gamma= [];
    modules= [];
    expected_typ=None;
    level=Expr;
    sigtab=[new_sigtab()];
    is_pattern=false;
    instantiate_targs=true;
    instantiate_vargs=true;
    effects={decls=[]; order=[]; joins=[]};
    generalize=true;
    letrecs=[];
    top_level=true;
    check_uvars=false;
    use_eq=false;
    is_iface=false;
    admit=false;
    default_effects=[];
  }


let effect_decl_opt env l =
  env.effects.decls |> Util.find_opt (fun d -> lid_equals d.mname l)

let name_not_found (l:Syntax.lident) =
  format1 "Name \"%s\" not found" l.str

let variable_not_found v =
  format1 "Variable \"%s\" not found" (Print.strBvd v)

let get_effect_decl env l =
  match effect_decl_opt env l with
    | None -> raise (Error(name_not_found l, range_of_lid l))
    | Some md -> md

let join env l1 l2 : (lident * (typ -> typ -> typ) * (typ -> typ -> typ)) =
  if lid_equals l1 l2
  then l1, (fun t wp -> wp), (fun t wp -> wp)
  else match env.effects.joins |> Util.find_opt (fun (m1, m2, _, _, _) -> lid_equals l1 m1 && lid_equals l2 m2) with
    | None -> raise (Error(Util.format2 "Effects %s and %s cannot be composed" (Print.sli l1) (Print.sli l2), env.range))
    | Some (_, _, m3, j1, j2) -> m3, j1, j2

let monad_leq env l1 l2 : option<edge> =
  if lid_equals l1 l2
  then Some ({msource=l1; mtarget=l2; mlift=(fun t wp -> wp)})
  else env.effects.order |> Util.find_opt (fun e -> lid_equals l1 e.msource && lid_equals l2 e.mtarget)

let wp_sig_aux decls m =
  match decls |> Util.find_opt (fun d -> lid_equals d.mname m) with
  | None -> failwith (Util.format1 "Impossible: declaration for monad %s not found" m.str)
  | Some md ->
    match md.signature.n with
      | Kind_arrow([(Inl a, _); (Inl wp, _); (Inl wlp, _)], {n=Kind_effect}) -> a, wp.sort
      | _ -> failwith "Impossible"

let wp_signature env m = wp_sig_aux env.effects.decls m

let default_effect env l = Util.find_map env.default_effects (fun (l', m) -> if lid_equals l l' then Some m else None)

let build_lattice env se = match se with
  | Sig_effect_abbrev(l, _, c, quals, r) ->
    begin match Util.find_map quals (function DefaultEffect n -> n | _ -> None) with
        | None -> env
        | Some e -> {env with default_effects=(e, l)::env.default_effects}
    end
  | Sig_new_effect(ne, _) ->
    let effects = {env.effects with decls=ne::env.effects.decls} in
    {env with effects=effects}

  | Sig_sub_effect(sub, _) ->
    let compose_edges e1 e2 : edge =
       {msource=e1.msource;
        mtarget=e2.mtarget;
        mlift=(fun r wp1 -> e2.mlift r (e1.mlift r wp1))} in

    let mk_lift lift_t r wp1 = mk_Typ_app(lift_t, [targ r; targ wp1]) None wp1.pos in

    let edge =
      {msource=sub.source;
       mtarget=sub.target;
       mlift=mk_lift sub.lift} in
    let id_edge l = {
       msource=sub.source;
       mtarget=sub.target;
       mlift=(fun t wp -> wp)
    } in
    let print_mlift l =
        let arg = Util.ftv (Syntax.lid_of_path ["ARG"] dummyRange) mk_Kind_type in
        let wp = Util.ftv (Syntax.lid_of_path  ["WP"]  dummyRange) mk_Kind_unknown in
        Print.typ_to_string (l arg wp) in
    let order = edge::env.effects.order in

    let ms = env.effects.decls |> List.map (fun (e:eff_decl) -> e.mname) in

    let find_edge order (i, j) =
      if lid_equals i j
      then id_edge i |> Some
      else order |> Util.find_opt (fun e -> lid_equals e.msource i && lid_equals e.mtarget j) in

    (* basically, this is Warshall's algorithm for transitive closure,
       except it's ineffcient because find_edge is doing a linear scan.
       and it's not incremental.
       Could be made better. But these are really small graphs (~ 4-8 vertices) ... so not worth it *)
    let order =
        ms |> List.fold_left (fun order k ->
        order@(ms |> List.collect (fun i ->
               if lid_equals i k then []
               else ms |> List.collect (fun j ->
                    if lid_equals j k
                    then []
                    else match find_edge order (i, k), find_edge order (k, j) with
                            | Some e1, Some e2 -> [compose_edges e1 e2]
                            | _ -> []))))
        order in
    let order = Util.remove_dups (fun e1 e2 -> lid_equals e1.msource e2.msource
                                            && lid_equals e1.mtarget e2.mtarget) order in
    let joins =
        ms |> List.collect (fun i ->
        ms |> List.collect (fun j ->
        let join_opt = ms |> List.fold_left (fun bopt k ->
          match find_edge order (i, k), find_edge order (j, k) with
            | Some ik, Some jk ->
              begin match bopt with
                | None -> Some (k, ik, jk) //we don't have a current candidate as the upper bound; so we may as well use k

                | Some (ub, _, _) ->
                  if Util.is_some (find_edge order (k, ub))
                  && not (Util.is_some (find_edge order (ub, k)))
                  then Some (k, ik, jk) //k is less than ub
                  else bopt
              end
            | _ -> bopt) None in
        match join_opt with
            | None -> []
            | Some (k, e1, e2) -> [(i, j, k, e1.mlift, e2.mlift)])) in

    let effects = {env.effects with order=order; joins=joins} in
//    order |> List.iter (fun o -> Printf.printf "%s <: %s\n\t%s\n" o.msource.str o.mtarget.str (print_mlift o.mlift));
//    joins |> List.iter (fun (e1, e2, e3, l1, l2) -> if lid_equals e1 e2 then () else Printf.printf "%s join %s = %s\n\t%s\n\t%s\n" e1.str e2.str e3.str (print_mlift l1) (print_mlift l2));
    {env with effects=effects}

  | _ -> env


let rec add_sigelt env se = match se with
  | Sig_bundle(ses, _, _, _) -> add_sigelts env ses
  | _ ->
    let lids = lids_of_sigelt se in
    List.iter (fun l -> Util.smap_add (sigtab env) l.str se) lids

and add_sigelts env ses =
  ses |> List.iter (add_sigelt env)

let empty_lid = Syntax.lid_of_ids [Syntax.id_of_text ""]

let finish_module env m =
  let sigs =
    if lid_equals m.name Const.prims_lid
    then env.gamma |> List.collect (function
            | Binding_sig se -> [se]
            | _ -> [])
    else m.exports  in
  add_sigelts env sigs;
  {env with
    curmodule=empty_lid;
    gamma=[];
    modules=m::env.modules}


let set_level env level = {env with level=level}
let is_level env level = env.level=level
let modules env = env.modules
let current_module env = env.curmodule
let set_current_module env lid = {env with curmodule=lid}
let set_range e r = if r = dummyRange then e else {e with range=r}
let get_range e = e.range
let find_in_sigtab env lid = Util.smap_try_find (sigtab env) (text_of_lid lid)

let lookup_bvvdef env (bvvd:bvvdef) : option<typ> =
  Util.find_map env.gamma (function
    | Binding_var (id, t) when (Util.bvd_eq id bvvd) -> Some t
    | _ -> None)

let lookup_bvar env (bv:bvvar) =
  match lookup_bvvdef env bv.v with
    | None -> raise (Error(variable_not_found bv.v, Util.range_of_bvd bv.v))
    | Some t -> t

let in_cur_mod env (l:lident) = (* TODO: need a more efficient namespace check! *)
    let cur = current_module env in
    if l.nsstr = cur.str then true (* fast case; works for everything except records *)
    else if Util.starts_with l.nsstr cur.str
    then let lns = l.ns@[l.ident] in
        let cur = cur.ns@[cur.ident] in
        let rec aux c l = match c, l with
        | [], _ -> true
        | _, [] -> false
        | hd::tl, hd'::tl' when (hd.idText=hd'.idText) -> aux tl tl'
        | _ -> false in
        aux cur lns
    else false 

let lookup_qname env (lid:lident) : option<either<typ, sigelt>>  =
  let cur_mod = in_cur_mod env lid in
  let found = if cur_mod
              then Util.find_map env.gamma (function
                | Binding_lid(l,t) -> if lid_equals lid l then Some (Inl t) else None
                | Binding_sig (Sig_bundle(ses, _, _, _)) ->
                    Util.find_map ses (fun se ->
                        if lids_of_sigelt se |> Util.for_some (lid_equals lid)
                        then Some (Inr se)
                        else None)
                | Binding_sig s ->
                  let lids = lids_of_sigelt s in
                  if lids |> Util.for_some (lid_equals lid) then Some (Inr s) else None
                | _ -> None)
               else None in
  if is_some found
  then found
  else if not (cur_mod) || has_interface env env.curmodule
  then match find_in_sigtab env lid with
        | Some se -> Some (Inr se)
        | None -> None
  else None

let lookup_datacon env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_datacon (_, t, (_, tps, _), _, _, _))) -> 
      close_typ (List.map (fun (x, _) -> (x, Some Implicit)) tps) t 
    | _ -> raise (Error(name_not_found lid, range_of_lid lid))

let lookup_kind_abbrev env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_kind_abbrev (l, binders, k, _))) -> (l, binders, k)
    | _ -> raise (Error(name_not_found lid, range_of_lid lid))

let lookup_projector env lid i =
    let fail () = failwith (Util.format2 "Impossible: projecting field #%s from constructor %s is undefined" (Util.string_of_int i) (Print.sli lid)) in
    let t = lookup_datacon env lid in
    match (Util.compress_typ t).n with
        | Typ_fun(binders, _) ->
          if ((i < 0) || i >= List.length binders) //this has to be within bounds!
          then fail ()
          else let b = List.nth binders i in
               begin match fst b with
                | Inl a -> Util.mk_field_projector_name lid a i |> fst
                | Inr x -> Util.mk_field_projector_name lid x i |> fst
               end
        | _ -> fail ()

let try_lookup_val_decl env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_val_decl(_, t, q, _))) -> Some (t,q)
    | _ -> None

let lookup_val_decl env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_val_decl(_, t, _, _))) -> t
    | _ -> raise (Error(name_not_found lid, range_of_lid lid))

let lookup_lid env lid =
  let not_found () =
    //let _ = Util.smap_fold env.sigtab (fun k _ _ -> Util.print_string (Util.format1 "%s, " k)) () in
    raise (Error(name_not_found lid, range_of_lid lid)) in
  let mapper = function
    | Inr (Sig_datacon(_, t, (_, tps, _), _,_, _)) -> 
      Some (close_typ (List.map (fun (x, _) -> (x, Some Implicit)) tps) t)
    | Inl t -> Some t

    | Inr (Sig_val_decl (l, t, qs, _)) -> 
      if in_cur_mod env l
      then if qs |> List.contains Assumption || env.is_iface
           then Some t
           else None
      else Some t  

    | Inr (Sig_let((_, [{lbtyp=t}]), _, _, _)) -> Some t
    | Inr (Sig_let((_, lbs), _, _, _)) ->
        Util.find_map lbs (fun lb -> match lb.lbname with
          | Inl _ -> failwith "impossible"
          | Inr lid' ->
            if lid_equals lid lid'
            then Some lb.lbtyp
            else None)
    | t -> None
  in
    match Util.bind_opt (lookup_qname env lid) mapper with
      | Some t -> {t with pos=Syntax.range_of_lid lid}
      | None -> not_found ()


let is_datacon env lid =
  match lookup_qname env lid with
    | Some (Inr(Sig_val_decl(_, _, quals, _))) -> quals |> Util.for_some (function Assumption -> true | _ -> false)
    | Some (Inr (Sig_datacon (_, t, _, _,_,_))) -> true
    | _ -> false

let is_record env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_tycon(_, _, _, _, _, tags, _))) ->
        Util.for_some (function RecordType _ | RecordConstructor _ -> true | _ -> false) tags
    | _ -> false

let lookup_datacons_of_typ env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_tycon(_, _, _, _, datas, _, _))) -> Some (List.map (fun l -> (l, lookup_lid env l)) datas)
    | _ -> None

let lookup_effect_abbrev env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_effect_abbrev (lid, binders, c, quals, _))) ->
      if quals |> Util.for_some (function Opaque -> true | _ -> false)
      then None
      else Some (binders, c)
    | _ -> None

let lookup_typ_abbrev env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_typ_abbrev (lid, tps, _, t, quals, _))) ->
      if quals |> Util.for_some (function Opaque -> true | _ -> false)
      then None
      else let t = Util.close_with_lam tps t in
           Some (mk_Typ_meta(Meta_named(t, lid)))
    | _ -> None

let lookup_opaque_typ_abbrev env lid =
  match lookup_qname env lid with
    | Some (Inr (Sig_typ_abbrev (lid, tps, _, t, quals, _))) ->
      let t = Util.close_with_lam tps t in
      Some (mk_Typ_meta(Meta_named(t, lid)))
    | _ -> None

let lookup_btvdef env (btvd:btvdef): option<knd> =
  Util.find_map env.gamma (function
    | Binding_typ (id, k) when Util.bvd_eq id btvd -> Some k
    | _ -> None)

let lookup_btvar env (btv:btvar) =
  match lookup_btvdef env btv.v with
    | None -> raise (Error(variable_not_found btv.v, Util.range_of_bvd btv.v))
    | Some k -> k

let lookup_typ_lid env (ftv:lident) : knd =
  match lookup_qname env ftv with
    | Some (Inr (Sig_tycon (lid, tps, k, _, _, _, _)))
    | Some (Inr (Sig_typ_abbrev (lid, tps, k, _, _, _))) ->
      Util.close_kind tps k
    | _ ->
      raise (Error(name_not_found ftv, range_of_lid ftv))

let is_projector env (l:lident) : bool =
    match lookup_qname env l with
        | Some (Inr (Sig_tycon(_, _, _, _, _, quals, _)))
        | Some (Inr (Sig_val_decl(_, _, quals, _))) ->
          Util.for_some (function Projector _ -> true | _ -> false) quals
        | _ -> false

let try_lookup_effect_lid env (ftv:lident) : option<knd> =
  match lookup_qname env ftv with
    | Some (Inr (Sig_new_effect(ne, _))) ->
      Util.close_kind ne.binders ne.signature |> Some
    | Some (Inr (Sig_effect_abbrev (lid, binders, _, _, _))) ->
      Util.close_kind binders mk_Kind_effect |> Some
    | _ ->
      None

let lookup_effect_lid env (ftv:lident) : knd =
  match try_lookup_effect_lid env ftv with
    | None -> raise (Error(name_not_found ftv, range_of_lid ftv))
    | Some k -> k

let lookup_operator env (opname:ident) =
  let primName = lid_of_path ["Prims"; ("_dummy_" ^ opname.idText)] dummyRange in
    lookup_lid env primName

let push_sigelt env s = build_lattice ({env with gamma=Binding_sig s::env.gamma}) s
let push_local_binding env b = {env with gamma=b::env.gamma}

let uvars_in_env env =
  let no_uvs = {
    uvars_k=new_uv_set();
    uvars_t=new_uvt_set();
    uvars_e=new_uvt_set();
  } in
  let ext out uvs =
    {out with uvars_k=Util.set_union out.uvars_k uvs.uvars_k;
              uvars_t=Util.set_union out.uvars_t uvs.uvars_t;
              uvars_e=Util.set_union out.uvars_e uvs.uvars_e;} in
  let rec aux out g = match g with
    | [] -> out
    | Binding_lid(_, t)::tl
    | Binding_var(_, t)::tl -> aux (ext out (Util.uvars_in_typ t)) tl
    | Binding_typ(_, k)::tl -> aux (ext out (Util.uvars_in_kind k)) tl
    | Binding_sig _::_ -> out in (* this marks a top-level scope ... no more uvars beyond this *)
  aux no_uvs env.gamma

let push_module env (m:modul) =
    add_sigelts env m.exports;
    {env with
      modules=m::env.modules;
      gamma=[];
      expected_typ=None}

let set_expected_typ env t =
  {env with expected_typ = Some t; use_eq=false}
let expected_typ env = match env.expected_typ with
  | None -> None
  | Some t -> Some t
let clear_expected_typ env = {env with expected_typ=None; use_eq=false}, expected_typ env

let fold_env env f a = List.fold_right (fun e a -> f a e) env.gamma a

let binding_of_binder (b:binder) = match fst b with
    | Inl a -> Binding_typ(a.v, a.sort)
    | Inr x -> Binding_var(x.v, x.sort)

let binders env : binders =
  List.fold_left (fun out b -> match b with
    | Binding_var(x, t) -> (v_binder <| bvd_to_bvar_s x t)::out
    | Binding_typ(a, k) -> (t_binder <| bvd_to_bvar_s a k)::out
    | _ -> out) [] env.gamma

let t_binders env : FStar.Absyn.Syntax.binders =
  List.fold_left (fun out b -> match b with
    | Binding_var _ -> out
    | Binding_typ(a, k) -> (t_binder <| bvd_to_bvar_s a k)::out
    | _ -> out) [] env.gamma

let idents env : freevars = freevars_of_list (binders env |> List.map fst)

let lidents env : list<lident> =
  let keys = List.fold_left (fun keys -> function
    | Binding_sig s -> Util.lids_of_sigelt s@keys
    | _ -> keys) [] env.gamma in
  Util.smap_fold (sigtab env) (fun _ v keys -> Util.lids_of_sigelt v@keys) keys


