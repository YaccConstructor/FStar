
open Prims

let lid_to_string : FStar_Ident.lid  ->  Prims.string = (fun l -> l.FStar_Ident.str)


let fv_to_string : FStar_Syntax_Syntax.fv  ->  Prims.string = (fun fv -> (lid_to_string fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v))


let bv_to_string : FStar_Syntax_Syntax.bv  ->  Prims.string = (fun bv -> (let _131_8 = (let _131_7 = (FStar_Util.string_of_int bv.FStar_Syntax_Syntax.index)
in (Prims.strcat "#" _131_7))
in (Prims.strcat bv.FStar_Syntax_Syntax.ppname.FStar_Ident.idText _131_8)))


let nm_to_string : FStar_Syntax_Syntax.bv  ->  Prims.string = (fun bv -> if (FStar_Options.print_real_names ()) then begin
(bv_to_string bv)
end else begin
bv.FStar_Syntax_Syntax.ppname.FStar_Ident.idText
end)


let db_to_string : FStar_Syntax_Syntax.bv  ->  Prims.string = (fun bv -> (let _131_14 = (let _131_13 = (FStar_Util.string_of_int bv.FStar_Syntax_Syntax.index)
in (Prims.strcat "@" _131_13))
in (Prims.strcat bv.FStar_Syntax_Syntax.ppname.FStar_Ident.idText _131_14)))


let infix_prim_ops : (FStar_Ident.lident * Prims.string) Prims.list = (((FStar_Syntax_Const.op_Addition), ("+")))::(((FStar_Syntax_Const.op_Subtraction), ("-")))::(((FStar_Syntax_Const.op_Multiply), ("*")))::(((FStar_Syntax_Const.op_Division), ("/")))::(((FStar_Syntax_Const.op_Eq), ("=")))::(((FStar_Syntax_Const.op_ColonEq), (":=")))::(((FStar_Syntax_Const.op_notEq), ("<>")))::(((FStar_Syntax_Const.op_And), ("&&")))::(((FStar_Syntax_Const.op_Or), ("||")))::(((FStar_Syntax_Const.op_LTE), ("<=")))::(((FStar_Syntax_Const.op_GTE), (">=")))::(((FStar_Syntax_Const.op_LT), ("<")))::(((FStar_Syntax_Const.op_GT), (">")))::(((FStar_Syntax_Const.op_Modulus), ("mod")))::(((FStar_Syntax_Const.and_lid), ("/\\")))::(((FStar_Syntax_Const.or_lid), ("\\/")))::(((FStar_Syntax_Const.imp_lid), ("==>")))::(((FStar_Syntax_Const.iff_lid), ("<==>")))::(((FStar_Syntax_Const.precedes_lid), ("<<")))::(((FStar_Syntax_Const.eq2_lid), ("==")))::(((FStar_Syntax_Const.eq3_lid), ("===")))::[]


let unary_prim_ops : (FStar_Ident.lident * Prims.string) Prims.list = (((FStar_Syntax_Const.op_Negation), ("not")))::(((FStar_Syntax_Const.op_Minus), ("-")))::(((FStar_Syntax_Const.not_lid), ("~")))::[]


let is_prim_op = (fun ps f -> (match (f.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(FStar_All.pipe_right ps (FStar_Util.for_some (FStar_Syntax_Syntax.fv_eq_lid fv)))
end
| _39_22 -> begin
false
end))


let get_lid = (fun f -> (match (f.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v
end
| _39_27 -> begin
(FStar_All.failwith "get_lid")
end))


let is_infix_prim_op : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun e -> (is_prim_op (Prims.fst (FStar_List.split infix_prim_ops)) e))


let is_unary_prim_op : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun e -> (is_prim_op (Prims.fst (FStar_List.split unary_prim_ops)) e))


let quants : (FStar_Ident.lident * Prims.string) Prims.list = (((FStar_Syntax_Const.forall_lid), ("forall")))::(((FStar_Syntax_Const.exists_lid), ("exists")))::[]


type exp =
FStar_Syntax_Syntax.term


let is_b2t : FStar_Syntax_Syntax.typ  ->  Prims.bool = (fun t -> (is_prim_op ((FStar_Syntax_Const.b2t_lid)::[]) t))


let is_quant : FStar_Syntax_Syntax.typ  ->  Prims.bool = (fun t -> (is_prim_op (Prims.fst (FStar_List.split quants)) t))


let is_ite : FStar_Syntax_Syntax.typ  ->  Prims.bool = (fun t -> (is_prim_op ((FStar_Syntax_Const.ite_lid)::[]) t))


let is_lex_cons : exp  ->  Prims.bool = (fun f -> (is_prim_op ((FStar_Syntax_Const.lexcons_lid)::[]) f))


let is_lex_top : exp  ->  Prims.bool = (fun f -> (is_prim_op ((FStar_Syntax_Const.lextop_lid)::[]) f))


let is_inr = (fun _39_1 -> (match (_39_1) with
| FStar_Util.Inl (_39_37) -> begin
false
end
| FStar_Util.Inr (_39_40) -> begin
true
end))


let filter_imp = (fun a -> (FStar_All.pipe_right a (FStar_List.filter (fun _39_2 -> (match (_39_2) with
| (_39_45, Some (FStar_Syntax_Syntax.Implicit (_39_47))) -> begin
false
end
| _39_52 -> begin
true
end)))))


let rec reconstruct_lex : exp  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax Prims.list Prims.option = (fun e -> (match ((let _131_37 = (FStar_Syntax_Subst.compress e)
in _131_37.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_app (f, args) -> begin
(

let args = (filter_imp args)
in (

let exps = (FStar_List.map Prims.fst args)
in if ((is_lex_cons f) && ((FStar_List.length exps) = 2)) then begin
(match ((let _131_38 = (FStar_List.nth exps 1)
in (reconstruct_lex _131_38))) with
| Some (xs) -> begin
(let _131_40 = (let _131_39 = (FStar_List.nth exps 0)
in (_131_39)::xs)
in Some (_131_40))
end
| None -> begin
None
end)
end else begin
None
end))
end
| _39_64 -> begin
if (is_lex_top e) then begin
Some ([])
end else begin
None
end
end))


let rec find = (fun f l -> (match (l) with
| [] -> begin
(FStar_All.failwith "blah")
end
| (hd)::tl -> begin
if (f hd) then begin
hd
end else begin
(find f tl)
end
end))


let find_lid : FStar_Ident.lident  ->  (FStar_Ident.lident * Prims.string) Prims.list  ->  Prims.string = (fun x xs -> (let _131_54 = (find (fun p -> (FStar_Ident.lid_equals x (Prims.fst p))) xs)
in (Prims.snd _131_54)))


let infix_prim_op_to_string = (fun e -> (let _131_56 = (get_lid e)
in (find_lid _131_56 infix_prim_ops)))


let unary_prim_op_to_string = (fun e -> (let _131_58 = (get_lid e)
in (find_lid _131_58 unary_prim_ops)))


let quant_to_string = (fun t -> (let _131_60 = (get_lid t)
in (find_lid _131_60 quants)))


let rec sli : FStar_Ident.lident  ->  Prims.string = (fun l -> if (FStar_Options.print_real_names ()) then begin
l.FStar_Ident.str
end else begin
l.FStar_Ident.ident.FStar_Ident.idText
end)


let const_to_string : FStar_Const.sconst  ->  Prims.string = (fun x -> (match (x) with
| FStar_Const.Const_effect -> begin
"Effect"
end
| FStar_Const.Const_unit -> begin
"()"
end
| FStar_Const.Const_bool (b) -> begin
if b then begin
"true"
end else begin
"false"
end
end
| FStar_Const.Const_float (x) -> begin
(FStar_Util.string_of_float x)
end
| FStar_Const.Const_string (bytes, _39_88) -> begin
(FStar_Util.format1 "\"%s\"" (FStar_Util.string_of_bytes bytes))
end
| FStar_Const.Const_bytearray (_39_92) -> begin
"<bytearray>"
end
| FStar_Const.Const_int (x, _39_96) -> begin
x
end
| FStar_Const.Const_char (c) -> begin
(FStar_Util.string_of_char c)
end
| FStar_Const.Const_range (r) -> begin
(FStar_Range.string_of_range r)
end
| FStar_Const.Const_reify -> begin
"reify"
end
| FStar_Const.Const_reflect (l) -> begin
(let _131_65 = (sli l)
in (FStar_Util.format1 "[[%s.reflect]]" _131_65))
end))


let lbname_to_string : FStar_Syntax_Syntax.lbname  ->  Prims.string = (fun _39_3 -> (match (_39_3) with
| FStar_Util.Inl (l) -> begin
(bv_to_string l)
end
| FStar_Util.Inr (l) -> begin
(lid_to_string l.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end))


let tag_of_term : FStar_Syntax_Syntax.term  ->  Prims.string = (fun t -> (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_bvar (x) -> begin
(let _131_70 = (db_to_string x)
in (Prims.strcat "Tm_bvar: " _131_70))
end
| FStar_Syntax_Syntax.Tm_name (x) -> begin
(let _131_71 = (nm_to_string x)
in (Prims.strcat "Tm_name: " _131_71))
end
| FStar_Syntax_Syntax.Tm_fvar (x) -> begin
(let _131_72 = (lid_to_string x.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
in (Prims.strcat "Tm_fvar: " _131_72))
end
| FStar_Syntax_Syntax.Tm_uinst (_39_119) -> begin
"Tm_uinst"
end
| FStar_Syntax_Syntax.Tm_constant (_39_122) -> begin
"Tm_constant"
end
| FStar_Syntax_Syntax.Tm_type (_39_125) -> begin
"Tm_type"
end
| FStar_Syntax_Syntax.Tm_abs (_39_128) -> begin
"Tm_abs"
end
| FStar_Syntax_Syntax.Tm_arrow (_39_131) -> begin
"Tm_arrow"
end
| FStar_Syntax_Syntax.Tm_refine (_39_134) -> begin
"Tm_refine"
end
| FStar_Syntax_Syntax.Tm_app (_39_137) -> begin
"Tm_app"
end
| FStar_Syntax_Syntax.Tm_match (_39_140) -> begin
"Tm_match"
end
| FStar_Syntax_Syntax.Tm_ascribed (_39_143) -> begin
"Tm_ascribed"
end
| FStar_Syntax_Syntax.Tm_let (_39_146) -> begin
"Tm_let"
end
| FStar_Syntax_Syntax.Tm_uvar (_39_149) -> begin
"Tm_uvar"
end
| FStar_Syntax_Syntax.Tm_delayed (_39_152, m) -> begin
(match ((FStar_ST.read m)) with
| None -> begin
"Tm_delayed"
end
| Some (_39_158) -> begin
"Tm_delayed-resolved"
end)
end
| FStar_Syntax_Syntax.Tm_meta (_39_161) -> begin
"Tm_meta"
end
| FStar_Syntax_Syntax.Tm_unknown -> begin
"Tm_unknown"
end))


let uvar_to_string = (fun u -> if (FStar_Options.hide_uvar_nums ()) then begin
"?"
end else begin
(let _131_77 = (let _131_76 = (FStar_Unionfind.uvar_id u)
in (FStar_All.pipe_right _131_76 FStar_Util.string_of_int))
in (Prims.strcat "?" _131_77))
end)


let rec univ_to_string : FStar_Syntax_Syntax.universe  ->  Prims.string = (fun u -> (match ((FStar_Syntax_Subst.compress_univ u)) with
| FStar_Syntax_Syntax.U_unif (u) -> begin
(uvar_to_string u)
end
| FStar_Syntax_Syntax.U_name (x) -> begin
(Prims.strcat "n" x.FStar_Ident.idText)
end
| FStar_Syntax_Syntax.U_bvar (x) -> begin
(let _131_80 = (FStar_Util.string_of_int x)
in (Prims.strcat "@" _131_80))
end
| FStar_Syntax_Syntax.U_zero -> begin
"0"
end
| FStar_Syntax_Syntax.U_succ (u) -> begin
(let _131_81 = (univ_to_string u)
in (FStar_Util.format1 "(S %s)" _131_81))
end
| FStar_Syntax_Syntax.U_max (us) -> begin
(let _131_83 = (let _131_82 = (FStar_List.map univ_to_string us)
in (FStar_All.pipe_right _131_82 (FStar_String.concat ", ")))
in (FStar_Util.format1 "(max %s)" _131_83))
end
| FStar_Syntax_Syntax.U_unknown -> begin
"unknown"
end))


let univs_to_string : FStar_Syntax_Syntax.universe Prims.list  ->  Prims.string = (fun us -> (let _131_86 = (FStar_List.map univ_to_string us)
in (FStar_All.pipe_right _131_86 (FStar_String.concat ", "))))


let univ_names_to_string : FStar_Ident.ident Prims.list  ->  Prims.string = (fun us -> (let _131_90 = (FStar_List.map (fun x -> x.FStar_Ident.idText) us)
in (FStar_All.pipe_right _131_90 (FStar_String.concat ", "))))


let qual_to_string : FStar_Syntax_Syntax.qualifier  ->  Prims.string = (fun _39_4 -> (match (_39_4) with
| FStar_Syntax_Syntax.Assumption -> begin
"assume"
end
| FStar_Syntax_Syntax.New -> begin
"new"
end
| FStar_Syntax_Syntax.Private -> begin
"private"
end
| FStar_Syntax_Syntax.Inline -> begin
"inline"
end
| FStar_Syntax_Syntax.Unfoldable -> begin
"unfoldable"
end
| FStar_Syntax_Syntax.Irreducible -> begin
"irreducible"
end
| FStar_Syntax_Syntax.Abstract -> begin
"abstract"
end
| FStar_Syntax_Syntax.Noeq -> begin
"noeq"
end
| FStar_Syntax_Syntax.Logic -> begin
"logic"
end
| FStar_Syntax_Syntax.TotalEffect -> begin
"total"
end
| FStar_Syntax_Syntax.Discriminator (l) -> begin
(let _131_93 = (lid_to_string l)
in (FStar_Util.format1 "(Discriminator %s)" _131_93))
end
| FStar_Syntax_Syntax.Projector (l, x) -> begin
(let _131_94 = (lid_to_string l)
in (FStar_Util.format2 "(Projector %s %s)" _131_94 x.FStar_Ident.idText))
end
| FStar_Syntax_Syntax.RecordType (fns) -> begin
(let _131_96 = (let _131_95 = (FStar_All.pipe_right fns (FStar_List.map lid_to_string))
in (FStar_All.pipe_right _131_95 (FStar_String.concat ", ")))
in (FStar_Util.format1 "(RecordType %s)" _131_96))
end
| FStar_Syntax_Syntax.RecordConstructor (fns) -> begin
(let _131_98 = (let _131_97 = (FStar_All.pipe_right fns (FStar_List.map lid_to_string))
in (FStar_All.pipe_right _131_97 (FStar_String.concat ", ")))
in (FStar_Util.format1 "(RecordConstructor %s)" _131_98))
end
| FStar_Syntax_Syntax.ExceptionConstructor -> begin
"ExceptionConstructor"
end
| FStar_Syntax_Syntax.HasMaskedEffect -> begin
"HasMaskedEffect"
end
| FStar_Syntax_Syntax.Effect -> begin
"Effect"
end
| FStar_Syntax_Syntax.Reifiable -> begin
"reify"
end
| FStar_Syntax_Syntax.Reflectable -> begin
"reflect"
end))


let quals_to_string : FStar_Syntax_Syntax.qualifier Prims.list  ->  Prims.string = (fun quals -> (match (quals) with
| [] -> begin
""
end
| _39_210 -> begin
(let _131_102 = (let _131_101 = (FStar_All.pipe_right quals (FStar_List.map qual_to_string))
in (FStar_All.pipe_right _131_101 (FStar_String.concat " ")))
in (Prims.strcat _131_102 " "))
end))


let rec term_to_string : FStar_Syntax_Syntax.term  ->  Prims.string = (fun x -> (

let x = (FStar_Syntax_Subst.compress x)
in (match (x.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_delayed (_39_214) -> begin
(FStar_All.failwith "impossible")
end
| FStar_Syntax_Syntax.Tm_app (_39_217, []) -> begin
(FStar_All.failwith "Empty args!")
end
| FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_pattern (ps)) -> begin
(

let pats = (let _131_127 = (FStar_All.pipe_right ps (FStar_List.map (fun args -> (let _131_126 = (FStar_All.pipe_right args (FStar_List.map (fun _39_230 -> (match (_39_230) with
| (t, _39_229) -> begin
(term_to_string t)
end))))
in (FStar_All.pipe_right _131_126 (FStar_String.concat "; "))))))
in (FStar_All.pipe_right _131_127 (FStar_String.concat "\\/")))
in (let _131_128 = (term_to_string t)
in (FStar_Util.format2 "{:pattern %s} %s" pats _131_128)))
end
| FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_monadic (m, t')) -> begin
(let _131_132 = (tag_of_term t)
in (let _131_131 = (sli m)
in (let _131_130 = (term_to_string t')
in (let _131_129 = (term_to_string t)
in (FStar_Util.format4 "(Monadic-%s{%s %s} %s )" _131_132 _131_131 _131_130 _131_129)))))
end
| FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_monadic_lift (m0, m1)) -> begin
(let _131_136 = (tag_of_term t)
in (let _131_135 = (term_to_string t)
in (let _131_134 = (sli m0)
in (let _131_133 = (sli m1)
in (FStar_Util.format4 "(MonadicLift-%s{%s} %s -> %s)" _131_136 _131_135 _131_134 _131_133)))))
end
| FStar_Syntax_Syntax.Tm_meta (t, FStar_Syntax_Syntax.Meta_labeled (l, r, b)) when (FStar_Options.print_implicits ()) -> begin
(let _131_138 = (FStar_Range.string_of_range r)
in (let _131_137 = (term_to_string t)
in (FStar_Util.format3 "Meta_labeled(%s, %s){%s}" l _131_138 _131_137)))
end
| FStar_Syntax_Syntax.Tm_meta (t, _39_256) -> begin
(term_to_string t)
end
| FStar_Syntax_Syntax.Tm_bvar (x) -> begin
(db_to_string x)
end
| FStar_Syntax_Syntax.Tm_name (x) -> begin
(nm_to_string x)
end
| FStar_Syntax_Syntax.Tm_fvar (f) -> begin
(fv_to_string f)
end
| FStar_Syntax_Syntax.Tm_uvar (u, _39_267) -> begin
(uvar_to_string u)
end
| FStar_Syntax_Syntax.Tm_constant (c) -> begin
(const_to_string c)
end
| FStar_Syntax_Syntax.Tm_type (u) -> begin
if (FStar_Options.print_universes ()) then begin
(let _131_139 = (univ_to_string u)
in (FStar_Util.format1 "Type(%s)" _131_139))
end else begin
"Type"
end
end
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
(let _131_141 = (binders_to_string " -> " bs)
in (let _131_140 = (comp_to_string c)
in (FStar_Util.format2 "(%s -> %s)" _131_141 _131_140)))
end
| FStar_Syntax_Syntax.Tm_abs (bs, t2, lc) -> begin
(match (lc) with
| Some (FStar_Util.Inl (l)) when (FStar_Options.print_implicits ()) -> begin
(let _131_145 = (binders_to_string " " bs)
in (let _131_144 = (term_to_string t2)
in (let _131_143 = (let _131_142 = (l.FStar_Syntax_Syntax.comp ())
in (FStar_All.pipe_left comp_to_string _131_142))
in (FStar_Util.format3 "(fun %s -> (%s $$ %s))" _131_145 _131_144 _131_143))))
end
| Some (FStar_Util.Inr (l)) when (FStar_Options.print_implicits ()) -> begin
(let _131_147 = (binders_to_string " " bs)
in (let _131_146 = (term_to_string t2)
in (FStar_Util.format3 "(fun %s -> (%s $$ (name only) %s))" _131_147 _131_146 l.FStar_Ident.str)))
end
| _39_290 -> begin
(let _131_149 = (binders_to_string " " bs)
in (let _131_148 = (term_to_string t2)
in (FStar_Util.format2 "(fun %s -> %s)" _131_149 _131_148)))
end)
end
| FStar_Syntax_Syntax.Tm_refine (xt, f) -> begin
(let _131_152 = (bv_to_string xt)
in (let _131_151 = (FStar_All.pipe_right xt.FStar_Syntax_Syntax.sort term_to_string)
in (let _131_150 = (FStar_All.pipe_right f formula_to_string)
in (FStar_Util.format3 "(%s:%s{%s})" _131_152 _131_151 _131_150))))
end
| FStar_Syntax_Syntax.Tm_app (t, args) -> begin
(let _131_154 = (term_to_string t)
in (let _131_153 = (args_to_string args)
in (FStar_Util.format2 "(%s %s)" _131_154 _131_153)))
end
| FStar_Syntax_Syntax.Tm_let (lbs, e) -> begin
(let _131_156 = (lbs_to_string [] lbs)
in (let _131_155 = (term_to_string e)
in (FStar_Util.format2 "%s\nin\n%s" _131_156 _131_155)))
end
| FStar_Syntax_Syntax.Tm_ascribed (e, FStar_Util.Inl (t), _39_307) -> begin
(let _131_158 = (term_to_string e)
in (let _131_157 = (term_to_string t)
in (FStar_Util.format2 "(%s : %s)" _131_158 _131_157)))
end
| FStar_Syntax_Syntax.Tm_ascribed (e, FStar_Util.Inr (c), _39_314) -> begin
(let _131_160 = (term_to_string e)
in (let _131_159 = (comp_to_string c)
in (FStar_Util.format2 "(%s : %s)" _131_160 _131_159)))
end
| FStar_Syntax_Syntax.Tm_match (head, branches) -> begin
(let _131_168 = (term_to_string head)
in (let _131_167 = (let _131_166 = (FStar_All.pipe_right branches (FStar_List.map (fun _39_324 -> (match (_39_324) with
| (p, wopt, e) -> begin
(let _131_165 = (FStar_All.pipe_right p pat_to_string)
in (let _131_164 = (match (wopt) with
| None -> begin
""
end
| Some (w) -> begin
(let _131_162 = (FStar_All.pipe_right w term_to_string)
in (FStar_Util.format1 "when %s" _131_162))
end)
in (let _131_163 = (FStar_All.pipe_right e term_to_string)
in (FStar_Util.format3 "%s %s -> %s" _131_165 _131_164 _131_163))))
end))))
in (FStar_Util.concat_l "\n\t|" _131_166))
in (FStar_Util.format2 "(match %s with\n\t| %s)" _131_168 _131_167)))
end
| FStar_Syntax_Syntax.Tm_uinst (t, us) -> begin
if (FStar_Options.print_universes ()) then begin
(let _131_170 = (term_to_string t)
in (let _131_169 = (univs_to_string us)
in (FStar_Util.format2 "%s<%s>" _131_170 _131_169)))
end else begin
(term_to_string t)
end
end
| _39_333 -> begin
(tag_of_term x)
end)))
and pat_to_string : FStar_Syntax_Syntax.pat  ->  Prims.string = (fun x -> (match (x.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_cons (l, pats) -> begin
(let _131_175 = (fv_to_string l)
in (let _131_174 = (let _131_173 = (FStar_List.map (fun _39_341 -> (match (_39_341) with
| (x, b) -> begin
(

let p = (pat_to_string x)
in if b then begin
(Prims.strcat "#" p)
end else begin
p
end)
end)) pats)
in (FStar_All.pipe_right _131_173 (FStar_String.concat " ")))
in (FStar_Util.format2 "(%s %s)" _131_175 _131_174)))
end
| FStar_Syntax_Syntax.Pat_dot_term (x, _39_345) -> begin
if (FStar_Options.print_bound_var_types ()) then begin
(let _131_177 = (bv_to_string x)
in (let _131_176 = (term_to_string x.FStar_Syntax_Syntax.sort)
in (FStar_Util.format2 ".%s:%s" _131_177 _131_176)))
end else begin
(let _131_178 = (bv_to_string x)
in (FStar_Util.format1 ".%s" _131_178))
end
end
| FStar_Syntax_Syntax.Pat_var (x) -> begin
if (FStar_Options.print_bound_var_types ()) then begin
(let _131_180 = (bv_to_string x)
in (let _131_179 = (term_to_string x.FStar_Syntax_Syntax.sort)
in (FStar_Util.format2 "%s:%s" _131_180 _131_179)))
end else begin
(bv_to_string x)
end
end
| FStar_Syntax_Syntax.Pat_constant (c) -> begin
(const_to_string c)
end
| FStar_Syntax_Syntax.Pat_wild (x) -> begin
if (FStar_Options.print_real_names ()) then begin
(let _131_181 = (bv_to_string x)
in (Prims.strcat "Pat_wild " _131_181))
end else begin
"_"
end
end
| FStar_Syntax_Syntax.Pat_disj (ps) -> begin
(let _131_182 = (FStar_List.map pat_to_string ps)
in (FStar_Util.concat_l " | " _131_182))
end))
and lbs_to_string : FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Syntax_Syntax.letbindings  ->  Prims.string = (fun quals lbs -> (

let lbs = if (FStar_Options.print_universes ()) then begin
(let _131_188 = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (

let _39_361 = (let _131_186 = (FStar_Syntax_Util.mk_conj lb.FStar_Syntax_Syntax.lbtyp lb.FStar_Syntax_Syntax.lbdef)
in (FStar_Syntax_Subst.open_univ_vars lb.FStar_Syntax_Syntax.lbunivs _131_186))
in (match (_39_361) with
| (us, td) -> begin
(

let _39_379 = (match ((let _131_187 = (FStar_Syntax_Subst.compress td)
in _131_187.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_app (_39_363, ((t, _39_370))::((d, _39_366))::[]) -> begin
((t), (d))
end
| _39_376 -> begin
(FStar_All.failwith "Impossibe")
end)
in (match (_39_379) with
| (t, d) -> begin
(

let _39_380 = lb
in {FStar_Syntax_Syntax.lbname = _39_380.FStar_Syntax_Syntax.lbname; FStar_Syntax_Syntax.lbunivs = us; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = _39_380.FStar_Syntax_Syntax.lbeff; FStar_Syntax_Syntax.lbdef = d})
end))
end)))))
in (((Prims.fst lbs)), (_131_188)))
end else begin
lbs
end
in (let _131_198 = (quals_to_string quals)
in (let _131_197 = (let _131_196 = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (let _131_195 = (lbname_to_string lb.FStar_Syntax_Syntax.lbname)
in (let _131_194 = if (FStar_Options.print_universes ()) then begin
(let _131_191 = (let _131_190 = (univ_names_to_string lb.FStar_Syntax_Syntax.lbunivs)
in (Prims.strcat _131_190 ">"))
in (Prims.strcat "<" _131_191))
end else begin
""
end
in (let _131_193 = (term_to_string lb.FStar_Syntax_Syntax.lbtyp)
in (let _131_192 = (FStar_All.pipe_right lb.FStar_Syntax_Syntax.lbdef term_to_string)
in (FStar_Util.format4 "%s %s : %s = %s" _131_195 _131_194 _131_193 _131_192))))))))
in (FStar_Util.concat_l "\n and " _131_196))
in (FStar_Util.format3 "%slet %s %s" _131_198 (if (Prims.fst lbs) then begin
"rec"
end else begin
""
end) _131_197)))))
and lcomp_to_string : FStar_Syntax_Syntax.lcomp  ->  Prims.string = (fun lc -> (let _131_201 = (sli lc.FStar_Syntax_Syntax.eff_name)
in (let _131_200 = (term_to_string lc.FStar_Syntax_Syntax.res_typ)
in (FStar_Util.format2 "%s %s" _131_201 _131_200))))
and imp_to_string : Prims.string  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option  ->  Prims.string = (fun s _39_5 -> (match (_39_5) with
| Some (FStar_Syntax_Syntax.Implicit (false)) -> begin
(Prims.strcat "#" s)
end
| Some (FStar_Syntax_Syntax.Implicit (true)) -> begin
(Prims.strcat "#." s)
end
| Some (FStar_Syntax_Syntax.Equality) -> begin
(Prims.strcat "$" s)
end
| _39_396 -> begin
s
end))
and binder_to_string' : Prims.bool  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option)  ->  Prims.string = (fun is_arrow b -> (

let _39_401 = b
in (match (_39_401) with
| (a, imp) -> begin
if (FStar_Syntax_Syntax.is_null_binder b) then begin
(let _131_206 = (term_to_string a.FStar_Syntax_Syntax.sort)
in (Prims.strcat "_:" _131_206))
end else begin
if ((not (is_arrow)) && (not ((FStar_Options.print_bound_var_types ())))) then begin
(let _131_207 = (nm_to_string a)
in (imp_to_string _131_207 imp))
end else begin
(let _131_211 = (let _131_210 = (nm_to_string a)
in (let _131_209 = (let _131_208 = (term_to_string a.FStar_Syntax_Syntax.sort)
in (Prims.strcat ":" _131_208))
in (Prims.strcat _131_210 _131_209)))
in (imp_to_string _131_211 imp))
end
end
end)))
and binder_to_string : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option)  ->  Prims.string = (fun b -> (binder_to_string' false b))
and arrow_binder_to_string : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option)  ->  Prims.string = (fun b -> (binder_to_string' true b))
and binders_to_string : Prims.string  ->  FStar_Syntax_Syntax.binders  ->  Prims.string = (fun sep bs -> (

let bs = if (FStar_Options.print_implicits ()) then begin
bs
end else begin
(filter_imp bs)
end
in if (sep = " -> ") then begin
(let _131_216 = (FStar_All.pipe_right bs (FStar_List.map arrow_binder_to_string))
in (FStar_All.pipe_right _131_216 (FStar_String.concat sep)))
end else begin
(let _131_217 = (FStar_All.pipe_right bs (FStar_List.map binder_to_string))
in (FStar_All.pipe_right _131_217 (FStar_String.concat sep)))
end))
and arg_to_string : (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option)  ->  Prims.string = (fun _39_6 -> (match (_39_6) with
| (a, imp) -> begin
(let _131_219 = (term_to_string a)
in (imp_to_string _131_219 imp))
end))
and args_to_string : FStar_Syntax_Syntax.args  ->  Prims.string = (fun args -> (

let args = if (FStar_Options.print_implicits ()) then begin
args
end else begin
(filter_imp args)
end
in (let _131_221 = (FStar_All.pipe_right args (FStar_List.map arg_to_string))
in (FStar_All.pipe_right _131_221 (FStar_String.concat " ")))))
and comp_to_string : FStar_Syntax_Syntax.comp  ->  Prims.string = (fun c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (t) -> begin
(match ((let _131_223 = (FStar_Syntax_Subst.compress t)
in _131_223.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_type (_39_417) when (not ((FStar_Options.print_implicits ()))) -> begin
(term_to_string t)
end
| _39_420 -> begin
(let _131_224 = (term_to_string t)
in (FStar_Util.format1 "Tot %s" _131_224))
end)
end
| FStar_Syntax_Syntax.GTotal (t) -> begin
(match ((let _131_225 = (FStar_Syntax_Subst.compress t)
in _131_225.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_type (_39_424) when (not ((FStar_Options.print_implicits ()))) -> begin
(term_to_string t)
end
| _39_427 -> begin
(let _131_226 = (term_to_string t)
in (FStar_Util.format1 "GTot %s" _131_226))
end)
end
| FStar_Syntax_Syntax.Comp (c) -> begin
(

let basic = if ((FStar_All.pipe_right c.FStar_Syntax_Syntax.flags (FStar_Util.for_some (fun _39_7 -> (match (_39_7) with
| FStar_Syntax_Syntax.TOTAL -> begin
true
end
| _39_433 -> begin
false
end)))) && (not ((FStar_Options.print_effect_args ())))) then begin
(let _131_228 = (term_to_string c.FStar_Syntax_Syntax.result_typ)
in (FStar_Util.format1 "Tot %s" _131_228))
end else begin
if (((not ((FStar_Options.print_effect_args ()))) && (not ((FStar_Options.print_implicits ())))) && (FStar_Ident.lid_equals c.FStar_Syntax_Syntax.effect_name FStar_Syntax_Const.effect_ML_lid)) then begin
(term_to_string c.FStar_Syntax_Syntax.result_typ)
end else begin
if ((not ((FStar_Options.print_effect_args ()))) && (FStar_All.pipe_right c.FStar_Syntax_Syntax.flags (FStar_Util.for_some (fun _39_8 -> (match (_39_8) with
| FStar_Syntax_Syntax.MLEFFECT -> begin
true
end
| _39_437 -> begin
false
end))))) then begin
(let _131_230 = (term_to_string c.FStar_Syntax_Syntax.result_typ)
in (FStar_Util.format1 "ALL %s" _131_230))
end else begin
if (FStar_Options.print_effect_args ()) then begin
(let _131_234 = (sli c.FStar_Syntax_Syntax.effect_name)
in (let _131_233 = (term_to_string c.FStar_Syntax_Syntax.result_typ)
in (let _131_232 = (let _131_231 = (FStar_All.pipe_right c.FStar_Syntax_Syntax.effect_args (FStar_List.map arg_to_string))
in (FStar_All.pipe_right _131_231 (FStar_String.concat ", ")))
in (FStar_Util.format3 "%s (%s) %s" _131_234 _131_233 _131_232))))
end else begin
(let _131_236 = (sli c.FStar_Syntax_Syntax.effect_name)
in (let _131_235 = (term_to_string c.FStar_Syntax_Syntax.result_typ)
in (FStar_Util.format2 "%s (%s)" _131_236 _131_235)))
end
end
end
end
in (

let dec = (let _131_240 = (FStar_All.pipe_right c.FStar_Syntax_Syntax.flags (FStar_List.collect (fun _39_9 -> (match (_39_9) with
| FStar_Syntax_Syntax.DECREASES (e) -> begin
(let _131_239 = (let _131_238 = (term_to_string e)
in (FStar_Util.format1 " (decreases %s)" _131_238))
in (_131_239)::[])
end
| _39_443 -> begin
[]
end))))
in (FStar_All.pipe_right _131_240 (FStar_String.concat " ")))
in (FStar_Util.format2 "%s%s" basic dec)))
end))
and formula_to_string : FStar_Syntax_Syntax.term  ->  Prims.string = (fun phi -> (term_to_string phi))


let tscheme_to_string : FStar_Syntax_Syntax.tscheme  ->  Prims.string = (fun _39_448 -> (match (_39_448) with
| (us, t) -> begin
(let _131_245 = (univ_names_to_string us)
in (let _131_244 = (term_to_string t)
in (FStar_Util.format2 "<%s> %s" _131_245 _131_244)))
end))


let eff_decl_to_string : Prims.bool  ->  FStar_Syntax_Syntax.eff_decl  ->  Prims.string = (fun for_free ed -> (

let actions_to_string = (fun actions -> (let _131_257 = (FStar_All.pipe_right actions (FStar_List.map (fun a -> (let _131_256 = (sli a.FStar_Syntax_Syntax.action_name)
in (let _131_255 = (univ_names_to_string a.FStar_Syntax_Syntax.action_univs)
in (let _131_254 = (term_to_string a.FStar_Syntax_Syntax.action_typ)
in (let _131_253 = (term_to_string a.FStar_Syntax_Syntax.action_defn)
in (FStar_Util.format4 "%s<%s> : %s = %s" _131_256 _131_255 _131_254 _131_253))))))))
in (FStar_All.pipe_right _131_257 (FStar_String.concat ",\n\t"))))
in (let _131_294 = (let _131_293 = (let _131_292 = (lid_to_string ed.FStar_Syntax_Syntax.mname)
in (let _131_291 = (let _131_290 = (univ_names_to_string ed.FStar_Syntax_Syntax.univs)
in (let _131_289 = (let _131_288 = (binders_to_string " " ed.FStar_Syntax_Syntax.binders)
in (let _131_287 = (let _131_286 = (term_to_string ed.FStar_Syntax_Syntax.signature)
in (let _131_285 = (let _131_284 = (tscheme_to_string ed.FStar_Syntax_Syntax.ret_wp)
in (let _131_283 = (let _131_282 = (tscheme_to_string ed.FStar_Syntax_Syntax.bind_wp)
in (let _131_281 = (let _131_280 = (tscheme_to_string ed.FStar_Syntax_Syntax.if_then_else)
in (let _131_279 = (let _131_278 = (tscheme_to_string ed.FStar_Syntax_Syntax.ite_wp)
in (let _131_277 = (let _131_276 = (tscheme_to_string ed.FStar_Syntax_Syntax.stronger)
in (let _131_275 = (let _131_274 = (tscheme_to_string ed.FStar_Syntax_Syntax.close_wp)
in (let _131_273 = (let _131_272 = (tscheme_to_string ed.FStar_Syntax_Syntax.assert_p)
in (let _131_271 = (let _131_270 = (tscheme_to_string ed.FStar_Syntax_Syntax.assume_p)
in (let _131_269 = (let _131_268 = (tscheme_to_string ed.FStar_Syntax_Syntax.null_wp)
in (let _131_267 = (let _131_266 = (tscheme_to_string ed.FStar_Syntax_Syntax.trivial)
in (let _131_265 = (let _131_264 = (term_to_string ed.FStar_Syntax_Syntax.repr)
in (let _131_263 = (let _131_262 = (tscheme_to_string ed.FStar_Syntax_Syntax.bind_repr)
in (let _131_261 = (let _131_260 = (tscheme_to_string ed.FStar_Syntax_Syntax.return_repr)
in (let _131_259 = (let _131_258 = (actions_to_string ed.FStar_Syntax_Syntax.actions)
in (_131_258)::[])
in (_131_260)::_131_259))
in (_131_262)::_131_261))
in (_131_264)::_131_263))
in (_131_266)::_131_265))
in (_131_268)::_131_267))
in (_131_270)::_131_269))
in (_131_272)::_131_271))
in (_131_274)::_131_273))
in (_131_276)::_131_275))
in (_131_278)::_131_277))
in (_131_280)::_131_279))
in (_131_282)::_131_281))
in (_131_284)::_131_283))
in (_131_286)::_131_285))
in (_131_288)::_131_287))
in (_131_290)::_131_289))
in (_131_292)::_131_291))
in (if for_free then begin
"for free "
end else begin
""
end)::_131_293)
in (FStar_Util.format "new_effect %s{ %s<%s> %s : %s \n  ret         = %s\n; bind_wp     = %s\n; if_then_else= %s\n; ite_wp      = %s\n; stronger    = %s\n; close_wp    = %s\n; assert_p    = %s\n; assume_p    = %s\n; null_wp     = %s\n; trivial     = %s\n; repr        = %s\n; bind_repr   = %s\n; return_repr = %s\n; actions     = \n\t%s\n}\n" _131_294))))


let rec sigelt_to_string : FStar_Syntax_Syntax.sigelt  ->  Prims.string = (fun x -> (match (x) with
| FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.ResetOptions (None), _39_458) -> begin
"#reset-options"
end
| FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.ResetOptions (Some (s)), _39_465) -> begin
(FStar_Util.format1 "#reset-options \"%s\"" s)
end
| FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.SetOptions (s), _39_471) -> begin
(FStar_Util.format1 "#set-options \"%s\"" s)
end
| FStar_Syntax_Syntax.Sig_inductive_typ (lid, univs, tps, k, _39_479, _39_481, quals, _39_484) -> begin
(let _131_299 = (quals_to_string quals)
in (let _131_298 = (binders_to_string " " tps)
in (let _131_297 = (term_to_string k)
in (FStar_Util.format4 "%s type %s %s : %s" _131_299 lid.FStar_Ident.str _131_298 _131_297))))
end
| FStar_Syntax_Syntax.Sig_datacon (lid, univs, t, _39_491, _39_493, _39_495, _39_497, _39_499) -> begin
if (FStar_Options.print_universes ()) then begin
(

let _39_504 = (FStar_Syntax_Subst.open_univ_vars univs t)
in (match (_39_504) with
| (univs, t) -> begin
(let _131_301 = (univ_names_to_string univs)
in (let _131_300 = (term_to_string t)
in (FStar_Util.format3 "datacon<%s> %s : %s" _131_301 lid.FStar_Ident.str _131_300)))
end))
end else begin
(let _131_302 = (term_to_string t)
in (FStar_Util.format2 "datacon %s : %s" lid.FStar_Ident.str _131_302))
end
end
| FStar_Syntax_Syntax.Sig_declare_typ (lid, univs, t, quals, _39_510) -> begin
(

let _39_515 = (FStar_Syntax_Subst.open_univ_vars univs t)
in (match (_39_515) with
| (univs, t) -> begin
(let _131_306 = (quals_to_string quals)
in (let _131_305 = if (FStar_Options.print_universes ()) then begin
(let _131_303 = (univ_names_to_string univs)
in (FStar_Util.format1 "<%s>" _131_303))
end else begin
""
end
in (let _131_304 = (term_to_string t)
in (FStar_Util.format4 "%s val %s %s : %s" _131_306 lid.FStar_Ident.str _131_305 _131_304))))
end))
end
| FStar_Syntax_Syntax.Sig_assume (lid, f, _39_519, _39_521) -> begin
(let _131_307 = (term_to_string f)
in (FStar_Util.format2 "val %s : %s" lid.FStar_Ident.str _131_307))
end
| FStar_Syntax_Syntax.Sig_let (lbs, _39_526, _39_528, qs) -> begin
(lbs_to_string qs lbs)
end
| FStar_Syntax_Syntax.Sig_main (e, _39_534) -> begin
(let _131_308 = (term_to_string e)
in (FStar_Util.format1 "let _ = %s" _131_308))
end
| FStar_Syntax_Syntax.Sig_bundle (ses, _39_539, _39_541, _39_543) -> begin
(let _131_309 = (FStar_List.map sigelt_to_string ses)
in (FStar_All.pipe_right _131_309 (FStar_String.concat "\n")))
end
| FStar_Syntax_Syntax.Sig_new_effect (ed, _39_548) -> begin
(eff_decl_to_string false ed)
end
| FStar_Syntax_Syntax.Sig_new_effect_for_free (ed, _39_553) -> begin
(eff_decl_to_string true ed)
end
| FStar_Syntax_Syntax.Sig_sub_effect (se, r) -> begin
(

let _39_562 = (FStar_Syntax_Subst.open_univ_vars (Prims.fst se.FStar_Syntax_Syntax.lift_wp) (Prims.snd se.FStar_Syntax_Syntax.lift_wp))
in (match (_39_562) with
| (us, t) -> begin
(let _131_313 = (lid_to_string se.FStar_Syntax_Syntax.source)
in (let _131_312 = (lid_to_string se.FStar_Syntax_Syntax.target)
in (let _131_311 = (univ_names_to_string us)
in (let _131_310 = (term_to_string t)
in (FStar_Util.format4 "sub_effect %s ~> %s : <%s> %s" _131_313 _131_312 _131_311 _131_310)))))
end))
end
| FStar_Syntax_Syntax.Sig_effect_abbrev (l, univs, tps, c, _39_568, _39_570) -> begin
if (FStar_Options.print_universes ()) then begin
(

let _39_575 = (let _131_314 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_arrow (((tps), (c)))) None FStar_Range.dummyRange)
in (FStar_Syntax_Subst.open_univ_vars univs _131_314))
in (match (_39_575) with
| (univs, t) -> begin
(

let _39_584 = (match ((let _131_315 = (FStar_Syntax_Subst.compress t)
in _131_315.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
((bs), (c))
end
| _39_581 -> begin
(FStar_All.failwith "impossible")
end)
in (match (_39_584) with
| (tps, c) -> begin
(let _131_319 = (sli l)
in (let _131_318 = (univ_names_to_string univs)
in (let _131_317 = (binders_to_string " " tps)
in (let _131_316 = (comp_to_string c)
in (FStar_Util.format4 "effect %s<%s> %s = %s" _131_319 _131_318 _131_317 _131_316)))))
end))
end))
end else begin
(let _131_322 = (sli l)
in (let _131_321 = (binders_to_string " " tps)
in (let _131_320 = (comp_to_string c)
in (FStar_Util.format3 "effect %s %s = %s" _131_322 _131_321 _131_320))))
end
end))


let format_error : FStar_Range.range  ->  Prims.string  ->  Prims.string = (fun r msg -> (let _131_327 = (FStar_Range.string_of_range r)
in (FStar_Util.format2 "%s: %s\n" _131_327 msg)))


let rec sigelt_to_string_short : FStar_Syntax_Syntax.sigelt  ->  Prims.string = (fun x -> (match (x) with
| FStar_Syntax_Syntax.Sig_let ((_39_589, ({FStar_Syntax_Syntax.lbname = lb; FStar_Syntax_Syntax.lbunivs = _39_596; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = _39_593; FStar_Syntax_Syntax.lbdef = _39_591})::[]), _39_602, _39_604, _39_606) -> begin
(let _131_331 = (lbname_to_string lb)
in (let _131_330 = (term_to_string t)
in (FStar_Util.format2 "let %s : %s" _131_331 _131_330)))
end
| _39_610 -> begin
(let _131_334 = (let _131_333 = (FStar_Syntax_Util.lids_of_sigelt x)
in (FStar_All.pipe_right _131_333 (FStar_List.map (fun l -> l.FStar_Ident.str))))
in (FStar_All.pipe_right _131_334 (FStar_String.concat ", ")))
end))


let rec modul_to_string : FStar_Syntax_Syntax.modul  ->  Prims.string = (fun m -> (let _131_339 = (sli m.FStar_Syntax_Syntax.name)
in (let _131_338 = (let _131_337 = (FStar_List.map sigelt_to_string m.FStar_Syntax_Syntax.declarations)
in (FStar_All.pipe_right _131_337 (FStar_String.concat "\n")))
in (FStar_Util.format2 "module %s\n%s" _131_339 _131_338))))


let subst_elt_to_string : FStar_Syntax_Syntax.subst_elt  ->  Prims.string = (fun _39_10 -> (match (_39_10) with
| FStar_Syntax_Syntax.DB (i, x) -> begin
(let _131_343 = (FStar_Util.string_of_int i)
in (let _131_342 = (bv_to_string x)
in (FStar_Util.format2 "DB (%s, %s)" _131_343 _131_342)))
end
| FStar_Syntax_Syntax.NM (x, i) -> begin
(let _131_345 = (bv_to_string x)
in (let _131_344 = (FStar_Util.string_of_int i)
in (FStar_Util.format2 "NM (%s, %s)" _131_345 _131_344)))
end
| FStar_Syntax_Syntax.NT (x, t) -> begin
(let _131_347 = (bv_to_string x)
in (let _131_346 = (term_to_string t)
in (FStar_Util.format2 "DB (%s, %s)" _131_347 _131_346)))
end
| FStar_Syntax_Syntax.UN (i, u) -> begin
(let _131_349 = (FStar_Util.string_of_int i)
in (let _131_348 = (univ_to_string u)
in (FStar_Util.format2 "UN (%s, %s)" _131_349 _131_348)))
end
| FStar_Syntax_Syntax.UD (u, i) -> begin
(let _131_350 = (FStar_Util.string_of_int i)
in (FStar_Util.format2 "UD (%s, %s)" u.FStar_Ident.idText _131_350))
end))


let subst_to_string : FStar_Syntax_Syntax.subst_t  ->  Prims.string = (fun s -> (let _131_353 = (FStar_All.pipe_right s (FStar_List.map subst_elt_to_string))
in (FStar_All.pipe_right _131_353 (FStar_String.concat "; "))))




