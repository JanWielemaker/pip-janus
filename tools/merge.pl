:- module(cleanup,
          [
          ]).
:- use_module(library(dcg/basics)).
:- use_module(library(main)).
:- use_module(library(pure_input)).
:- use_module(library(dcg/high_order)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(option)).
:- use_module(library(prolog_code)).

:- initialization(main, main).

main(Argv) :-
    argv_options(Argv, Pos, Options),
    run(Pos, Options).

opt_type(preds, preds, boolean).
opt_type(interleave, interleave, boolean).

opt_help(preds, "Only extract predicates").
opt_help(interleave, "Interleave the contents of two documents").

run([XSB, SWI, Out], Options) :-
    option(interleave(true), Options),
    !,
    file_structure(XSB, XSBStructure, Options),
    file_structure(SWI, SWIStructure, Options),
    interleave(XSBStructure, SWIStructure, Structure),
    emit_to_file(Out, Structure).
run([In, Out], Options) :-
    !,
    file_structure(In, Structure, Options),
    emit_to_file(Out, Structure).
run(_, _) :-
    argv_usage(debug).

file_structure(In, Structure, Options) :-
    phrase_from_file(parse(Contents), In),
    extract_structure(Contents, Structure, Options).

emit_to_file(File, Structure) :-
    emit(Structure, Codes),
    setup_call_cleanup(
        open(File, write, S),
        format(S, '~s', [Codes]),
        close(S)).

parse(Contents) -->
    string(Pre),
    match(Term),
    !,
    { codes_lines(Pre, Contents, [Term|T])
    },
    parse(T).
parse(Contents) -->
    string(Rest),
    eos,
    !,
    { codes_lines(Rest, Contents, [])
    }.

codes_lines(Codes, Lines, Tail) :-
    phrase(codes_lines(Lines, Tail), Codes).

codes_lines([nl(N)|T0], T) -->
    "\n", !, blank_lines(1, N),
    codes_lines(T0, T).
codes_lines([s(Line), nl(N)|T0], T) -->
    string(L),
    "\n", !, blank_lines(1, N),
    { string_codes(Line, L) },
    codes_lines(T0, T).
codes_lines([s(Line)|T], T) -->
    string(Rest),
    eos,
    !,
    { string_codes(Line, Rest) }.

blank_lines(N0, N) -->
    whites, "\n",
    !,
    { N1 is N0+1 },
    blank_lines(N1, N).
blank_lines(N, N) -->
    "".


		 /*******************************
		 *            MATCHING		*
		 *******************************/

match(Term) --> swi_pred_def(Term).
match(Term) --> swi_pred_ref(Term).
match(Term) --> xsb_pred_def(Term).
match(Term) --> md_header(Term).
match(Term) --> swi_match_python_func(Term), {writeln(Term)}.
match(Term) --> xsb_match_python_func(Term), {writeln(Term)}.

%!  swi_pred_def(-Def)//

swi_pred_def(pred(Head)) -->
    optional("-", ""),
    whites,
    optional(swi_tag(_Tag), ""),
    id_span_open(_),
    "**", csym(Name), "**",
    swi_args(Args),
    id_span_close,
    !,
    whites,
    { Head =.. [Name|Args] }.

id_span_open(Id) -->
    "<span id=\"", string(Codes), "\">",
    !,
    { atom_codes(Id, Codes) }.
id_span_close -->
    "</span>".

swi_tag(Tag) -->
    "<span class=\"pred-tag\">",
    tag_content(Tag),
    "</span>",
    !.

tag_content(Tag) -->
    "\\[", string(Codes), "\\]",
    { atom_codes(Tag, Codes) }.

swi_args(List) -->
    args_begin(Style), !, swi_arg_list(List), args_end(Style), whites.
swi_args([]) -->
    whites.

args_begin(c) --> "(`".
args_begin(p) --> "(".
args_end(c) --> "`)".
args_end(p) --> ")".

swi_arg_list([H|T]) -->
    swi_arg(H),
    !,
    blanks,
    (   ","
    ->  swi_arg_list(T)
    ;   { T=[] }
    ).

swi_arg(Arg) -->
    blanks,
    swi_mode(Mode),
    prolog_var_name(Name),
    { Arg =.. [Mode,Name] }.

swi_mode(+) --> "+".
swi_mode(?) --> "?".
swi_mode(-) --> "-".
swi_mode(@) --> "@".

xsb_pred_def(pred(Head)) -->
    "\n`", csym(Name), swi_args(Args), "`\n",
    { Head =.. [Name|Args] }.

swi_pred_ref(predref(Name/Arity)) -->
    "[", csym(Name), "/", integer(Arity), "](#", string(_), ")".

md_header(h(Level, Title)) -->
    "\n", hlevel(Level), !, whites, string(Codes), whites, "\n",
    { string_codes(Title, Codes) }.

hlevel(5) --> "#####".
hlevel(4) --> "####".
hlevel(3) --> "###".
hlevel(2) --> "##".
hlevel(1) --> "#".

swi_match_python_func(py_func(Return, Name, Args)) -->
    optional("-", ""), whites,
    id_span_open(_),
    code_atom(Return), whites, bold_atom(QName), "(", code_atom(Args0), ")",
    id_span_close,
    !,
    { py_unqualify(QName, Name),
      starts_lower(Name),
      normalize_space(atom(Args), Args0)
    }.

py_unqualify(QName, Name) :-
    atom_concat('janus.', Name, QName),
    !.
py_unqualify(Name, Name).

starts_lower(Atom) :-
    sub_atom(Atom, 0, 1, _, First),
    char_type(First, lower).

code_atom(Atom) -->
    code_delim(S), string(Codes), code_delim(S), !,
    { atom_codes(Atom, Codes) }.
bold_atom(Atom) -->
    bold_delim(S), string(Codes), bold_delim(S), !,
    { atom_codes(Atom, Codes) }.

code_delim('``') --> "``".
code_delim('`') --> "`".

bold_delim('__') --> "__".
bold_delim('**') --> "**".

xsb_match_python_func(py_func('', Name, Args)) -->
    "\n`", csym(Name), "(", py_args(ArgList), ")`\n",
    !,
    { atomic_list_concat(ArgList, ', ', Args) }.

py_args([]), ")"--> ")", !.
py_args([H|T]) -->
    py_arg(H),
    whites,
    (   ","
    ->  py_args(T)
    ;   {T=[]}
    ).

py_arg(Arg) --> "**", py_arg_name(Name), !, {atom_concat('**', Name, Arg)}.
py_arg(Arg) --> "*", py_arg_name(Name),  !, {atom_concat('*', Name, Arg)}.
py_arg(Arg) --> py_arg_name(Arg), !.

py_arg_name(Name) -->
    sequence(lower, Codes),
    { Codes \== [] ,
      !,
      atom_codes(Name, Codes)
    }.

lower(0'_) --> "_".
lower(C) -->
    [C],
    { code_type(C, lower) }.




		 /*******************************
		 *            CLEANUP		*
		 *******************************/

extract_structure(Contents, Structure, Options) :-
    exclude(=(s("")), Contents, Contents1),
    phrase(structure(Structure0), Contents1),
    select_content(Structure0, Structure, Options).

%!  structure(-Structure)//
%
%   Recognise the document structure

:- det(structure//1).

structure([Preds|T]) -->
    preds(Preds),
    !,
    structure(T).
structure([Funcs|T]) -->
    funcs(Funcs),
    !,
    structure(T).
structure([Hdr|T]) -->
    skip_layout,
    hdr(Hdr),
    !,
    skip_layout,
    structure(T).
structure([H|T]) -->
    [H],
    !,
    structure(T).
structure([]) -->
    [].

%!  preds(-Term)//
%
%   Recognise a sequence of one or more predicate definitions

preds(preds([H|T], Description)) -->
    skip_layout,
    pred(H),
    !,
    preds_or_empty(T),
    string(Contents),
    skip_layout,
    peek(Next),
    { ends_descripton(Next),
      extract_structure(Contents, Description, [])
    }.

preds_or_empty([H|T]) -->
    skip_layout,
    pred(H),
    !,
    preds_or_empty(T).
preds_or_empty([]) -->
    optional(blank_text, []),
    optional([nl(_)], []).

skip_layout --> [nl(_)], !, skip_layout.
skip_layout --> blank_text, !, skip_layout.
skip_layout --> [].

blank_text -->
    [s(Text)],
    { split_string(Text, "", " \t", [""]) }.

%!  preds(-Term)//
%
%   Recognise a sequence of one or more Python functions

funcs(funcs([H|T], Description)) -->
    skip_layout,
    func(H),
    !,
    funcs_or_empty(T),
    string(Contents),
    skip_layout,
    peek(Next),
    { ends_descripton(Next),
      extract_structure(Contents, Description, [])
    }.

funcs_or_empty([H|T]) -->
    skip_layout,
    func(H),
    !,
    funcs_or_empty(T).
funcs_or_empty([]) -->
    optional(blank_text, []),
    optional([nl(_)], []).

func(F) --> { F = py_func(_,_,_) }, [F].
pred(P) --> { P = pred(_) }, [P].
hdr(H) --> { H = h(_,_) }, [H].
hdr(H) --> { H = h(_,_,_) }, [H].

ends_descripton(pred(_)) => true.
ends_descripton(py_func(_,_,_)) => true.
ends_descripton(h(_,_)) => true.
ends_descripton(h(_,_,_)) => true.
ends_descripton(_) => fail.

peek(H), [H] --> [H].


select_content(Structure0, Structure, Options) :-
    option(preds(true), Options),
    !,
    include(is_preds, Structure0, Structure).
select_content(Structure, Structure, _).

is_preds(preds(_Heads,_Content)).
is_preds(funcs(_Heads,_Content)).



		 /*******************************
		 *             EMIT		*
		 *******************************/

emit(Structure, Codes) :-
    add_vspace(Structure, Structure1),
    join_vspace(Structure1, Structure2),
    phrase(emit(Structure2), Codes).

vspace(preds(_,_), 2, 1).
vspace(h(_,_), 2, 2).
vspace(h(_,_,_), 2, 2).
vspace(toc(_,_), 1, 1).

%!  add_vspace(+StructureIn, -StructureOut) is det.

add_vspace([], []).
add_vspace([H|T0], [nl(Above),H,nl(Below)|T]) :-
    vspace(H, Above, Below),
    !,
    add_vspace(T0, T).
add_vspace([H|T0], [H|T]) :-
    add_vspace(T0, T).

join_vspace([], []).
join_vspace([nl(F)|T0], [nl(Max)|T]) :-
    !,
    max_vspace(T0, F, Max, T1),
    join_vspace(T1, T).
join_vspace([H|T0], [H|T]) :-
    join_vspace(T0, T).

max_vspace([nl(N)|T0], M0, M, T) =>
    M1 is max(N,M0),
    max_vspace(T0, M1, M, T).
max_vspace(T0, M0, M, T) =>
    T = T0,
    M = M0.

%!  emit(+Contents)//

:- det(emit//1).

emit([]) --> !,
    "".
emit([H|T]) --> !,
    emit(H),
    emit(T).
emit(nl(N)) --> !,
    foreach(between(1,N,_), "\n").
emit(s(Text)) --> !,
    { string_codes(Text, Codes)
    },
    string(Codes).
emit(preds(Preds, Description)) --> !,
    sequence(emit_pred, "\n", Preds),
    "\n",
    emit(Description).
emit(predref(Name/Arity)) --> !,
    emit_code([Name,/,Arity]).
emit(funcs(Funcs, Description)) --> !,
    sequence(emit_func, "\n", Funcs),
    "\n",
    emit(Description).
emit(h(Level, Title, _Anchor)) --> !,
    foreach(between(1,Level,_), "#"),
    " ", atom(Title).			% Not in gfm " {#", atom(Anchor), "}".
emit(h(Level, Title)) --> !,
    foreach(between(1,Level,_), "#"),
    " ", atom(Title).
emit(toc(Anchor, Title)) --> !,
    { toc_anchor(Anchor, Title, TheAnchor) },
    "  - [", atom(Title), "](#", atom(TheAnchor), ")".

emit_pred(pred(Head)) -->
    { Head =.. [Name|Args] },
    "  - ", emit_bold(Name),
    (   {Args == []}
    ->  ""
    ;   "(", emit_args(Args), ")<br>"
    ).

emit_args([H|T]) -->
    emit_arg(H),
    (   {T==[]}
    ->  ""
    ;   ", ",
        emit_args(T)
    ).

emit_arg(Arg) -->
    { Arg =.. [Mode,Name] },
    atom(Mode), atom(Name).

emit_func(py_func(Return, Name, Args)) --> !,
    "  - ", emit_code(Return), " ",
    emit_bold(Name), "(", emit_code(Args), ")<br>".

emit_bold(Name) -->
    "**", atom(Name), "**".

emit_code(Code) -->
    { atomic(Code) },
    !,
    "`", atom(Code), "`".
emit_code(List) -->
    "`", sequence(atom, List), "`".

%toc_anchor(Anchor, _Title, Anchor).		% Not for gfm
toc_anchor(_, Title, Anchor) :-
    string_lower(Title, TitleLwr),
    string_codes(TitleLwr, Codes),
    convlist(to_hyphen, Codes, Hyphenated),
    phrase(single_hyphen(SHCodes), Hyphenated),
    string_codes(Anchor, SHCodes).

to_hyphen(C, C) :-
    code_type(C, alnum),
    !.
to_hyphen(0'_, 0'_).
to_hyphen(0'\s, 0'-).

single_hyphen([0'-|T]) -->
    "-", !, hyphens,
    single_hyphen(T).
single_hyphen([H|T]) --> [H], !, single_hyphen(T).
single_hyphen([]) --> [].

hyphens --> "-", !, hyphens.
hyphens --> "".


		 /*******************************
		 *           INTERLEAVE		*
		 *******************************/

interleave(XSB, SWI, Structure) :-
    interleave(XSB, SWI, Structure0, TOC),
    append([ [h(1, 'Contents')],
             TOC,
             Structure0
           ], Structure).

interleave([], _, [], []).
interleave([First|XSB], SWI, Structure, [toc(Anchor, Title)|TOC]) :-
    doc_obj(First, XSBPreds, _),
    include(about_same_objs(XSBPreds), SWI, AboutSame),
    AboutSame \== [],
    !,
    append(AboutSame, Tail, SWIDocAndTail),
    maplist(arg(1), AboutSame, SWIPredLists),
    append([XSBPreds|SWIPredLists], AllPreds),
    preds_title(AllPreds, Title, Anchor),
    Structure = [ h(2, Title, Anchor),
                  h(3, 'XSB version'),
                  First,
                  h(3, 'SWI-Prolog version')
                | SWIDocAndTail
                ],
    interleave(XSB, SWI, Tail, TOC).
interleave([_|XSB], SWI, Structure, TOC) :-
    interleave(XSB, SWI, Structure, TOC).

doc_obj(preds(Preds, Doc), Preds, Doc).
doc_obj(funcs(Funcs, Doc), Funcs, Doc).

about_same_objs(XSBPreds, preds(SWIPreds, _)) :-
    member(pred(H1), XSBPreds),
    pi_head(PI, H1),
    member(pred(H2), SWIPreds),
    pi_head(PI, H2),
    !.
about_same_objs(XSBFuncs, funcs(SWIFuncs,_)) :-
    member(py_func(_Ret1, Name, _Args1), XSBFuncs),
    member(py_func(_Ret2, Name, _Args2), SWIFuncs),
    !.

preds_title(AllPreds, Title, Anchor) :-
    maplist(pred_pi, AllPreds, PIs),
    !,
    sort(PIs, UPIs),
    maplist(term_string, UPIs, UPIStr),
    atomics_to_string(UPIStr, ", ", Preds),
    format(string(Title), 'Predicate ~s', [Preds]),
    maplist(arg(1), UPIs, Names),
    sort(Names, UNames),
    atomics_to_string(UNames, ",", Anchor).
preds_title(AllFuncs, Title, Anchor) :-
    maplist(func_name, AllFuncs, Names),
    !,
    sort(Names, UNames),
    atomics_to_string(UNames, ", ", Funcs),
    format(string(Title), 'Python function ~s', [Funcs]),
    atomics_to_string(UNames, ",", Anchor).

pred_pi(pred(Head), PI) :-
    pi_head(PI, Head).

func_name(py_func(_Ret, Name, _Args), Name).
