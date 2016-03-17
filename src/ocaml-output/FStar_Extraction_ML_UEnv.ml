
open Prims
# 25 "FStar.Extraction.ML.UEnv.fst"
type ty_or_exp_b =
((FStar_Extraction_ML_Syntax.mlident * FStar_Extraction_ML_Syntax.mlty), (FStar_Extraction_ML_Syntax.mlexpr * FStar_Extraction_ML_Syntax.mltyscheme * Prims.bool)) FStar_Util.either

# 27 "FStar.Extraction.ML.UEnv.fst"
type binding =
| Bv of (FStar_Syntax_Syntax.bv * ty_or_exp_b)
| Fv of (FStar_Syntax_Syntax.fv * ty_or_exp_b)

# 28 "FStar.Extraction.ML.UEnv.fst"
let is_Bv = (fun _discr_ -> (match (_discr_) with
| Bv (_) -> begin
true
end
| _ -> begin
false
end))

# 29 "FStar.Extraction.ML.UEnv.fst"
let is_Fv = (fun _discr_ -> (match (_discr_) with
| Fv (_) -> begin
true
end
| _ -> begin
false
end))

# 28 "FStar.Extraction.ML.UEnv.fst"
let ___Bv____0 = (fun projectee -> (match (projectee) with
| Bv (_66_6) -> begin
_66_6
end))

# 29 "FStar.Extraction.ML.UEnv.fst"
let ___Fv____0 = (fun projectee -> (match (projectee) with
| Fv (_66_9) -> begin
_66_9
end))

# 31 "FStar.Extraction.ML.UEnv.fst"
type env =
{tcenv : FStar_TypeChecker_Env.env; gamma : binding Prims.list; tydefs : (FStar_Extraction_ML_Syntax.mlsymbol Prims.list * FStar_Extraction_ML_Syntax.mltydecl) Prims.list; currentModule : FStar_Extraction_ML_Syntax.mlpath}

# 31 "FStar.Extraction.ML.UEnv.fst"
let is_Mkenv : env  ->  Prims.bool = (Obj.magic ((fun _ -> (FStar_All.failwith "Not yet implemented:is_Mkenv"))))

# 40 "FStar.Extraction.ML.UEnv.fst"
let debug : env  ->  (Prims.unit  ->  Prims.unit)  ->  Prims.unit = (fun g f -> (
# 41 "FStar.Extraction.ML.UEnv.fst"
let c = (FStar_Extraction_ML_Syntax.string_of_mlpath g.currentModule)
in if ((let _150_52 = (FStar_ST.read FStar_Options.debug)
in (FStar_All.pipe_right _150_52 (FStar_Util.for_some (fun x -> (c = x))))) && (FStar_Options.debug_level_geq (FStar_Options.Other ("Extraction")))) then begin
(f ())
end else begin
()
end))

# 47 "FStar.Extraction.ML.UEnv.fst"
let mkFvvar : FStar_Ident.lident  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.fv = (fun l t -> (FStar_Syntax_Syntax.lid_as_fv l FStar_Syntax_Syntax.Delta_constant None))

# 51 "FStar.Extraction.ML.UEnv.fst"
let erasedContent : FStar_Extraction_ML_Syntax.mlty = FStar_Extraction_ML_Syntax.ml_unit_ty

# 53 "FStar.Extraction.ML.UEnv.fst"
let erasableTypeNoDelta : FStar_Extraction_ML_Syntax.mlty  ->  Prims.bool = (fun t -> if (t = FStar_Extraction_ML_Syntax.ml_unit_ty) then begin
true
end else begin
(match (t) with
| FStar_Extraction_ML_Syntax.MLTY_Named (_66_23, ("FStar"::"Ghost"::[], "erased")) -> begin
true
end
| _66_32 -> begin
false
end)
end)

# 60 "FStar.Extraction.ML.UEnv.fst"
let unknownType : FStar_Extraction_ML_Syntax.mlty = FStar_Extraction_ML_Syntax.MLTY_Top

# 63 "FStar.Extraction.ML.UEnv.fst"
let prependTick = (fun _66_35 -> (match (_66_35) with
| (x, n) -> begin
if (FStar_Util.starts_with x "\'") then begin
(x, n)
end else begin
((Prims.strcat "\'A" x), n)
end
end))

# 64 "FStar.Extraction.ML.UEnv.fst"
let removeTick = (fun _66_38 -> (match (_66_38) with
| (x, n) -> begin
if (FStar_Util.starts_with x "\'") then begin
(let _150_61 = (FStar_Util.substring_from x 1)
in (_150_61, n))
end else begin
(x, n)
end
end))

# 66 "FStar.Extraction.ML.UEnv.fst"
let convRange : FStar_Range.range  ->  Prims.int = (fun r -> 0)

# 67 "FStar.Extraction.ML.UEnv.fst"
let convIdent : FStar_Ident.ident  ->  (Prims.string * Prims.int) = (fun id -> (id.FStar_Ident.idText, 0))

# 82 "FStar.Extraction.ML.UEnv.fst"
let bv_as_ml_tyvar : FStar_Syntax_Syntax.bv  ->  (Prims.string * Prims.int) = (fun x -> (let _150_68 = (FStar_Extraction_ML_Syntax.bv_as_mlident x)
in (prependTick _150_68)))

# 83 "FStar.Extraction.ML.UEnv.fst"
let bv_as_ml_termvar : FStar_Syntax_Syntax.bv  ->  (Prims.string * Prims.int) = (fun x -> (let _150_71 = (FStar_Extraction_ML_Syntax.bv_as_mlident x)
in (removeTick _150_71)))

# 85 "FStar.Extraction.ML.UEnv.fst"
let rec lookup_ty_local : binding Prims.list  ->  FStar_Syntax_Syntax.bv  ->  FStar_Extraction_ML_Syntax.mlty = (fun gamma b -> (match (gamma) with
| Bv (b', FStar_Util.Inl (mli, mlt))::tl -> begin
if (FStar_Syntax_Syntax.bv_eq b b') then begin
mlt
end else begin
(lookup_ty_local tl b)
end
end
| Bv (b', FStar_Util.Inr (_66_57))::tl -> begin
if (FStar_Syntax_Syntax.bv_eq b b') then begin
(FStar_All.failwith (Prims.strcat "Type/Expr clash: " b.FStar_Syntax_Syntax.ppname.FStar_Ident.idText))
end else begin
(lookup_ty_local tl b)
end
end
| _66_64::tl -> begin
(lookup_ty_local tl b)
end
| [] -> begin
(FStar_All.failwith (Prims.strcat "extraction: unbound type var " b.FStar_Syntax_Syntax.ppname.FStar_Ident.idText))
end))

# 92 "FStar.Extraction.ML.UEnv.fst"
let tyscheme_of_td = (fun _66_71 -> (match (_66_71) with
| (_66_68, vars, body_opt) -> begin
(match (body_opt) with
| Some (FStar_Extraction_ML_Syntax.MLTD_Abbrev (t)) -> begin
Some ((vars, t))
end
| _66_76 -> begin
None
end)
end))

# 97 "FStar.Extraction.ML.UEnv.fst"
let lookup_ty_const : env  ->  FStar_Extraction_ML_Syntax.mlpath  ->  FStar_Extraction_ML_Syntax.mltyscheme Prims.option = (fun env _66_80 -> (match (_66_80) with
| (module_name, ty_name) -> begin
(FStar_Util.find_map env.tydefs (fun _66_83 -> (match (_66_83) with
| (m, tds) -> begin
if (module_name = m) then begin
(FStar_Util.find_map tds (fun td -> (
# 101 "FStar.Extraction.ML.UEnv.fst"
let _66_90 = td
in (match (_66_90) with
| (n, _66_87, _66_89) -> begin
if (n = ty_name) then begin
(tyscheme_of_td td)
end else begin
None
end
end))))
end else begin
None
end
end)))
end))

# 107 "FStar.Extraction.ML.UEnv.fst"
let lookup_tyvar : env  ->  FStar_Syntax_Syntax.bv  ->  FStar_Extraction_ML_Syntax.mlty = (fun g bt -> (lookup_ty_local g.gamma bt))

# 109 "FStar.Extraction.ML.UEnv.fst"
let lookup_fv_by_lid : env  ->  FStar_Ident.lident  ->  ty_or_exp_b = (fun g fv -> (
# 110 "FStar.Extraction.ML.UEnv.fst"
let x = (FStar_Util.find_map g.gamma (fun _66_1 -> (match (_66_1) with
| Fv (fv', x) when (FStar_Syntax_Syntax.fv_eq_lid fv' fv) -> begin
Some (x)
end
| _66_101 -> begin
None
end)))
in (match (x) with
| None -> begin
(let _150_92 = (FStar_Util.format1 "free Variable %s not found\n" fv.FStar_Ident.nsstr)
in (FStar_All.failwith _150_92))
end
| Some (y) -> begin
y
end)))

# 118 "FStar.Extraction.ML.UEnv.fst"
let lookup_fv : env  ->  FStar_Syntax_Syntax.fv  ->  ty_or_exp_b = (fun g fv -> (
# 119 "FStar.Extraction.ML.UEnv.fst"
let x = (FStar_Util.find_map g.gamma (fun _66_2 -> (match (_66_2) with
| Fv (fv', t) when (FStar_Syntax_Syntax.fv_eq fv fv') -> begin
Some (t)
end
| _66_114 -> begin
None
end)))
in (match (x) with
| None -> begin
(let _150_100 = (let _150_99 = (FStar_Range.string_of_range fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.p)
in (let _150_98 = (FStar_Syntax_Print.lid_to_string fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
in (FStar_Util.format2 "(%s) free Variable %s not found\n" _150_99 _150_98)))
in (FStar_All.failwith _150_100))
end
| Some (y) -> begin
y
end)))

# 126 "FStar.Extraction.ML.UEnv.fst"
let lookup_bv : env  ->  FStar_Syntax_Syntax.bv  ->  ty_or_exp_b = (fun g bv -> (
# 127 "FStar.Extraction.ML.UEnv.fst"
let x = (FStar_Util.find_map g.gamma (fun _66_3 -> (match (_66_3) with
| Bv (bv', r) when (FStar_Syntax_Syntax.bv_eq bv bv') -> begin
Some (r)
end
| _66_127 -> begin
None
end)))
in (match (x) with
| None -> begin
(let _150_108 = (let _150_107 = (FStar_Range.string_of_range bv.FStar_Syntax_Syntax.ppname.FStar_Ident.idRange)
in (let _150_106 = (FStar_Syntax_Print.bv_to_string bv)
in (FStar_Util.format2 "(%s) bound Variable %s not found\n" _150_107 _150_106)))
in (FStar_All.failwith _150_108))
end
| Some (y) -> begin
y
end)))

# 135 "FStar.Extraction.ML.UEnv.fst"
let lookup : env  ->  (FStar_Syntax_Syntax.bv, FStar_Syntax_Syntax.fv) FStar_Util.either  ->  (ty_or_exp_b * FStar_Syntax_Syntax.fv_qual Prims.option) = (fun g x -> (match (x) with
| FStar_Util.Inl (x) -> begin
(let _150_113 = (lookup_bv g x)
in (_150_113, None))
end
| FStar_Util.Inr (x) -> begin
(let _150_114 = (lookup_fv g x)
in (_150_114, x.FStar_Syntax_Syntax.fv_qual))
end))

# 140 "FStar.Extraction.ML.UEnv.fst"
let lookup_term : env  ->  FStar_Syntax_Syntax.term  ->  (ty_or_exp_b * FStar_Syntax_Syntax.fv_qual Prims.option) = (fun g t -> (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_name (x) -> begin
(lookup g (FStar_Util.Inl (x)))
end
| FStar_Syntax_Syntax.Tm_fvar (x) -> begin
(lookup g (FStar_Util.Inr (x)))
end
| _66_145 -> begin
(FStar_All.failwith "Impossible: lookup_term for a non-name")
end))

# 154 "FStar.Extraction.ML.UEnv.fst"
let extend_ty : env  ->  FStar_Syntax_Syntax.bv  ->  FStar_Extraction_ML_Syntax.mlty Prims.option  ->  env = (fun g a mapped_to -> (
# 155 "FStar.Extraction.ML.UEnv.fst"
let ml_a = (bv_as_ml_tyvar a)
in (
# 156 "FStar.Extraction.ML.UEnv.fst"
let mapped_to = (match (mapped_to) with
| None -> begin
FStar_Extraction_ML_Syntax.MLTY_Var (ml_a)
end
| Some (t) -> begin
t
end)
in (
# 159 "FStar.Extraction.ML.UEnv.fst"
let gamma = (Bv ((a, FStar_Util.Inl ((ml_a, mapped_to)))))::g.gamma
in (
# 160 "FStar.Extraction.ML.UEnv.fst"
let tcenv = (FStar_TypeChecker_Env.push_bv g.tcenv a)
in (
# 161 "FStar.Extraction.ML.UEnv.fst"
let _66_156 = g
in {tcenv = tcenv; gamma = gamma; tydefs = _66_156.tydefs; currentModule = _66_156.currentModule}))))))

# 163 "FStar.Extraction.ML.UEnv.fst"
let extend_bv : env  ->  FStar_Syntax_Syntax.bv  ->  FStar_Extraction_ML_Syntax.mltyscheme  ->  Prims.bool  ->  Prims.bool  ->  Prims.bool  ->  env = (fun g x t_x add_unit is_rec mk_unit -> (
# 164 "FStar.Extraction.ML.UEnv.fst"
let ml_ty = (match (t_x) with
| ([], t) -> begin
t
end
| _66_168 -> begin
FStar_Extraction_ML_Syntax.MLTY_Top
end)
in (
# 167 "FStar.Extraction.ML.UEnv.fst"
let mlx = (let _150_137 = (FStar_Extraction_ML_Syntax.bv_as_mlident x)
in FStar_Extraction_ML_Syntax.MLE_Var (_150_137))
in (
# 168 "FStar.Extraction.ML.UEnv.fst"
let mlx = if mk_unit then begin
FStar_Extraction_ML_Syntax.ml_unit
end else begin
if add_unit then begin
(FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top) (FStar_Extraction_ML_Syntax.MLE_App (((FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top mlx), (FStar_Extraction_ML_Syntax.ml_unit)::[]))))
end else begin
(FStar_Extraction_ML_Syntax.with_ty ml_ty mlx)
end
end
in (
# 173 "FStar.Extraction.ML.UEnv.fst"
let gamma = (Bv ((x, FStar_Util.Inr ((mlx, t_x, is_rec)))))::g.gamma
in (
# 174 "FStar.Extraction.ML.UEnv.fst"
let tcenv = (let _150_138 = (FStar_Syntax_Syntax.binders_of_list ((x)::[]))
in (FStar_TypeChecker_Env.push_binders g.tcenv _150_138))
in (
# 175 "FStar.Extraction.ML.UEnv.fst"
let _66_174 = g
in {tcenv = tcenv; gamma = gamma; tydefs = _66_174.tydefs; currentModule = _66_174.currentModule})))))))

# 177 "FStar.Extraction.ML.UEnv.fst"
let rec mltyFvars : FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlident Prims.list = (fun t -> (match (t) with
| FStar_Extraction_ML_Syntax.MLTY_Var (x) -> begin
(x)::[]
end
| FStar_Extraction_ML_Syntax.MLTY_Fun (t1, f, t2) -> begin
(let _150_142 = (mltyFvars t1)
in (let _150_141 = (mltyFvars t2)
in (FStar_List.append _150_142 _150_141)))
end
| FStar_Extraction_ML_Syntax.MLTY_Named (args, path) -> begin
(FStar_List.collect mltyFvars args)
end
| FStar_Extraction_ML_Syntax.MLTY_Tuple (ts) -> begin
(FStar_List.collect mltyFvars ts)
end
| FStar_Extraction_ML_Syntax.MLTY_Top -> begin
[]
end))

# 185 "FStar.Extraction.ML.UEnv.fst"
let rec subsetMlidents : FStar_Extraction_ML_Syntax.mlident Prims.list  ->  FStar_Extraction_ML_Syntax.mlident Prims.list  ->  Prims.bool = (fun la lb -> (match (la) with
| h::tla -> begin
((FStar_List.contains h lb) && (subsetMlidents tla lb))
end
| [] -> begin
true
end))

# 190 "FStar.Extraction.ML.UEnv.fst"
let tySchemeIsClosed : FStar_Extraction_ML_Syntax.mltyscheme  ->  Prims.bool = (fun tys -> (let _150_149 = (mltyFvars (Prims.snd tys))
in (subsetMlidents _150_149 (Prims.fst tys))))

# 193 "FStar.Extraction.ML.UEnv.fst"
let extend_fv' : env  ->  FStar_Syntax_Syntax.fv  ->  FStar_Extraction_ML_Syntax.mlpath  ->  FStar_Extraction_ML_Syntax.mltyscheme  ->  Prims.bool  ->  Prims.bool  ->  env = (fun g x y t_x add_unit is_rec -> if (tySchemeIsClosed t_x) then begin
(
# 196 "FStar.Extraction.ML.UEnv.fst"
let ml_ty = (match (t_x) with
| ([], t) -> begin
t
end
| _66_208 -> begin
FStar_Extraction_ML_Syntax.MLTY_Top
end)
in (
# 199 "FStar.Extraction.ML.UEnv.fst"
let mly = FStar_Extraction_ML_Syntax.MLE_Name (y)
in (
# 200 "FStar.Extraction.ML.UEnv.fst"
let mly = if add_unit then begin
(FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top) (FStar_Extraction_ML_Syntax.MLE_App (((FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top mly), (FStar_Extraction_ML_Syntax.ml_unit)::[]))))
end else begin
(FStar_Extraction_ML_Syntax.with_ty ml_ty mly)
end
in (
# 201 "FStar.Extraction.ML.UEnv.fst"
let gamma = (Fv ((x, FStar_Util.Inr ((mly, t_x, is_rec)))))::g.gamma
in (
# 202 "FStar.Extraction.ML.UEnv.fst"
let tcenv = (FStar_TypeChecker_Env.push_let_binding g.tcenv (FStar_Util.Inr (x)) ([], x.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.ty))
in (
# 203 "FStar.Extraction.ML.UEnv.fst"
let _66_214 = g
in {tcenv = tcenv; gamma = gamma; tydefs = _66_214.tydefs; currentModule = _66_214.currentModule}))))))
end else begin
(FStar_All.failwith "freevars found")
end)

# 207 "FStar.Extraction.ML.UEnv.fst"
let extend_fv : env  ->  FStar_Syntax_Syntax.fv  ->  FStar_Extraction_ML_Syntax.mltyscheme  ->  Prims.bool  ->  Prims.bool  ->  env = (fun g x t_x add_unit is_rec -> (
# 208 "FStar.Extraction.ML.UEnv.fst"
let mlp = (FStar_Extraction_ML_Syntax.mlpath_of_lident x.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
in (extend_fv' g x mlp t_x add_unit is_rec)))

# 215 "FStar.Extraction.ML.UEnv.fst"
let extend_lb : env  ->  FStar_Syntax_Syntax.lbname  ->  FStar_Syntax_Syntax.typ  ->  FStar_Extraction_ML_Syntax.mltyscheme  ->  Prims.bool  ->  Prims.bool  ->  (env * FStar_Extraction_ML_Syntax.mlident) = (fun g l t t_x add_unit is_rec -> (match (l) with
| FStar_Util.Inl (x) -> begin
(let _150_185 = (extend_bv g x t_x add_unit is_rec false)
in (let _150_184 = (bv_as_ml_termvar x)
in (_150_185, _150_184)))
end
| FStar_Util.Inr (f) -> begin
(
# 220 "FStar.Extraction.ML.UEnv.fst"
let _66_234 = (FStar_Extraction_ML_Syntax.mlpath_of_lident f.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
in (match (_66_234) with
| (p, y) -> begin
(let _150_186 = (extend_fv' g f (p, y) t_x add_unit is_rec)
in (_150_186, (y, 0)))
end))
end))

# 223 "FStar.Extraction.ML.UEnv.fst"
let extend_tydef : env  ->  FStar_Extraction_ML_Syntax.mltydecl  ->  env = (fun g td -> (
# 224 "FStar.Extraction.ML.UEnv.fst"
let m = (FStar_List.append (Prims.fst g.currentModule) (((Prims.snd g.currentModule))::[]))
in (
# 225 "FStar.Extraction.ML.UEnv.fst"
let _66_238 = g
in {tcenv = _66_238.tcenv; gamma = _66_238.gamma; tydefs = ((m, td))::g.tydefs; currentModule = _66_238.currentModule})))

# 228 "FStar.Extraction.ML.UEnv.fst"
let emptyMlPath : (Prims.string Prims.list * Prims.string) = ([], "")

# 230 "FStar.Extraction.ML.UEnv.fst"
let mkContext : FStar_TypeChecker_Env.env  ->  env = (fun e -> (
# 231 "FStar.Extraction.ML.UEnv.fst"
let env = {tcenv = e; gamma = []; tydefs = []; currentModule = emptyMlPath}
in (
# 232 "FStar.Extraction.ML.UEnv.fst"
let a = ("\'a", (- (1)))
in (
# 233 "FStar.Extraction.ML.UEnv.fst"
let failwith_ty = ((a)::[], FStar_Extraction_ML_Syntax.MLTY_Fun ((FStar_Extraction_ML_Syntax.MLTY_Named (([], (("Prims")::[], "string"))), FStar_Extraction_ML_Syntax.E_IMPURE, FStar_Extraction_ML_Syntax.MLTY_Var (a))))
in (let _150_195 = (let _150_194 = (let _150_193 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.failwith_lid FStar_Syntax_Syntax.Delta_constant None)
in FStar_Util.Inr (_150_193))
in (extend_lb env _150_194 FStar_Syntax_Syntax.tun failwith_ty false false))
in (FStar_All.pipe_right _150_195 Prims.fst))))))



