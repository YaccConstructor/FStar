
open Prims

let exhaustiveness_check : Prims.string = "Patterns are incomplete"


let subtyping_failed : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.typ  ->  Prims.unit  ->  Prims.string = (fun env t1 t2 x -> (let _135_10 = (FStar_Tc_Normalize.typ_norm_to_string env t2)
in (let _135_9 = (FStar_Tc_Normalize.typ_norm_to_string env t1)
in (FStar_Util.format2 "Subtyping check failed; expected type %s; got type %s" _135_10 _135_9))))


let ill_kinded_type : Prims.string = "Ill-kinded type"


let totality_check : Prims.string = "This term may not terminate"


let diag : FStar_Range.range  ->  Prims.string  ->  Prims.unit = (fun r msg -> (let _135_17 = (let _135_16 = (let _135_15 = (FStar_Range.string_of_range r)
in (FStar_Util.format2 "%s (Diagnostic): %s\n" _135_15 msg))
in (_135_16)::[])
in (FStar_Util.fprint FStar_Util.stderr "%s" _135_17)))


let warn : FStar_Range.range  ->  Prims.string  ->  Prims.unit = (fun r msg -> (let _135_24 = (let _135_23 = (let _135_22 = (FStar_Range.string_of_range r)
in (FStar_Util.format2 "%s (Warning): %s\n" _135_22 msg))
in (_135_23)::[])
in (FStar_Util.fprint FStar_Util.stderr "%s" _135_24)))


let num_errs : Prims.int FStar_ST.ref = (FStar_Util.mk_ref 0)


let verification_errs : (FStar_Range.range * Prims.string) Prims.list FStar_ST.ref = (FStar_Util.mk_ref [])


let add_errors : FStar_Tc_Env.env  ->  (Prims.string * FStar_Range.range) Prims.list  ->  Prims.unit = (fun env errs -> (

let errs = (FStar_All.pipe_right errs (FStar_List.map (fun _43_14 -> (match (_43_14) with
| (msg, r) -> begin
(

let r = if (r = FStar_Absyn_Syntax.dummyRange) then begin
(FStar_Tc_Env.get_range env)
end else begin
r
end
in ((r), (msg)))
end))))
in (

let n_errs = (FStar_List.length errs)
in (FStar_Util.atomically (fun _43_18 -> (match (()) with
| () -> begin
(

let _43_19 = (let _135_32 = (let _135_31 = (FStar_ST.read verification_errs)
in (FStar_List.append errs _135_31))
in (FStar_ST.op_Colon_Equals verification_errs _135_32))
in (let _135_33 = ((FStar_ST.read num_errs) + n_errs)
in (FStar_ST.op_Colon_Equals num_errs _135_33)))
end))))))


let report_all : Prims.unit  ->  Prims.int = (fun _43_21 -> (match (()) with
| () -> begin
(

let all_errs = (FStar_Util.atomically (fun _43_22 -> (match (()) with
| () -> begin
(

let x = (FStar_ST.read verification_errs)
in (

let _43_24 = (FStar_ST.op_Colon_Equals verification_errs [])
in x))
end)))
in (

let all_errs = (FStar_List.sortWith (fun _43_30 _43_34 -> (match (((_43_30), (_43_34))) with
| ((r1, _43_29), (r2, _43_33)) -> begin
(FStar_Range.compare r1 r2)
end)) all_errs)
in (

let _43_39 = (FStar_All.pipe_right all_errs (FStar_List.iter (fun _43_38 -> (match (_43_38) with
| (r, msg) -> begin
(let _135_40 = (FStar_Range.string_of_range r)
in (FStar_Util.print2 "%s: %s\n" _135_40 msg))
end))))
in (FStar_List.length all_errs))))
end))


let report : FStar_Range.range  ->  Prims.string  ->  Prims.unit = (fun r msg -> (

let _43_43 = (FStar_Util.incr num_errs)
in (let _135_47 = (let _135_46 = (let _135_45 = (FStar_Range.string_of_range r)
in (FStar_Util.format2 "%s: %s\n" _135_45 msg))
in (_135_46)::[])
in (FStar_Util.fprint FStar_Util.stderr "%s" _135_47))))


let get_err_count : Prims.unit  ->  Prims.int = (fun _43_45 -> (match (()) with
| () -> begin
(FStar_ST.read num_errs)
end))


let unexpected_signature_for_monad : FStar_Tc_Env.env  ->  FStar_Ident.lident  ->  FStar_Absyn_Syntax.knd  ->  Prims.string = (fun env m k -> (let _135_56 = (FStar_Tc_Normalize.kind_norm_to_string env k)
in (FStar_Util.format2 "Unexpected signature for monad \"%s\". Expected a kind of the form (\'a:Type => WP \'a => WP \'a => Type);\ngot %s" m.FStar_Ident.str _135_56)))


let expected_a_term_of_type_t_got_a_function : FStar_Tc_Env.env  ->  Prims.string  ->  FStar_Absyn_Syntax.typ  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax  ->  Prims.string = (fun env msg t e -> (let _135_66 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_65 = (FStar_Absyn_Print.exp_to_string e)
in (FStar_Util.format3 "Expected a term of type \"%s\";\ngot a function \"%s\" (%s)" _135_66 _135_65 msg))))


let unexpected_implicit_argument : Prims.string = "Unexpected instantiation of an implicit argument to a function that only expects explicit arguments"


let expected_expression_of_type : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env t1 e t2 -> (let _135_77 = (FStar_Tc_Normalize.typ_norm_to_string env t1)
in (let _135_76 = (FStar_Absyn_Print.exp_to_string e)
in (let _135_75 = (FStar_Tc_Normalize.typ_norm_to_string env t2)
in (FStar_Util.format3 "Expected expression of type \"%s\";\ngot expression \"%s\" of type \"%s\"" _135_77 _135_76 _135_75)))))


let expected_function_with_parameter_of_type : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.typ  ->  Prims.string  ->  Prims.string = (fun env t1 t2 -> (let _135_89 = (FStar_Tc_Normalize.typ_norm_to_string env t1)
in (let _135_88 = (FStar_Tc_Normalize.typ_norm_to_string env t2)
in (FStar_Util.format3 "Expected a function with a parameter of type \"%s\"; this function has a parameter of type \"%s\"" _135_89 _135_88))))


let expected_pattern_of_type : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env t1 e t2 -> (let _135_100 = (FStar_Tc_Normalize.typ_norm_to_string env t1)
in (let _135_99 = (FStar_Absyn_Print.exp_to_string e)
in (let _135_98 = (FStar_Tc_Normalize.typ_norm_to_string env t2)
in (FStar_Util.format3 "Expected pattern of type \"%s\";\ngot pattern \"%s\" of type \"%s\"" _135_100 _135_99 _135_98)))))


let basic_type_error : FStar_Tc_Env.env  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax Prims.option  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env eopt t1 t2 -> (match (eopt) with
| None -> begin
(let _135_110 = (FStar_Tc_Normalize.typ_norm_to_string env t1)
in (let _135_109 = (FStar_Tc_Normalize.typ_norm_to_string env t2)
in (FStar_Util.format2 "Expected type \"%s\";\ngot type \"%s\"" _135_110 _135_109)))
end
| Some (e) -> begin
(let _135_113 = (FStar_Tc_Normalize.typ_norm_to_string env t1)
in (let _135_112 = (FStar_Absyn_Print.exp_to_string e)
in (let _135_111 = (FStar_Tc_Normalize.typ_norm_to_string env t2)
in (FStar_Util.format3 "Expected type \"%s\"; but \"%s\" has type \"%s\"" _135_113 _135_112 _135_111))))
end))


let occurs_check : Prims.string = "Possibly infinite typ (occurs check failed)"


let unification_well_formedness : Prims.string = "Term or type of an unexpected sort"


let incompatible_kinds : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.knd  ->  FStar_Absyn_Syntax.knd  ->  Prims.string = (fun env k1 k2 -> (let _135_121 = (FStar_Tc_Normalize.kind_norm_to_string env k1)
in (let _135_120 = (FStar_Tc_Normalize.kind_norm_to_string env k2)
in (FStar_Util.format2 "Kinds \"%s\" and \"%s\" are incompatible" _135_121 _135_120))))


let constructor_builds_the_wrong_type : FStar_Tc_Env.env  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env d t t' -> (let _135_132 = (FStar_Absyn_Print.exp_to_string d)
in (let _135_131 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_130 = (FStar_Tc_Normalize.typ_norm_to_string env t')
in (FStar_Util.format3 "Constructor \"%s\" builds a value of type \"%s\"; expected \"%s\"" _135_132 _135_131 _135_130)))))


let constructor_fails_the_positivity_check = (fun env d l -> (let _135_137 = (FStar_Absyn_Print.exp_to_string d)
in (let _135_136 = (FStar_Absyn_Print.sli l)
in (FStar_Util.format2 "Constructor \"%s\" fails the strict positivity check; the constructed type \"%s\" occurs to the left of a pure function type" _135_137 _135_136))))


let inline_type_annotation_and_val_decl : FStar_Ident.lident  ->  Prims.string = (fun l -> (let _135_140 = (FStar_Absyn_Print.sli l)
in (FStar_Util.format1 "\"%s\" has a val declaration as well as an inlined type annotation; remove one" _135_140)))


let inferred_type_causes_variable_to_escape = (fun env t x -> (let _135_145 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_144 = (FStar_Absyn_Print.strBvd x)
in (FStar_Util.format2 "Inferred type \"%s\" causes variable \"%s\" to escape its scope" _135_145 _135_144))))


let expected_typ_of_kind : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.knd  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.knd  ->  Prims.string = (fun env k1 t k2 -> (let _135_156 = (FStar_Tc_Normalize.kind_norm_to_string env k1)
in (let _135_155 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_154 = (FStar_Tc_Normalize.kind_norm_to_string env k2)
in (FStar_Util.format3 "Expected type of kind \"%s\";\ngot \"%s\" of kind \"%s\"" _135_156 _135_155 _135_154)))))


let expected_tcon_kind : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.knd  ->  Prims.string = (fun env t k -> (let _135_164 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_163 = (FStar_Tc_Normalize.kind_norm_to_string env k)
in (FStar_Util.format2 "Expected a type-to-type constructor or function;\ngot a type \"%s\" of kind \"%s\"" _135_164 _135_163))))


let expected_dcon_kind : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.knd  ->  Prims.string = (fun env t k -> (let _135_172 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_171 = (FStar_Tc_Normalize.kind_norm_to_string env k)
in (FStar_Util.format2 "Expected a term-to-type constructor or function;\ngot a type \"%s\" of kind \"%s\"" _135_172 _135_171))))


let expected_function_typ : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env t -> (let _135_177 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (FStar_Util.format1 "Expected a function;\ngot an expression of type \"%s\"" _135_177)))


let expected_poly_typ : FStar_Tc_Env.env  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax  ->  FStar_Absyn_Syntax.typ  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env f t targ -> (let _135_188 = (FStar_Absyn_Print.exp_to_string f)
in (let _135_187 = (FStar_Tc_Normalize.typ_norm_to_string env t)
in (let _135_186 = (FStar_Tc_Normalize.typ_norm_to_string env targ)
in (FStar_Util.format3 "Expected a polymorphic function;\ngot an expression \"%s\" of type \"%s\" applied to a type \"%s\"" _135_188 _135_187 _135_186)))))


let nonlinear_pattern_variable = (fun x -> (

let m = (match (x) with
| FStar_Util.Inl (x) -> begin
(FStar_Absyn_Print.strBvd x)
end
| FStar_Util.Inr (a) -> begin
(FStar_Absyn_Print.strBvd a)
end)
in (FStar_Util.format1 "The pattern variable \"%s\" was used more than once" m)))


let disjunctive_pattern_vars = (fun v1 v2 -> (

let vars = (fun v -> (let _135_195 = (FStar_All.pipe_right v (FStar_List.map (fun _43_1 -> (match (_43_1) with
| FStar_Util.Inl (a) -> begin
(FStar_Absyn_Print.strBvd a)
end
| FStar_Util.Inr (x) -> begin
(FStar_Absyn_Print.strBvd x)
end))))
in (FStar_All.pipe_right _135_195 (FStar_String.concat ", "))))
in (let _135_197 = (vars v1)
in (let _135_196 = (vars v2)
in (FStar_Util.format2 "Every alternative of an \'or\' pattern must bind the same variables; here one branch binds (\"%s\") and another (\"%s\")" _135_197 _135_196)))))


let name_and_result = (fun c -> (match (c.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Total (t) -> begin
(("Tot"), (t))
end
| FStar_Absyn_Syntax.Comp (ct) -> begin
(let _135_199 = (FStar_Absyn_Print.sli ct.FStar_Absyn_Syntax.effect_name)
in ((_135_199), (ct.FStar_Absyn_Syntax.result_typ)))
end))


let computed_computation_type_does_not_match_annotation = (fun env e c c' -> (

let _43_127 = (name_and_result c)
in (match (_43_127) with
| (f1, r1) -> begin
(

let _43_130 = (name_and_result c')
in (match (_43_130) with
| (f2, r2) -> begin
(let _135_205 = (FStar_Tc_Normalize.typ_norm_to_string env r1)
in (let _135_204 = (FStar_Tc_Normalize.typ_norm_to_string env r2)
in (FStar_Util.format4 "Computed type \"%s\" and effect \"%s\" is not compatible with the annotated type \"%s\" effect \"%s\"" _135_205 f1 _135_204 f2)))
end))
end)))


let unexpected_non_trivial_precondition_on_term : FStar_Tc_Env.env  ->  FStar_Absyn_Syntax.typ  ->  Prims.string = (fun env f -> (let _135_210 = (FStar_Tc_Normalize.formula_norm_to_string env f)
in (FStar_Util.format1 "Term has an unexpected non-trivial pre-condition: %s" _135_210)))


let expected_pure_expression = (fun e c -> (let _135_215 = (FStar_Absyn_Print.exp_to_string e)
in (let _135_214 = (let _135_213 = (name_and_result c)
in (FStar_All.pipe_left Prims.fst _135_213))
in (FStar_Util.format2 "Expected a pure expression;\ngot an expression \"%s\" with effect \"%s\"" _135_215 _135_214))))


let expected_ghost_expression = (fun e c -> (let _135_220 = (FStar_Absyn_Print.exp_to_string e)
in (let _135_219 = (let _135_218 = (name_and_result c)
in (FStar_All.pipe_left Prims.fst _135_218))
in (FStar_Util.format2 "Expected a ghost expression;\ngot an expression \"%s\" with effect \"%s\"" _135_220 _135_219))))


let expected_effect_1_got_effect_2 : FStar_Ident.lident  ->  FStar_Ident.lident  ->  Prims.string = (fun c1 c2 -> (let _135_226 = (FStar_Absyn_Print.sli c1)
in (let _135_225 = (FStar_Absyn_Print.sli c2)
in (FStar_Util.format2 "Expected a computation with effect %s; but it has effect %s\n" _135_226 _135_225))))


let failed_to_prove_specification_of : FStar_Absyn_Syntax.lbname  ->  Prims.string Prims.list  ->  Prims.string = (fun l lbls -> (let _135_232 = (FStar_Absyn_Print.lbname_to_string l)
in (let _135_231 = (FStar_All.pipe_right lbls (FStar_String.concat ", "))
in (FStar_Util.format2 "Failed to prove specification of %s; assertions at [%s] may fail" _135_232 _135_231))))


let failed_to_prove_specification : Prims.string Prims.list  ->  Prims.string = (fun lbls -> (match (lbls) with
| [] -> begin
"An unknown assertion in the term at this location was not provable"
end
| _43_144 -> begin
(let _135_235 = (FStar_All.pipe_right lbls (FStar_String.concat "\n\t"))
in (FStar_Util.format1 "The following problems were found:\n\t%s" _135_235))
end))


let top_level_effect : Prims.string = "Top-level let-bindings must be total; this term may have effects"


let cardinality_constraint_violated = (fun l a -> (let _135_239 = (FStar_Absyn_Print.sli l)
in (let _135_238 = (FStar_Absyn_Print.strBvd a.FStar_Absyn_Syntax.v)
in (FStar_Util.format2 "Constructor %s violates the cardinality of Type at parameter \'%s\'; type arguments are not allowed" _135_239 _135_238))))




