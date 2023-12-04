::: center
** Credits **
:::

> Packages and interfaces have become an increasingly important part of
> XSB. They are an important way to incorporate code from other systems
> into XSB, and to interface XSB to databases and other stores. Most of
> the packages had significant contributions by people other than the
> core XSB developers, for which we are grateful. As a result most
> chapters have information about its authors.

::: center
# Janus: Calling Python from Prolog {#chap:januspy}
:::

::: center
**Version 2.0**
:::

::: center
**By Theresa Swift, Muthukumar Suresh, Carl Andersen**
:::

The new `janus` package provides an easy and highly efficient way for
Prolog to call Python3 functions and methods, and vice versa. `janus` is
originally based on the packages `xsbpy` and `px` [@SwiA23; @AndS23] and
has undergone a major rewrite with expanded functionality in close
collaboration with the SWI Prolog and Ciao Prolog teams.[^1] This
chapter describes Prolog calling Python, while Chapter
 [2](#chap:janus-py){reference-type="ref" reference="chap:janus-py"}
describes Python calling Prolog.

`janus` leverages the fact that the reference C-Python is written in C
(as are most Prologs), so that Prolog and Python can be readily loaded
into the same process. The core interface routines are also written
almost entirely in C, so the interface is very efficient (hundreds of
thousands to *millions* of round-trip calls between Prolog and Python
can be made per second) and it is hoped -- very robust within its known
restrictions. In addition, due to the dynamic typing of both Prolog and
Python, a simple bi-translation maps complex Python data structures to
and from Prolog terms. All of this this makes using Python from Prolog
as simple as consulting `janus` from XSB and calling Python. Calling
Prolog from Python is as simple: just add

    import janus_xsb

to a Python file or session, and start making calls.

This chapter first describes how to configure `janus-plg`, followed by
introductory examples. Next is a more precise description of its
functions and its current limitations followed by applications and
further examples.

## Introductory Examples

We introduce some of the core functionality of `janus-plg` via a series
of examples. As background, when `janus` is loaded, Python is also
loaded and initialized within the Prolog process, the core Prolog
modules of `janus` are loaded into Prolog, and paths to `janus` and its
sub-directories are added both to Prolog and to Python (the latter paths
are added by modifying Python's `sys.path`). Later, Prolog calls Python,
Python will search for modules and packages in the same manner as if
they were stand-alone.

::: {#ex:janus-json .example}
**Example 1.1**. ***Calling a Python Function (I)** *

**The translation of JSON through `janus-plg` in this example works
well, but for most purposes we recommend using XSB's native JSON
interface described in Chapter
[\[chap:json\]](#chap:json){reference-type="ref" reference="chap:json"}
of this manual.* *

*Suppose `janus` has been loaded by the command `?- [janus].` and
consider the call:*

    py_func(json,prolog_loads('{"name":"Demo term"
                                "created": {"day":null,
                                            "month":"December",
                                            "year":2007  },
                                "confirmed":true,
                                "members":[1,2,3]}'

*loads the Python `json` module and then calls the Python function*

*`json.loads()`*

*with the above JSON string as its argument. In Python the atom is
parsed and converted into a Python dictionary whose syntax is very close
to that of the JSON. Next, `janus` translates this dictionary to a
Prolog term that can be pretty printed as:*

    {name:'Demo term'),
     created:{day:@(none),
              month:'December',
              year:2007},
     confirmed:@(true),
     members:[1,2,3]}

*The syntactic flexibility of Prolog allows the Python dictionary to be
represented as a logical term whose syntax is very close to that of both
a Python dictionary and a JSON object. We call a term that maps to a
Python dictionary a *(Janus) dictionary term*. Such a term is simply a
Prolog term whose outer functor is `'{}'`/1, whose argument is a comma
list, where the elements of the comma list are attribute-value pairs
(sometimes called key-value pairs) using the predicate `:/2`, where the
attributes and values themselves may contain nested dictionaries, lists,
tuples or sets in accordance with the restrictions of Python
dictionaries.[^2]*
:::

::: {#jns-examp:glue .example}
**Example 1.2**. ***Calling a Python Function (II): Where to Maintain
Python Objects?** *

*A slightly more complex call to Python is to load a JSON object from a
file as opposed to a string. For this, we may use the Python function*

*`json.load(Stream)`*

*which loads a JSON string from a file into a Python dictionary which
can then be translated to Prolog. A small problem arises in that the
input to `json.load()` is a Python input stream (sometimes called a file
pointer `fp` is Python documentation). Python input streams are of
course different than Prolog input streams. This can be handled in
several ways.*

-   ***Maintain The Stream Reference in Python***

    *A straightforward solution to the problem is to write a small
    amount of glue code in Python as follows.*

        def prolog_load(File):
            with open(File) as fileptr:
                return(json.load(fileptr))

    *If this code were kept in the file `jns_json.py` the call*

        py_func(jns_json,prolog_load('sample.json'),Json)

    *would unify `Json` with a `janus` dictionary term as in the last
    example.*

-   ***Maintain The Stream Reference in Prolog** `janus` also allows the
    user to obtain any Python object reference in Prolog. The goal*

        py_func(builtins,open('sample.json',r),Stream),
        py_func(json,load(Stream),Json),
        py_dot(Stream,close(),Return).

    *makes three calls to Python: one to obtain the Python stream as a
    Python object reference, a second to parse the JSON object from the
    file and load it into Prolog, and a third to close the stream. Note
    that closing a stream requires a method to be applied to a stream
    object rather than a function call, so the `janus` predicate
    ` py_dot/[3,4]` is called instead of `py_func/[3,4]`.*

*Each of these approaches has advantages. Maintaining the stream
reference in Prolog requires no glue code, but does require explicitly
opening and closing the file. Either works well from the viewpoint of
performance: the `janus` interface is so fast that making one call vs.
three calls to Python make no measurable difference (see
Section [2.4](#sec:jns-perf){reference-type="ref"
reference="sec:jns-perf"}). of whether to maintain object references in
Python or Prolog is a matter of taste.*
:::

::: {#ex:jns-kewords .example}
**Example 1.3**. ***Calling a Python Function (III): Keyword Arguments**
*

*Python library functions often make heavy use of keyword arguments.
These are easily handled by `py_func/[3,4]` along with other `janus`
functions such as `py_dot/[3,4]` and `py_iter/[3,4]`. Suppose we want to
call the Python function*

*`json.dumps(Dict,indent=2)`*

*where `Dict` is a Python dictionary that is to be written out as a JSON
string. This can easily be called via*

*`py_func(json,dumps(PlgDict,indent=2),Ret)`*

*where `PlgDict` is a Prolog dictionary that is to be converted to the
Python dictionary `Dict`. Note that `py_func/[3,4]` handles keyword
arguments using the same syntax as Python: positional arguments must
occur first in a call followed by 0, 1 or more keyword arguments.*
:::

The `janus` predicate `py_dot/3` was briefly introduced in
Example [1.2](#jns-examp:glue){reference-type="ref"
reference="jns-examp:glue"}. Let's take a closer look at it.

::: {#jns-examp:method .example}
**Example 1.4**. ***Calling a Python Method** *

*Consider the following simple Python class:*

    class Person:
      def __init__(self, name, age, ice_cream=None):
        self.name = name
        self.age = age
        if favorite_ice_cream is None:
          favorite_ice_cream = 'chocolate'
        self.favorite_ice_cream = favorite_ice_cream

      def hello(self,mytype):
        return("Hello my name is " + self.name + " and I'm a " + mytype)

*The call*

        py_func('Person','Person'(john,35),Obj),

*creates a new instance of the `Person` class, and returns a reference
to this instance that can later be used to call a method. We refer to
this reference abstractly as $<obj>$ as the form of a Python object
reference can differ between Prologs that support `janus`. Using this
reference, the goal*

*`py_dot(`$<obj>$`,hello(programmer),Ret2).`*

*returns the Prolog atom:*

*`’Hello my name is john and I’m a programmer’`*

*Note that unlike `py_func/[3,4]` which requires a module as its first
argument, the module is not needed in `py_dot/[3,4]` as the module is
implicit in the object reference.*
:::

::: {#jns-examp:exam-object .example}
**Example 1.5**. ***Examining a Python Object** *

*Example [1.4](#jns-examp:method){reference-type="ref"
reference="jns-examp:method"} showed how to create a Python object, pass
it back to Prolog and apply a method to it. Suppose we create another
`Person` instance:*

        py_func('Person','Person'(bob,34),Obj),

*and later want to find out all attributes of `bob` both explicitly
assigned, and default. This is easily done by ` janus:obj_dict/2`:*

*`obj_dict(Obj ,ObjDict ).`*

*returns*

        ObjDict = {name:bob,age:34,favorite_ice_cream:chocolate}

*There are times when using the dictionary associated with a class is
either not possible or not appropriate. For instance, not all Python
classes have `__dict__` methods defined for them, or only a single
attribute of an object might be required. In these cases, ` py_dot/4`
can be used:*

*`py_dot(`$<obj>$`,favorite_ice_cream,I)`*

*returns `I = chocolate`.*

*Summarizing from the previous two examples, `py_dot/[3,4]` can be used
in two ways. If the second argument of a call to `py_dot/4` is a Prolog
structure, the structure is interpreted as a method. In this case, a
Python method is applied to the object, and its return is unified with
the last argument of `py_dot/4`. If the second argument is a Prolog
atom, it is interpreted as attribute of the object. In this case, the
attribute is accessed and returned to Prolog. Note that the
functionality of `py_dot/4` is overloaded in direct analogy to the
functionality of the `’.’` connector in Python.*
:::

::: {#jns-examp:lazy-ret .example}
**Example 1.6**. ***Eager and Lazy Returns** Prolog can either "lazily"
backtrack through solutions to a goal $G$ or "eagerly" return all
solutions to $G$ as a list via ` findall/3` or similar predicates. In an
analogous manner, Python can either 1) return a list or set of returns
via a mechanism such as comprehension; or 2) return solutions one at a
time through the `yield` statement or similar framework¡. `janus`
provides full flexibility in handling both lazy and eager returns.*

*Consider a file `range.py` that contains the following functions:*

      def demo_yield(): 
        for i in range(10):
            yield i

      def demo_comp():
        return [i for i in range(10)]

*To improve performance, many Python libraries, such as SpaCy and the
RDF-HDT interface to Wikidata, use `yield` to return generators rather
than returning lists or other data structures. ` demo_yield()` may be
considered a function with lazy returns. while ` demo_comp()` may be
considered a function with eager returns.*

*We first address the case of `demo_yield()`.*

***Eager return to Prolog of a eager Python function** This case
reflects the usual behavior of `janus` with most Python functions. An
example is*

*`py_func(range,demo_comp(),Ret).`*

*which unifies `Ret` with the list `[0,1,2,3,4,5,6,7,8,9]`. Such goals
can be extremely efficient in `janus` due to its high-speed translation
of Python data structures.*

***Eager return to Prolog of a lazy Python function** The goal*

*`py_func(range,demo_yield(),YieldObj).`*

*in fact returns the same ten element list as in the previous case that
used `demo_comp()`. The default behavior of `py_func/[3,4]` is that if a
function returns a Python object $O$ that is not of a type directly
handled by bi-translation, $O$ is checked to see whether it is a
generator or has an associated iterator $I_O$. If so the generator or
iterator traversed to return all answers eagerly to Prolog.*

***Lazy return to Prolog of an lazy Python function** If, rather than
using `py_func()` with its default behavior, the goal*

*`py_iter(range,demo_yield(),Return).`*

*is set, `Return` will be unified with the first list element,` 0`,
while the rest of its answers can be returned via backtracking.*

*An alternate approach is to call*

*`py_func(range,demo_yield(),Return,[py_object(true)]).`*

*In this case, `Return` will be unified with a Python object if the
Python function returns any non-base Python data type. Returning an
explicit object through which to iterate may be useful of the object is
needed in Prolog for other purposes. Otherwise it is better to use
`py_iter()` which does not create an explicit Python object reference
that should be freed.*

***Lazy return to Prolog of a eager Python function** If the goal*

*`py_iter(range,demo_comp(),Return).`*

*were called, `py_iter/3` would lazily backtrack through the list
returned by `demo_comp()`, rather than eagerly returning the list.
Similarly*

*`py_func(range,demo_comp(),Return,[py_object(true)]).`*

*will return a Python object reference as in the immediately previous
case.*
:::

::: {#jns-examp:pycall .example}
**Example 1.7**. ***py_call/\[2,3\]** *

*`py_call/[2,3]` provides an alternate syntax for ` py_dot/[3,4]` and
`py_func/[3,4]` (and vice-versa). Rather than calling*

*`py_func(Module,Function,Return)`*

*one may equivalently call*

*`py_call(Module:Function,Return)`*

*and rather than calling*

*`py_dot(Object,Function,Return)`*

*one may equivalently call*

*`py_call(Object:Function,Return)`*

*These equivalences also hold when options are provided for a call.*
:::

The syntax of `py_func/[3,4]` and `py_dot/[3,4]` is arguably slightly
more "Pythonic" than `py_call/[2,3]`. Python distinguishes between
calling a function and applying a method or obtaining an attribute and
this distinction is maintained when using `py_func/[3,4]` and
`py_dot/[3,4]`. On the other hand, ` py_call/[2,3]` is arguably slightly
more "Prologic", since it treats module qualification in the same manner
as with Prolog goals, and does not require the user to distinguish
between Python methods and functions. The following example shows how
`py_call/[3.4]` can write concise code.

::: example
**Example 1.8**. *Like many languages, Python allows simple functional
composition -- a simple case might be*

    >>> make_squares(make_list(4))

*which makes a list of the first four integers and then squares each
integer in the list producing*

    >>> [1,4,9,25]

*`py_call/2` supports a similar form of recursion, by clothing arguments
in `eval/1`, for instance:*

    ?- py_call(test_janus:squares(eval(test_janus:makelist(4))),Res).

*unifies `Res` with the expected result.*

*Compositions of method application to objects is similar. The goal*

    py_call(returnVal:returnVal({a:b,c:d}),Obj,[py_object(true)]).

*unifies `Obj` with a reference to the Python dictionary object for
`{a:b,c:d}`. Using this binding, the goal*

    py_call(Obj:'__class__':'__name__', Name),

*first finds the Python class for `Obj` and then unifies `Name` with its
string representation.*
:::

There is no deep difference between `py_call/[2,3]` and the mixture of
`py_func/[3,4]` and `py_dot/[3,4]`. They are merely alternate syntaxes.
In XSB, `py_call/[2,3]` is defined in terms of `py_func/[3,4]` and
`py_dot/[3,4]` and so ` py_func/[3,4]` and `py_dot/[3,4]` are slightly
faster; in SWI it is the reverse. Which form to use is a matter of
taste.

## Bi-translation between Prolog Terms and Python Data Structures {#sec:jns-bi-translation}

`janus` takes advantage of a C-level bi-translation of a large portion
of Prolog terms and Python data structures: i.e., Python lists, tuples,
dictionaries, sets and other data types are translated to their Prolog
term forms, and Prolog terms of restricted syntax are translated to
lists, tuples, dictionaries, sets and so on. Bi-translation is recursive
in that any of these data structures can be nested in any other data
structures (subject to limitations on the occurrence of mutables in
Python data structures).

Due to syntactic similarities between Prolog terms and Python data
structures, the Prolog term forms are easy to translate and use -- and
sometimes appear syntactically identical.

As terminology, when a Python data structure $D$ is translated into a
Prolog term $T$, $T$ is called a *(Janus) D term* e.g., a dictionary
term or a set term. he type representing any Python structure that can
be translated to Prolog is called *jns_struct* while *jns_term* is the
pseudo-type representing all Prolog terms that can be translated into a
Python data structure.

### The Bi-translation Specification {#sec-bi-translation}

Bi-translation between Prolog and Python can be described from the
viewpoint of Python types as follows:

-   *Numeric Types*: Python integers and floats are bi-translated to
    Prolog integers and floats. Python complex numbers are not (yet)
    translated, and in XSB translation is only supported for integers
    between XSB's minimum and maximum integer [^3]

    -   *Boolean Types* in Python are translated to the special Prolog
        structures `@(true)` and ` @(false)`.

-   *String Types*: Python string types are bi-translated to Prolog
    atoms. XSB's translation assumes UTF-8 encoding on both sides.

    Note that a Python string can be enclosed in either double quotes
    (`''`) or single quotes (`'`). In translating from Python to Prolog,
    the outer enclosure is ignored, so Python `"’Hello’"` is translated
    to the Prolog `’\’Hello\’’`, while the Python `’"Goodbye"’` is
    translated to the Prolog `’"Goodbye"’`.

-   *Sequence Types*:

    -   Python lists are bi-translated as Prolog lists and the two forms
        are syntactically identical. The maximum size of lists in both
        XSB and Python is limited only by the memory available.

    -   A Python tuple of arity `N` is bi-translated with a compound
        Prolog term `-/N` (i.e., the functor is a hyphen). The maximum
        size of tuples in XSB is $2^{16}$.

-   *Mapping Types*: The translation of Python dictionaries takes
    advantage of the syntax of braces, which is supported by any Prolog
    that supports DCGs. The term form of a dictionary is;

    `{ DictList} `

    where `DictList` is a comma list of `’:’/2` terms that use input
    notation.

    `Key:Value`

    `Key` and `Value` are the translations of any Python data structures
    that are both allowable as a dictionary key or value, and supported
    by `janus`. For instance, ` Value` can be (the term form of) a list,
    a set, a tuple or another dictionary as with

    `{’K1’:[1,2,3], ’k2’:(4,5,6)]}`

    which has a nearly identical term form as

    `{’K1’:[1,2,3], k2: -(4,5,6)]}`

-   *Set Types*: A Python set *S* is translated to the term form

    `py_set(SetList)`

    where *SetList* is the list containing exactly the translated
    elements of $S$. Due to Python's implementation of sets, there is no
    guarantee that the order of elements will be the same in $S$ and
    $SetList$.

-   *None Types.* The Python keyword `None` is translated to the Prolog
    term `@(none)`.

-   *Binary Types:* are not yet supported. There are no current plans to
    support this type in XSB.

-   Any Python object `Obj` of a type that is not translated to a Prolog
    term as indicated above, and that does not have an associated
    iterator is translated to the Python object reference, which can be
    passed back to Python for an object call or other purposes. In XSB,
    object references have the form `pyObj(Obj)`, but this form is
    system dependent, and will differ in other Prologs that support
    `janus` such as SWI.

## The Prolog-Python API

`py_func(+Module,+Function,?Return)`

:    \

`py_func(+Module,+Function,?Return,+Options)`

:    \
    Ensures that the Python module `Module` is loaded, and calls
    ` Module.Function` unifying the return of `Function` with ` Return`.
    As in Python, the arguments of `Function` may contain keywords but
    positional arguments must occur before keywords. For example the
    goal

        py_func(jns_rdflib,rdflib_write_file(Triples,'out.ttl',format=turtle),Ret).

    calls the Python function `jns_rdflib.rdflib_write_file()` to write
    `Triples`, a list of triples in Prolog format, to the file
    `new_sample.ttl` using the RDF `turtle` format.

    In general, `Module` must be the name of a Python module or path
    represented as a Prolog atom. Python built-in functions can be
    called using the "pseudo-module" `builtins`, for instance

    `py_func(builtins, float(’+1E6’),F).`

    produces the expected result:

    `F = 1000000.0`

    If `Module` has not already been loaded, it will be automatically
    loaded during the call. Python modules are searched for in the paths
    maintained in Python's `sys.path` list and these Python paths can be
    queried from Prolog via ` py_lib_dir/1` and modified via
    `py_add_lib_dir/1`.

    `Function` is the invocation of a Python function in `Module`, where
    `Function` is a compound Prolog structure in which arguments with
    the outer functor `=/2` are treated as Python keyword arguments.

    Currently supported options are:

    -   `py_object(true)` This option returns most Python data
        structures as object references, so that attributes of the data
        structures can be queried if needed. The only data returned
        *not* as an object reference are

        -   Objects of `boolean` type

        -   Objects of `none` type

        -   Objects of exactly the class `long`, `float` or ` string`.
            Objects that are proper subclasses of these types are
            returned as object references.

    **Error Cases**

    -   `py_func/4` is called with an uninstantiated option list

        -   `instantiation_error`

    -   The option list `py_func/4` contains an improper element, or
        combination of elements.

        -   `domain_error`

    -   `Module` is not a Prolog atom:

        -   `type_error`

    -   `Module` cannot be found in the current Python search paths:

        -   `existence_error`

    -   `Function` is not a callable term

        -   `type_error`

    -   `Function` does not correspond to a Python function in `Module`

        -   `existence_error`

    -   When translating an argument of function:

        -   A set (`py_set/1`) term has an argument that is not a list

            -   `type_error`

        -   The list in a set term (`py_set/1` contains a non-hashable
            term

            -   `type_error`

        -   A dictionary (`/1`) term has an argument that is not a
            comma-list

            -   `type_error`

        -   An element of a dictionary comma-list is not of the form
            ` :/2` or the structure contains a non-hashable key (first
            argument)

            -   `type_error`

        -   An argument of `Function` is otherwise non-translatable to
            Python

            -   `misc_error`

    In addition, errors thrown by Python are caught by XSB and re-thrown
    as `misc_error` errors.

`py_dot(+ObjRef,+MethAttr,?Ret,+Prolog_Opts)`

:    \

`py_dot(+ObjRef,+MethAttr,?Ret)`

:    \
    Applies a method to `ObjRef` or obtains an attribute value for
    `ObjRef`. As with `py_func/[3,4]`, `ObjRef` is a Python object
    reference in term form or a Python module. A Python object reference
    may be returned by various calls, such as initializing an instance
    of a class: [^4]

    -   If `MethAttr` is a Prolog compound term corresponding to a
        Python method for `ObjRef`, the method is called and its return
        unified with `Ret`.

    -   If `MethAttr` is a Prolog atom corresponding to the name of an
        attribute of `ObjRef`, the attribute value (for `ObjRef`) is
        accessed and unified with `Ret`.

    Both the Prolog options (`Prolog_Opts`) and the handling of Python
    paths is as with `py_func/[3,4]`.

    **Error Cases**

    -   `py_dot/4` is called with an uninstantiated option list

        -   `instantiation_error`

    -   The option list `py_dot/4` contains an improper element, or
        combination of elements.

        -   `domain_error`

    -   `Obj` is not a Prolog atom or Python object reference

        -   `type_error`

    -   `MethAttr` is not a callable term or atom.

        -   `type_error`

    -   `MethAttr` does not correspond to a Python method or attribute
        for `PyObj`

        -   `misc_error`

    -   If an error occurs when translating an argument of ` MethAttr`
        to Python the actions are as described for ` py_func/[3,4]`.

    In addition, errors thrown by Python are caught by XSB and re-thrown
    as `misc_error` errors.

`py_setAttr(+ModObj,+Attr,+Val)`

:    \
    If `ModObj` is a module or an object, this command is equivalent to
    the Python

    `ModObj.Attr = Val`.

    **Error Cases**

    -   `Obj` is not a Prolog atom or Python object reference

        -   `type_error`

    -   `MethAttr` is not an atom.

        -   `type_error`

    -   If an error occurs when translating an argument of ` MethAttr`
        to Python the actions are as described for ` py_func/[3,4]`.

`py_iter(+ModObj,+FuncMethAttr,Ret)`

:    \
    `py_iter/2` takes as input to its first argument either a module in
    which the function `FuncMethAttr` will be called; or a Python object
    reference to which either the method `FuncMethAttr` will be applied
    or the attribute `FuncMethAttr` will be accessed. Just as with
    `py_func/[3,4]` and `py_dot/[3,4]` the arguments of `FuncMethAttr`
    may contain keywords, but positional arguments must occur before
    keywords. However, if the Python function, method or attribute
    returns an iterator object `Obj`, the iterator for ` Obj` will be
    accessed and values of the iterator will be returned via
    backtracking (cf.
    Example [1.6](#jns-examp:lazy-ret){reference-type="ref"
    reference="jns-examp:lazy-ret"}).

    If the size of a return from Python is expected to be very large,
    say over 1MB or so the use of `py_iter()` is recommended.

    **Error Cases**

    Error cases are similar to `py_func/[3,4]` if `ModObj` is a module,
    and to `py_obj` if `ModObj` is a Python object reference.

`py_call(+Form,-Ret,+Opts)`

:    \

`py_call(+Form,Ret)`

:    \
    `py_call/[2,3]` is alternate syntax for `py_func/[3,4]` and
    `py_dot/[3,4]`. Or perhaps it is the other way around.

    `py_call(Mod:Func,Ret,Opts)`

    emulates `py_func(Mod,Func,Ret,Opts)`, while

    `py_call(Obj:Func,Ret,Opts)`

    emulates `py_dot(Obj,Func,Ret,Opts)`. Within ` py_call/[2,3]`
    function composition can be performed via the use of the `eval/1`
    term and via nested use of `:/2` as indicated in
    Example [1.7](#jns-examp:pycall){reference-type="ref"
    reference="jns-examp:pycall"}.

    Options and Error cases are the same as for `py_func/[3,4]` and
    `py_dot/[3,4]`.

`py_free(+ObjRef)`

:    \
    In general when `janus` bi-translates between Python objects and
    Prolog terms it performs a copy: this has the advantage that each
    system can perform its own memory management independently of the
    other. The exception is when a reference to a Python object is
    passed to XSB. In this case, Python must explicitly be told that the
    Python object can be reclaimed, and this is done through
    ` py_free/1`.

    **Error Cases**

    -   `ObjRef` is not a Python object reference. (Only a syntax check
        is performed, so no determination is made that `ObjRef` is a
        *valid* Python object reference

        -   `type_error`

`py_pp(+Stream,+Term,+Options)`

:    \

`py_pp(+Stream,+Term)`

:    \

`py_pp(Term)`

:    \
    Pretty prints a `janus` Python term. By default, the term is
    translated to Python and makes use of Python's `pprint.pformat()`,
    which produces a string that is then returned to Prolog and written
    out. If the option `prolog_pp(true)` is given, the term is pretty
    printed directly in Prolog. As an example

        pydict([''(name,'Bob'),''(languages,['English','French','GERMAN'])]).

    is pretty-printed as

        {
          name:'Bob',
          languages:[
           'English','
           'French',
           'GERMAN'
          ]
        } 

    Such pretty printing can be useful for developing applications such
    as with `jns_elastic`, the `janus` Elasticsearch interface which
    communicates with Elasticsearch via (sometimes large) JSON terms.

`py_add_lib_dir(+Path,+FirstLast)`

:    \

`py_add_lib_dir(+Path)`

:    \
    The convenience and compatibility predicate `py_add_lib_dir/2`
    allows the user to add a path to the end of `sys.path` (if
    ` FirstLast = last` or the beginning (if `FirstLast = fiast`.
    `py_add_lib_dir/1` acts as `py_add_lib_dir/2` where
    ` FirstLast = last`.

    When adding to the end `sys.path` this predicate acts similarly to
    XSB's `add_lib_dir/1`, which adds Prolog library directories.

`py_lib_dirs(?Path)`

:    \
    This convenience and compatibility predicate returns the current
    Python library directories as a Prolog list.

`values(+Dict,+Path,?Val)`

:    \
    Convenience predicate and compatibility to obtain a value from a
    (possibly nested) Prolog dictionary. The goal

    `values(D,key1,V)`

    is equivalent to the Python expression `D[key1]` while

    `values(D,[key1,key2,key3],V)` v is equivalent to the Python
    expression

    `D[key1][key2][key3]`

    There are no error conditions associated with this predicate.

`py_is_object(+Obj)`

:    \
    Succeeds if `Obj` is a Python object reference and fails otherwise.
    Different Prologs that implement Janus will have different
    representations of Python objects, so this predicate should be used
    to determine whether a term is a Python Object.

`keys(+Dict,?Keys)`

:    \

`key(+Dict,?Keys)`

:    \

`items(+Dict,?Items)`

:    \
    Convenience predicates (for the inveterate Python programmer) to
    obtain a list of keys or items from a Prolog dictionary. There are
    no error conditions associated with these predicates.

    The predicate `key/2` returns each key of a dictionary on
    backtracking, rather than returning all keys as one list, as in
    `keys/2`.

`obj_dict(+ObjRef,-Dict)`

:    \
    Given a reference to a Python object as `ObjRef`, this predicate
    returns the dictionary of attributes of `ObjRef` in `Dict`. If no
    `__dict__` attribute is associated with `ObjRef` the predicate
    fails.

    `obj_dict/2` is a convenience predicate, and could be written using
    `py_dot/3` as:

          py_dot(Obj,'__dict__',Dict).

`obj_dir(+ObjRef,-Dir)`

:    \
    Given a reference to a Python object as `ObjRef`, this predicate
    returns the list of attributes of `ObjRef` in `Dir`. If no `__dir__`
    attribute is associated with `ObjRef` the predicate fails.

    `obj_dir/2` is a convenience predicate, and could be written using
    `py_dot/3` as:

          py_dot(Obj,'__dir__'(),Dir).

## Performance and Space Management {#sec:jns-perf}

Needs to be rewritten

## Interfaces to Python Libraries

The `packages/janus/starters` directory contains code to interface to
various Python libraries---to help users start projects using `janus`.
Some of the files implement useful higher level mappings that translate
say, embedding spaces or SpaCy graphs to Prolog graphs, or translate RDF
graphs to lists of Prolog structures. Others are simple collections of
examples to show how to query or update Elasticsearch, to detect the
language of input text or to perform machine translation. Nearly all of
the interfaces have been a starting point for research or commercial
applications.[^5]

When `janus` is loaded, both the `janus` directory and its
`packages/janus/starters` sub-directory is added to the Prolog and
Python paths. As a result, modules in these sub-directories can be
loaded into XSB and Python without changing their library paths.

Note that most of these applications require the underlying Python
libraries to have been installed via a `pip` or `conda` install.

### Fasttext Queries and Language Detection: `jns_fasttext`

Facebook's `fastText` provides a collection of functionality that
includes querying pre-trained word vectors in over a hundred
languages [@FBFJM18], training sets of vectors, aligning vector
embeddings [@MUSE2018], and identifying languages via ` lid.176.bin`.
This XSB module uses the Python module `fasttext` and allows an XSB
programmer to immediately start using fastText's pre-trained word
embeddings. A related module, `jns_faiss` provides an interface to
Facebook's dense vector management system Faiss. The distinction between
the two is that Faiss can manage vectors read in from a file, and
provides batch-oriented operations; the fastText module relies on
fastText's binary format and provides simpler, though useful, query
support.

##### Queries to Word Embeddings

`load_model(+BinPath,+Name)`

:    \
    Loads a word embedding model in fastText binary form, the path of
    which is `BinPath`. `Name` is an atom to be used as a Prolog
    referent. By associating different names with different models it is
    easy to make use of more than one word embedding model at a time.

`get_nearest_neighbors(+Name,+Word,-Neighbors)`

:    \
    Returns the 10 nearest neighbors of `Word` in the model ` Name`.
    This feature is useful for determining other words that are
    distributionally similar to `Word`. `Neighbors` is a list of tuples
    (terms with functor `-/2`) containing a neighboring word and its
    cosine similarity to `Word`. Although `Word` must be a Prolog atom,
    it need not be an actual English word. Because fastText uses subword
    embeddings rather than word embeddings [@BGJM17], `Word` need not
    have been in the training set of the model. This feature can
    sometimes be useful for correcting misspellings and other purposes.

`cosine_similarity(+Name,+WordList,-SimMat)`

:    \
    For a model `Name` and `WordList` a list of atoms of length $N$,
    this predicate returns a (cosine) similarity matrix of dimension
    $N \times N$.

`get_word_vec(+Name,+Word,-Vec)`

:    \
    Returns a the vector for `Word` in the model `Name` as a Prolog list
    of floats. In general, if a computation on word vectors can be done
    wholly on the Python side, it is much faster to do so, rather than
    manipulating vectors in XSB. This is because the word vectors are
    actually kept as `numpy` arrays and computations performed in C
    rather than in Python (or Prolog).

##### Language Identification via `lid.176.bin`

Assuming that Fasttext's language identification module is in the
current directory, the command:

     py_func(fasttext,load_model('./lid.176.bin'),Obj).

Loads the model and unifies `Obj` with a reference to the loaded module
which might look like `pyObj(p0x7faca3428510)`. Next, a call to the
example Python module `jns_fasttext`:

    py_func(jns_fasttext, fasttext_predict(pyObj(p0x7faca3428510),
           'janus is a really useful addition to XSB! But language detection
            requires a longer string than I usually want to type.'),Lang).  

returns the detected language and confidence value, which in this case

    -('__label__en',0.93856)

Note that loading the model can be done by calling the Python
` fasttext` module directly. In fact, the only reason that the module
`jns_fasttext` needs to be used (as opposed to calling the Python
functionality directly) is because the confidence of the language
detection is returned as a `numpy` array, which `janus` does not
currently translate automatically.[^6]

### Dense Vector Queries with jns_faiss

The dense-vector query engine Faiss [@JDH17], developed by Facebook
offers an efficient way to perform nearest neighbor searches in vector
spaces produced by word, network, tuple, or other embeddings. The
`jns_faiss` example provides XSB predicates to initialize a Faiss index
from a text file of vectors, perform queries to the index, and to make a
weighted Prolog graph out of the vector space.

As with many machine-learning tools, Faiss expects that each of the
vectors is referenced by an integer. For instance, a vector for the
string *cheugy* would be referenced by an integer, say 37. The XSB
programmer thus would be responsible for associating the string *cheugy*
with 37 in order to use Faiss. The main predicates exported by
`jns_faiss.P` include:

-   `faissInit(+XbFile,+Dim)` initializes a Faiss index where `XbFile`
    is a text file containing the vectors to be indexed and `Dim` is the
    dimension of these vectors. (`xb` is Faiss terminology for the set
    of *base*, i.e., indexed, vectors.) This predicate also creates a
    `numpy` array with a set of query vectors `xq` consisting of the
    same vectors. When the query and index vectors are set up in this
    manner, a nearest-neighbor search can be performed for any of the
    indexed vectors. With this, the vector space can be explored,
    visualized, and so on.

    After execution of this predicate, a fact for the predicate
    ` jns_faiss:xq_num/1` contains the number of query vectors (` xq`),
    which is the same as the number of indexed vectors (` xb`).

-   `get_k_nn(+Node,+K,-Neighbors)` finds the `K` nearest neighbors of a
    node. The predicate takes as input `Node`, the integer identifier of
    a node, and `K` the number of nearest neighbors to be returned. The
    return structure `Neighbors` is the Prolog representation of a 2-ary
    Python tuple (i.e., `-/2`) containing as its first argument a list
    of `K` distances and as it second argument a list of `K` neighbors.

-   `make_vector_graph(K)` Given a Faiss index, this predicate asserts a
    weighted graph in Prolog by obtaining the nearest `K` neighbors for
    each indexed vector. Edges of the graph have the form:

    `vector_edge_raw(From,To,Dist)`

    Where `From` and `To` are integer referents for indexed vectors, and
    `Dist` is the Euclidean distance between the vector with referent
    `From` and the vector with referent `To`. Each fact of
    `vector_edge_raw/3` is indexed both on its first and second
    argument.

    If both the number of indexed vectors and `K` are large,
    construction of the Prolog vector graph may take a few minutes.
    Construction time is almost wholly comprised of the time within
    Faiss to find the set of `K` nearest neighbors for each node.

-   `vector_edge(Node1,Node2,Dist)`. The vector graph, which represents
    distances is undirected. However to save space, the
    ` vector_edge_raw/3` facts are asserted so that if
    ` vector_edge_raw(Node1,Node2,Dist`) has been asserted,
    ` vector_edge_raw(Node2,Node1,Dist`) will not be asserted.
    ` vector_edge/3` calls `vector_edge_raw/3` in both directions, and
    should be used for querying the vector graph.

-   `write_vector_graph(+File,+Header)` writes out the vector graph to
    `File`. This predicate ensures that `File` contains the proper
    indexing directive for `vector_edge_raw/3` as well a directive to
    the compiler describing how to dynamically load `File` in an
    efficient manner. Because of these directives, the file can simply
    be consulted or ensure_loaded and the user does not need to worry
    about which compiler options should be used. The graph is loaded
    into the module `vector_graph`.

    `Header` is simply a string that is written as a comment to the
    first line of `File` that can serve to contain any necessary
    provenance information.

### Translating Between RDF and Prolog: jns_rdflib {#sec:jns-rdflib}

This module interfaces to the Python `rdflib` library to read RDF
information from files in Turtle, jsonld, N-triples and N-quads format,
and to write files in Turtle, jsonld, and N-triples format. In addition,
RDF HDT files can be loaded and queried using ` rdflib-HDT`. As such
`jns_rdflib` augments XSB's RDF package
(Chapter [\[chapter:RDF\]](#chapter:RDF){reference-type="ref"
reference="chapter:RDF"}) which handles XML-RDF.

Within a triple, URIs and blank nodes are returned as Prolog atoms,
while literals are returned as terms with functor `-/3` (the Prolog
representation of a 3-ary tuple) in which the first argument is the
literal's string as a Prolog atom, the second argument is its datatype,
and the third argument its language. If the data type or language are
not included, the argument will be null. As examples:

    "That Seventies Show"^^<http://www.w3.org/2001/XMLSchema#string> 

is returned as

    -('"That Seventies Show"','<http://www.w3.org/2001/XMLSchema#string>',) 

while

    "That Seventies Show"@en

is returned as

    -('"That Seventies Show"',,en) 

The file `jns_rdflib.P` contains predicates `test_nt/0`, `test_ttl/0`,
`test_nq/0` to test reading and writing. Note that Python options needed
to deserialize an `rdfllb` graph write are specific to the `rdflib`
plug-in for a particular format, and these plug-ins are not always
consistent with one another. As a result, if other formats are desired,
minor modifications of `jns_rdflib` may be necessary, though they will
often be simple to make.

The use of `jns_rdflib` differs on the RDF format used. For the `turtle`
(or `ttl`), `nt` (or `ntriples`), ` jsonld`, and `nquads` formats a file
is read into XSB as a (large) list, and an XSB list of terms of the
proper form can be transformed into RDF and written to a file. For the
` HDT` format the usage pattern is different: when an `HDT` file is
loaded, it is simply memory mapped into a process and facts are loaded
into a `rdflib` graph (and into XSB) purely on demand [^7].

#### Functionality for Turtle, jsonld. N-triples and N-quads Formats

##### Reading RDF

-   `read_rdf(+File,+Format,-TripleList)` reads RDF from a file
    containing an RDF graph formatted as `Format`, where the formats
    `turtle`, `nt`, `jsonld` and `nquads` have been tested.[^8]. These
    formats can be tested on `sample.ttl`, `sample.nt` and `sample.nq`,
    all of which are in the `packages/janus/starters` directory.

    Due to the structure of the Python `rdflib` graph, no guarantee is
    made that the order of facts in `File` will match the order of facts
    in `TripleList`.

**Error Cases**

-   `Format` is not `nt`, `turtle`, `ttl`, or ` nquads`

    -   `misc_error`

##### Writing RDF

If `TripleList` is a list of terms, structured as `-/3` terms described
above, it can be easily be written to `File` as properly formatted RDF.
The Python function ` rdflib_write_file_no_decode()` can be called
directly as:

    py_func(jns_rdflib,rdflib_write_file_no_decode(+TripleList,+File,format=+Fmt),-Ret).

where `Fmt` is `turtle` or `nq`. ` rdflib_write_file_no_decode()` is a
simple function that creates an RDFlib graph out of `TripleList`,
serializes the graph and prints it out. The Python options needed to
write to a file are specific to the RDFlib plug-in for a particular
format, so if other formats are desired, minor modifications of
`jns_rdflib` may be necessary.

Due to the structure of the Python `rdflib` graph, no guarantee is made
that the order of facts in `File` will match the order of facts in
`TripleList`.

#### Functionality for the HDT Format

The RDF HDT format is intended to support large, read-only knowledge
bases, such as Wikidata, that may contain billions of triples. A HDT
file is a compressed binary serialization that can be directly browsed
and queried. The advantage of querying over compressed data is that
large data stores become manageable that otherwise wouldn't be. For
instance, a Wikidata snapshot that contains several billion rows along
with indexes takes up about 160 Gbytes on disk and takes about 3 seconds
to initialize into (`jns_``)rdflib`. Furthermore, the data is loaded
into RAM only as needed for query evaluation.

`jns_rdflib` offers two main predicates for use with `rdflib` HDT:

`hdt_load(+Store,-Obj)`

:    \
    Initializes `rdflib` for the HDT file `Store` and creates a `rdflib`
    graph in which to store the results of queries. ` Obj` is the Python
    reference to the data store.

`hdt_query(?Arg1,?Arg2,?Arg3,-List)`

:    \
    Allows a user to query a HDT store using Prolog-like syntax and
    returns the results of the query in `List`. For instance the query

            hdt_query('http://www.wikidata.org/entity/Q144',Pred,Obj,List)

    finds all triples having the above URI as their subject. In this
    case, `List` would be unified with a long list beginning with

    ::: footnotesize
        [('http://www.wikidata.org/entity/Q144','http://schema.org/name',-(dog,'',en))
         ('http://www.wikidata.org/entity/Q144','http://schema.org/description',-('domestic animal,'',en))
        ...
    :::

### jns_spacy

SpaCy is widely used tool that exploits neural language models to
analyze text via dependency parses, named entity recognition, and much
else. Although SpaCy is a Python tool, much of it is written in C/Cython
which makes it highly efficient. The `jns_spacy` package offers a
flexible and efficient means to use SpaCy from Prolog (once SpaCy has
been properly installed for Python, along with appropriate SpaCy
language models).

In SpaCy, a user first loads one or more language models for the
language(s) of interest and of a size suitable to the application. Text
is then run through this language model and through other SpaCy code
producing a `Document` object containing a great amount of detail about
the sentences in the text, tokens in the sentence and their relations to
one another.

Reflecting this sequence, the predicate `load_model/1` is used to load a
SpaCy model into the XSB/Python session:

    load_model(en_core_web_sm) 

On the Python side the identifier `en_core_web_sm` is associated with a
`Language` object, and using this association the same atom can be used
to process text throughout the session. Multiple models can be loaded
and used to process different text or files in different languages or
for different purposes. For instance, the `jns_spacy` query:

    proc_string(en_core_web_sm,'She was the youngest of the two daughters of a
    most affectionate, indulgent father; and had, in consequence of her sister's
    marriage, been mistress of his house from a very early period.',Doc)

processes the above text, unifying `Doc` with the referent to the
resulting SpaCy `Document` object, which contains the textual analysis
of the string. The predicate `proc_file/3` works similarly for textual
files.

At this point, a user of `jns_spacy` has two options: she can either
query the `Document` object directly or call ` token_assert/1` to assert
information from the `Document` object into a Prolog graph that can be
conveniently analyzed.

For many purposes however, it may be easier to call the XSB predicate
` token_assert(Doc)` that asserts tokens and their dependency parse
edges into XSB as explained below. As an example of how to navigate this
graph, `show_all_trees/0` and its supporting predicates provide a simple
but clear representation of the SpaCy dependency parse in constituency
tree form using the Prolog version of the parse.
Example [1.9](#spacy-examp){reference-type="ref"
reference="spacy-examp"} below shows a similar sequence as it might be
executed in a simple session.

As a final point before presenting the the main predicates, note that if
text from different languages is to be analyzed, the package
` jns_fasttext` can be used to determine the language of a text string,
and the text can then be sent to one of several language models.

##### `jns_spacy` Predicates

`load_model(+Model,+Options)`

:    \

`load_model(+Model)`

:    \
    Loads the SpaCy model `Model` and associates the Prolog atom
    ` Model` with the corresponding SpaCy `Language` object. Currently,
    the only form for `Options` is a (possibly empty) list of terms of
    the form `pipe(Pipe)` where `Pipe` is the name of a SpaCy pipe,
    i.e., a process to add to the NLP pipeline of the SpaCy Language
    object `Model`.

    `load_model(Model)` is a convenience predicate for
    ` load_model(Model,[])`.

`proc_string(+Model,+Atom,-Doc,+Options)`

:    \

`proc_string(+Model,+Atom,-Doc)`

:    \
    Processes the text `Atom` using the model `Model` and unifying `Doc`
    with the resulting SpaCy `Document` object. The only option
    currently allowed in `Options` is ` token_assert`, which in addition
    asserts information from `Doc` into a Prolog graph (after removing
    information about any previous dependency graphs).

    `proc_string(+Model,+File,-Doc)` is a convenience predicate for\
    `proc_string(+Model,+Atom,-Doc,[])`.

    If `Model` has not been loaded, `proc_string/[3,4]` will try to load
    it before processing. If `Model` cannot be found, a Python
    `NameError` error is thrown as an XSB miscellaneous error.

`proc_file(+Model,+File,-Doc,+Options)`

:    \

`proc_file(+Model,+File,-Doc)`

:    \
    Opens `File` and processes its contents using the model ` Model` and
    unifying `Doc` with the resulting SpaCy ` Document` object. `File`
    is opened in Python, and the stream for `File` is closed
    automatically. The only option currently allowed in `Options` is
    `token_assert`, which in addition asserts information from `Doc`
    into a Prolog graph.

    `proc_file(+Model,+File,-Doc)` is a convenience predicate for\
    `proc_file(+Model,+File,-Doc,[])`.

    If `Model` has not been loaded, `proc_file/[3,4]` will try to load
    it before processing. If `Model` cannot be found, a Python
    `NameError` error is thrown as an XSB miscellaneous error.

`token_assert(+Doc)`

:    \
    This predicate accesses the SpaCy Document object `Doc`, then
    queries the dependency graph and other information from `Doc`, and
    asserts it to Prolog as a graph (after retracting information from
    any previous dependency graphs). The Prolog form of the graph uses
    two predicates. The first:

            token_info_raw(Index,Text,Lemma,Pos,Tag,Dep,EntType)

    represents the nodes of the graph; For a given SpaCy `token` object
    the fields in the corresponding `token_info_raw/7` fact are: are as
    follows:

    -   `Index` (`token.idx`) is the character offset of ` token` within
        the document (i.e., the input file or atom), and serves as an
        index for the token both in SpaCy and in its Prolog
        representation.

    -   `Text` (`token.text`) the verbatim form of `token` in the text
        that was processed.

    -   `Lemma` (`token.lemma_`) the base form of ` token`. If `token`
        is a verb, `Lemma` is its stem, if `token` is a noun, `Lemma` is
        its singular form.

    -   `Pos` (`token.pos_ `) is the coarse-grained part of speech for
        `token` according to
        ` https://universaldependencies.org/docs/u/pos`

    -   `Tag` (`token.tag_ `) The fine-grained part of speech for
        `token` that contains some morphological analysis in addition to
        the part-of-speech. Cf.

        `https://stackoverflow.com/questions/37611061/spacy-token-tag-full-list`

        for a discussion of its meaning and use.

    -   `Dep` (`token.dep_ `) The type of relation that ` token` has
        with its parent in the dependency graph.

    -   `EntType` (`token.ent_type_ `) The SpaCy named entity type,
        e.g., person, organization, etc.

    Edges of the Prolog graph have the form:

        token_childOf(ChildIndex,ParentIndex)

    where `ChildIndex`, and `ParentIndex` are indexes for
    ` token_info_raw/7` facts.

    Note that SpaCy tokens have many other attributes, of which the
    above are some of the more useful. If other attributes are needed,
    the ` jns_spacy` code can easily be expanded to include them.
    However many aspects of the parse can be easily reconstructed by the
    Prolog graph and don't need to be materialized in Prolog. For
    instance the code for `show_all_trees/0` in `jns_spacy.P` contains
    code for constructing sentences, subtrees of a given token and so
    on.

`get_text(Index,Text)`

:    \

`get_lemma(Index,Lemma)`

:    \

`get_pos(Index,Pos)`

:    \

`get_tag(Index,Tag)`

:    \

`get_dep(Index,Dep)`

:    \

`get_ner_type(Index,NER)`

:    \

`token_info(Index,Text,Lemma,Pos,Tag,Dep,Ent_type)`

:    \
    Various convenience predicates for accessing `token_info_raw/7`.
    `token_info/7` is a convenience predicate that calls
    ` token_info_raw/7` and filters out spaces and punctuation.
    ` get_text/2`, `get_lemma/2` etc. get the appropriate field from a
    `token_info_raw/7` fact indexed by `Index`.

`show_all_trees()`

:    \
    Given a SpaCy graph asserted to Prolog as described above,
    ` show_all_trees/0` navigates the graph, and for each sentence in
    the graph converts the dependency graph to a tree and prints it out.
    This predicate is useful for reviewing parses, and its code in
    ` jns_spacy.P` can be modified and repurposed for other needed
    functionality.

`sentence_roots(-RootList)`

:    \
    Returns a list of the dependency graph nodes (i.e.,
    ` token_info_raw/7` terms) that are roots of a sentence in the
    Prolog dependency graph. By backtracking through `RootList`,
    sentence by sentence processing can be done for a document.

`dependent_tokens(+Root,-Toklist)`

:    \
    Given the index of token `Root`, returns a sorted list of the tokens
    dependent on `Root`. If `Root` is the root of a sentence, `Toklist`
    will be the words in the sentence; if ` Root` is the root of a noun
    phrase, `Toklist` will be the words in the noun phrase, etc.

::: {#spacy-examp .example}
**Example 1.9**. *We provide an example session where `jns_spacy` is
used. For a session like this to work SpaCy would need to be installed
along with the SpaCy model `en_core_web_sm`. The session would start by
consulting the appropriate files and model:*

    | ?- [janus,jns_spacy].
    :
    | ?- load_model(en_core_web_sm).

*Next SpaCy is used to process a string (i.e., a Prolog atom):*

    | ?- proc_string(en_core_web_sm,'She was the youngest of the two daughters of a most affectionate,indulgent father; and had, in consequence of her sister''''s marriage,been mistress of his house from a very early period.  ',Doc,[token_assert]).

    Doc = pyObj(p0x7f36ed5b3580)

    yes

*The option `token_assert` automatically loads the SpaCy dependency
graph and other information to Prolog. Alternately, one could omit this
option and later call ` token_assert(pyObj(p0x7f36ed5b3580))`: i.e.,
call ` token_assert/1` with the first argument as the reference to the
SpaCy document object in Python. Either way, once the dependency graph
has been loaded into XSB the command:*

    show_all_trees().

*will print out the list of tokens for this sentence followed by:*

    token_info(245,was,be,AUX,VBD,ROOT,)
       token_info(241,She,she,PRON,PRP,nsubj,)
       token_info(253,youngest,young,ADJ,JJS,attr,)
          token_info(249,the,the,DET,DT,det,)
          token_info(262,of,of,ADP,IN,prep,)
             token_info(273,daughters,daughter,NOUN,NNS,pobj,)
                token_info(265,the,the,DET,DT,det,)
                token_info(269,two,two,NUM,CD,nummod,CARDINAL)
                token_info(283,of,of,ADP,IN,prep,)
                   token_info(317,father,father,NOUN,NN,pobj,)
                      token_info(286,a,a,DET,DT,det,)
                      token_info(293,affectionate,affectionate,ADJ,JJ,amod,)
                         token_info(288,most,most,ADV,RBS,advmod,)
                      token_info(307,indulgent,indulgent,ADJ,JJ,amod,)
       token_info(325,and,and,CCONJ,CC,cc,)
       token_info(375,been,be,VERB,VBN,conj,)
          token_info(329,had,have,AUX,VBD,aux,)
             token_info(334,in,in,ADP,IN,prep,)
                token_info(337,consequence,consequence,NOUN,NN,pobj,)
                   token_info(349,of,of,ADP,IN,prep,)
                      token_info(365,marriage,marriage,NOUN,NN,pobj,)
                         token_info(356,sister,sister,NOUN,NN,poss,)
                            token_info(352,her,her,PRON,PRP$,poss,)
                            token_info(362,'s,'s,PART,POS,case,)
          token_info(380,mistress,mistress,NOUN,NN,attr,)
             token_info(389,of,of,ADP,IN,prep,)
                token_info(396,house,house,NOUN,NN,pobj,)
                   token_info(392,his,his,PRON,PRP$,poss,)
          token_info(402,from,from,ADP,IN,prep,)
             token_info(420,period,period,NOUN,NN,pobj,)
                token_info(407,a,a,DET,DT,det,)
                token_info(414,early,early,ADJ,JJ,amod,)
                   token_info(409,very,very,ADV,RB,advmod,)

*A similar sequence, but with
` proc_file(en_core_web_sm,’emma.txt’,Doc,[token_assert])` parses the
sentences in `emma.txt` and loads the results into XSB. In this case the
command `show_all_trees()` displays the dependency graph for each
sentence in tree form.*
:::

### jns_json

This module contains an interface to the Python `json` module, with
predicates to read JSON from and write JSON to files and strings. The
`json` module transforms JSON objects into and from Python dictionaries,
which the interface maps to and from their term forms. This module can
be used to help understand how Python dictionaries relate to XSB terms,
or as an alternative to XSB's `json` package (`json`
Chapter [\[chap:json\]](#chap:json){reference-type="ref"
reference="chap:json"}). For instance, while for most purposes XSB's
`json` package should be used, `jns_json` can be useful if the json
constructed and read comes from another `janus` application such as
`jns_elastic`. This is because the format used by `jns_json` maps
directly to a Python dictionary, while that of the `json` package maps
to other (very useful) formats.

The `jns_json` functions are written in Python and can be called
directly from Prolog.

-   `py_func(jns_json,prolog_load(+File),+Features,-Json)` opens and
    reads `File` and returns its JSON content in ` Json` as a Prolog
    dictionary term.

-   `py_func(jns_json,prolog_dump(+Dict,+File),+Features,-Ret)` converts
    `Dict` to a JSON object, write it to `File` and returns the result
    of the operation in `Ret`.

-   `py_func(jns_json,prolog_loads(+Atom),+Features,-Json)` reads the
    atom `Atom` and returns its JSON content in `Json` as a Prolog
    dictionary term.

-   `py_func(jns_json,prolog_dumps(+Dict),+Features,-JsonAtom)` converts
    `Dict` to a JSON string, and returns the string as the Prolog atom
    `JsonAtom`.

### Querying Wikidata from XSB

Wikidata is a multi-language ontology-style knowledge graph created from
processing Wikipedia articles and from many other sources. The Wikidata
graph contains a huge amount of information with 14-15 billion edges,
This information consists of *Qnodes* which include people, places,
things and their classes. Among the more important Qnodes are of course,
XSB (`Q8042469`) and Prolog (`Q163468`). Qnodes are related to each
other using *Pnodes*: among the more important indicate that one node is
a subclass of another (`P279`) or an instance of another (`P31`). Both
Pnodes and Qnodes have various attributes such as their preferred label
(`http://www.w3.org/2004/02/skos/core#prefLabel`).

Due to the amount of information it contains, Wikidata is widely used in
knowledge intensive applications such as NLP, entity resolution, and
content extraction along with many others. However, Wikidata can be
difficult to use due to its size and its design.

In terms of its size, while Wikidata can be downloaded and stored in a
database, this can be time and resource intensive. Alternately, various
Wikidata servers can be queried via REST interfaces, although the public
servers limit the number of queries made from a given caller over a time
period, making them useful only for a light query load. Easily usable
snapshots of a Wikidata at a given time are also available in RDF-HDT
format (cf. Section [1.5.3](#sec:jns-rdflib){reference-type="ref"
reference="sec:jns-rdflib"}).[^9] In using XSB with Wikidata, one
project found it worked well to query RDF-HDT first, with REST queries
as a backup.

The design of Wikidata also makes it difficult to use. Information
useful to one project may simply be noise to another. In addition some
Wikidata statements are reified, and others are not. And finally, the
need to use identifiers such as `P31` means that aliases must be used
for code readability.

XSB's Wikidata interfaces help address many of these issues. The HDT
interface `jns_wd` and the server interface `jns_wdi` were both
developed during a project that heavily used both XSB and Wikidata.
While these interfaces worked well for our project, they make no claim
to tame all of Wikidata's difficulties, just the ones we repeatedly ran
into.

#### `jns_wd`: Querying Wikidata via HDT

`wd_query(?Arg1,?Arg2,?Arg3,?Lang)`

:    \
    This predicate queries the HDT version of Wikidata and unifies the
    various arguments with Wikidata triples that match the input, so
    that the caller may backtrack through all results. `Arg1` and `Arg3`
    can either be concise Qnode identifiers (e.g., ` Q144`: *dog*) or
    URLs that may or may not represent Qnodes.[^10] Similarly, `Arg2`
    may be a concise Pnode identifier (e.g., `P31`) or a full URL.
    `Lang` is a 2 character language designation, which serves as a
    filter if instantiated. `Arg3` can also be a string like `Italy`
    which `jns_wd` turns into rdf form using Lang, e.g., `Italy@en`.
    This predicate is the basis of many other predicates in this module.

    In order to take advantage of HDT indexes, at least one of `Arg1`
    and `Arg3` should be instantiated; otherwise the query can take a
    long time.

    Finally, there are many properties indicating provinance and other
    meta-data that are not needed for many purposes. The file
    ` jns_wd_ignore.P` defines the predicate `ignore_1/1` that contains
    a number of Pnodes (`Arg2` instantiations) that one project
    preferred to filter out of the `wd_query/4` answers. Filtering is
    off by default, and can be turned on by asserting
    ` jns_wd:use_wd_filter`. Of course, since filtering may be
    application-specific, Pnodes can be added to or deleted from
    ` jns_wd_ignore.P` as desired.

`wd_get_labels(+Qnode,-Label,?Lang)`

:    \
    Backtracks through all preferred labels
    (`http://www.w3.org/2004/02/skos/core#prefLabel`), and other labels
    (`http://www.w3.org/2004/02/skos/core#prefLabel` and\
    `http://www.w3.org/2000/01/rdf-schema#label`) whose language unifies
    with `Lang`.

`wd_get_label(+Qnode,-Label,?Lang)`

:    \
    Tries to find a good label for `Qnode` that unifies with ` Lang`,
    first trying for a preferred label, then
    `http://www.w3.org/2004/02/skos/core#prefLabel`, and finally other
    labels (`http://www.w3.org/2004/02/skos/core#prefLabel` and\
    `http://www.w3.org/2000/01/rdf-szvchema#label`.

`wd_instance_of(+SCNode,-CNode)`

:    \

`wd_subclass_of(+InstNode,-CNode)`

:    \

`wd_parent_of(+Node,-Parent)`

:    \
    Because it is called with the first argument bound,
    ` wd_subclass_of/2` and `wd_instance_of/2` both go up the Wikidata
    ontology dag and should not have any problems with speed, since
    upward traversals are supported by the HDT indexes. These predicate
    attempt to handle the case where the obtained class is a reified
    statement. In this case, it attempts another call from the reified
    statement to try to get a Qnode, a strategy that works at least
    *sometimes*.[^11]

    In Wikidata, it is not always apparent whether a node has an
    instance or a subclass relation with its parent, so `wd_parent_of/3`
    is a convenience predicate that calls both.

#### `jns_wdi`: Querying Wikidata over the web

This package provides a simple interface to the Wikidata website via the
Python library `wikidataintegrator`. It is one of two ways in which
`janus` can be used to query Wikidata: the other is to query a
compressed local snapshot of Wikidata via the `hdt` functionality in
`jns_rdflib`. Each approach has advantages and disadvantages. The use of
`hdt` can be much faster: in part because it requires no webservice
calls, but also because the Wikidata site slows down responses to
requests from a session that is using the site heavily. On the other
hand, to use `hdt` the a Wikidata ` hdt` file must be locally mounted;
and when a process loads the hdt file, it must allocate a large amount
of virtual memory, although this memory does not usually affect RAM
usage.[^12] So for applications that take place on servers or that use
Wikidata extensively the `hdt` approach for `jns_rdflib` is best; for
other uses `jns_wdi` may be more convenient.

`wdi_get_dict(+Qnode,-Dict))`

:    \

`wdi_get_entity(+Qnode,-EDict))`

:    \

`wdi_sparql_query(+Qnode,+PropertyNode,-Ret)`

:    \

### Other Interfaces, Examples and Demos

##### jns_elastic

This module contains example code for using the Python ` elasticsearch`
package. A step by step description shows how a connection is opened,
and index is created and a document added and committed. The example
then shows how the document can be searched in two ways, and finally
deleted.

Much of the information that Elasticsearch reads and writes is in JSON
format, which the Python interface transforms to dictionaries, and
`janus` transforms these dictionaries to and from their term form. Thus
although this example is short, the ideas in it can easily be extended
to a full interface.[^13] Often the `elasticsearch` functions can be
called directly, but in certain cases simple Python functions must be
written to handle default positional arguments. [^14]

##### Reading XML files as `janus` Dictionaries

Although XSB's `SGML` package allows XML files to be read, the ability
to read XML structures as `janus` dictionaries can be convenient,
especially if an application already must navigate through `janus`
dictionaries for other purposes. The module ` jns_xmldict`, based on the
Python package ` xmltodict` [^15] provides a simple implementation of
this based on Python's `Expat` XML parser, and so retains the advantages
of `Expat` in terms of reliability, Unicode support and speed.

`xmldict_read(+File,-Dict)`

:    \
    Given an XML file `File`, this predicate opens `File`, parses its
    contents, transforms the contents into a dictionary, and unifies
    `Dict` with dictionary.

It is worthwhile noting that the Python `xmltodict` package offers
several keyword arguments and other options for parsing XML files and
strings, that can be easily accessed via user-written `janus` calls.

##### jns_spellcheck

This module provides a simple interface to `pyspellchecker`, a basic but
sometimes useful spell checker and corrector based on dictionaries and a
minimum edit distance search. Because a minimum edit distance search is
relatively expensive, it is best to check whether a word is known via
`sp_known/1`, and only call ` sp_correct/2` on unknown words.

The two main predicates are:

`sp_known(+Word)`

:    \
    Succeeds if `Word` is known to the `pyspellchecker` dictionary, and
    fails otherwise.

`sp_correct(+WordIn,-WordOut)`

:    \
    If `Word` has a reasonable minimum-edit distance to a word
    *word$_1$* in the `pyspellchecker` dictionary this predicate
    succeeds, unifying `WordOut` to *word$_1$*; otherwise the predicate
    fails.

##### jns_googleTrans

This example provides demo code to access Google's web-services for
language translation and language detection using `janus`.

\<

'

::: center
# `janus`: The Python 3 - XSB Interface {#chap:janus-py}
:::

::: center
**Version 2.0**
:::

::: center
**By Theresa Swift**
:::

***`janus-py` (`janus` support for Python to call Prolog) has been
tested on macOS and various versions of Linux. It is not currently
working on Windows.***[^16]

`janus-py` is the half of `janus` that allows XSB to be used as an
embedded subprocess within a Python process. Using `janus-py`()
virtually all XSB functionality is directly accessible from Python, with
various `janus-py` functions providing different trade-offs in terms of
speed, ease of use and generality. At the same time, `janus-py` is
nearly as fast as `janus-plg`: nearly half a million calls to, and
returns from a simple XSB predicate can be made per second. Data is
transferred very quickly: for instance list elements can be transferred
at a few tens of nanoseconds per list element.

`janus-py` is originally based on XSB's `px` module, but has been
heavily redesigned and improved by developers from XSB, SWI and Ciao in
an effort to make `janus` available and compatible in all three systems.
As a result, the Python module for `janus-py` is named `janus_xsb` in
order to distinguish its implementation from ` janus_swi` and eventually
`janus_ciao`. For Python examples in this chapter, we assume that the
calling environment has executed the statement

    import janus_xsb as jns

## Configuration, Loading and Start-up {#px:config}

### Installation on Linux and macOS

#### System Prerequisites

On Linux and MacOS, both `janus`-py and `janus`-plg are automatically
configured as part of the source code configuration and making process
for XSB, while on Windows `janus`-py is not yet working properly. This
configuration and make process itself requires most of the tools to
build `janus`-py (e.g., `build-essential` or `xcode`). In XSB `janus`
has been tested at various times on versions 3.6-3.11 of Python.

-   **Linux**

    `janus` requires Python development packages to have been installed
    for the Python version of interest. (See
    Section [\[sec:xsbpy-linux\]](#sec:xsbpy-linux){reference-type="ref"
    reference="sec:xsbpy-linux"} for an overview of installing such
    dependencies.) On Ubuntu, and other Debian-derived Linuxes
    installation also requires installing `${PYTHON}-distutils`, though
    this is not required for other Linuxes. For a given version of
    Python `$PYTHON` on Ubuntu, the command to install these Python
    packages would be:

    `sudo apt-get install ${PYTHON}-dev ${PYTHON}-distutils`

    On Fedora-based Linuxes, the `dnf` command must be used.[^17]

-   **macOS** For masOS, you'll need a development package of Python
    that includes `libpython.dylib` and `python.h`, both of which can be
    installed via homebrew, macports or other means.

#### Discussion

XSB's configuration/make process creates a file, ` janus_activate`,
somewhat analogous to activation code in ` venv` or other virtual
environments.[^18] In `bash` or `zsh`, simply type

    source $XSB_HOME/packages/xsbpy/px_activate

and you're ready to go.

Once `janus` has been built and activated, `janus` can be used just as
any other package installed as a personal or site package for
` ${PYTHON}`.

    $PYTHON
    >>> import janus as jns
    [xsb_configuration loaded]
    [sysinitrc loaded]
    [xsbbrat loaded]
    [janus loaded, cpu time used: 0.001 seconds]
    janus_initted_with_python(auto(python3.11))
    [janus_py loaded]

Note that XSB is initialized in the Python process when the `janus`
module is loaded.

As a final point, you can test `janus-py` by changing directory to

`$XSB_ROOT/xsbtests/janus_tests`

and executing the command `bash test.sh ` $< xsb\_executable\_path>$

The test script executes a number of `janus` examples, which may be
useful for trying out various features.

## Using `janus-py` {#sec:using-januspy}

Although Python and Prolog have similarities at the data structure level
(Section [1.2](#sec:jns-bi-translation){reference-type="ref"
reference="sec:jns-bi-translation"}) they differ substantially in their
execution. In terms of input, `janus-py` functions are either

-   *Variadic:* passing to XSB a module, a predicate name, zero or more
    input arguments and zero or more keyword arguments
    (` jns.apply_once()`,`jns.apply()` and `jns.comp()`); or

-   *String-based:* passing a Prolog goal as a string, with input and
    output bindings passed via dictionaries (` jns.query_once()` and
    `jns.query()`).

In terms of output, `janus-py` functions have three different behaviors.

-   *Deterministic*: passing back a single answer (` jns.apply_once()`,
    `jns.query_once())`;

-   *Itertor-based*: returning answers for a Prolog goal $G$ via an
    instance of a class whose iterator backtracks through answers to $G$
    (`jns.apply()`, `jns.query())`; or

-   *Comprehension-based*: passing back multiple answers as a list or
    set (`jns.comp())`.

We discuss these various approaches using a series of examples.

### Deterministic Queries and Commands {#sec:jnsdet}

In these examples, features of `janus-py` are presented via commands and
deterministic queries before turning to general support of
non-deterministic queries. We begin with the variadic deterministic
calls (`jns.apply_once()` and `jns.cmd`); and then proceed to the
deterministic string-based call `jns.query_once()`.

#### Variadic Deterministic Queries and Commands

::: {#ex:apply-once .example}
**Example 2.1**. *[]{#ex:apply-once-reverse
label="ex:apply-once-reverse"} *Calling a deterministic query via
`jns.apply_once()`* *

*As described in
Section [\[jns-py:config\]](#jns-py:config){reference-type="ref"
reference="jns-py:config"} `janus` is loaded like any other Python
module. Once loaded, a simple way to use `janus` is to execute a
deterministic query to XSB. The Python statement:*

    >>> Ans = jns.apply_once('basics','reverse',[1,2,3,('mytuple'),{'a':{'b':'c'}}])

*asks XSB to reverse a list using `basics:reverse(+,-)` -- i.e., with
the first argument ground and the second argument free. To execute this
query the input list along with the tuple and dictionary it contains are
translated to XSB terms as described in
Section [1.2](#sec:jns-bi-translation){reference-type="ref"
reference="sec:jns-bi-translation"}, the query is executed, and the
answer translated back to Python and assigning `Ans` the value*

    [{'a':{'b':'c'}},('mytuple'),3,2,1]
:::

For learning `janus` or for tutorials, a family of pretty printing calls
can be useful.

::: {#ex:janus-py-pp .example}
**Example 2.2**. *Viewing `janus-py` in Prolog Syntax *

*The `pp_jns_apply_once()` function calls ` jns_apply_once()` and upon
return pretty prints both the call and return in a style like that used
in XSB"s command line interface. For example if the following call is
made on the Python command line interface:*

    >>> pp_jns_apply_once('basics','reverse',[1,2,3,('mytuple'),{'a':{'b':'c'}}])

*the function will print out both the query and answer in Prolog syntax
as if it were executed in XSB.[^19]*

    ?- basics:reverse(([1,2,3,-(mytuple), {a:{b:c}}],Answer).

       Answer  = [{a:{b:c}}, mytuple, 3, 2, 1]
       TV = True
:::

Note that the Python calls in the above example each had a module name
as their first position, a function name in their second position, and
the Prolog query argument in their third position. The translation to
XSB by `jns.apply_once()` adds an extra unbound variable as the last
argument in the query so that the query had two arguments.

The variadic `jns.cmd()` provides a convenient way manage the Prolog
session from Python.

::: {#ex:jns-cmd .example}
**Example 2.3**. **Session management in `janus-py` using `jns.cmd()`* *

*Once `janus-py` has been imported (initializing XSB), any user XSB code
can be loaded easily. One can execute*

    >>>  jns.cmd('consult','consult','xsb_file')

*which loads the XSB file `xsb_file.{P,pl}`, compiling it if necessary.
Note that unlike (the default behavior of) ` jns_apply_once()`,
`jns.cmd()` does not add an extra return argument to the Prolog call.
For convenience and compatibility, `janus-py` also defines a shortcut
for consulting:*

    >>>  jns.consult('xsb_file')

*`janus-py` also provides shortcuts for some other frequent Prolog calls
-- other desired shortcuts are easily implemented via Python functions.*

*If a Prolog file `xsb_file.P`, is modified it can be reconsulted in the
same session just as if the XSB interpreter were being used. Indeed,
using `janus-py`, the Python interpreter can be used as a command-line
interface for writing and debugging XSB code (although the XSB
interpreter is recommended for most XSB development tasks).*
:::

The following example shows how Python can handle errors thrown by
Prolog.

::: {#ex:janus-py-errors .example}
**Example 2.4**. **Error handling in `janus-py`* *

*If an exception occurs when XSB is executing a goal, the error can be
caught in XSB by `catch/3` in the usual manner. If the error is not
caught by user code, it will be caught by `janus-py`, translated to a
Python exception of the vanilla `Exception` class,[^20] and can be
caught as any other Python exception of that type. Precise information
about the XSB exception is available to Python through the `janus-py`
function ` jns_get_error_message()`,*

*Consider what happens when trying to consult a file that doesn't exist
in any of the XSB library paths. In this case, XSB's `consult/1` throws
an exception, the `janus-py` sub-system catches it and raises a Python
error as mentioned above. The Python error is easily handled: for
instance by calling the function in a block such as the following:*

        try
          <some jns.function>
        except Exception as err:
          display_xsb_error(err)

*where `display_xsb_error()` is a call to the function:*

    def display_xsb_error(err):    
            print('Exception Caught from XSB: ')
            print('      ' + jns.get_error_message())

*where, `jns.get_error_message()` is calls C to return the last
`janus-py` error text as a string. If an exception arises during
execution of a `janus-py` function the function returns the value
` None` in addition to setting a Python Error.*

*Error handling is performed automatically in `pp_jns_apply_once()` and
other pretty-printing calls.*
:::

Although the string-based queries are the most general way for Python to
query Prolog, the variadic functions `jns.apply_once()` and `jns.cmd()`
and `jns.comp()` (to be introduced) can all make queries with different
numbers of input arguments.

::: {#ex:variadic-examples .example}
**Example 2.5**. **Varying the number of arguments in `jns.apply_once()`
and `jns.cmd()`* *

*Suppose you wanted to make a ground Prolog query, say `?- p(a)`: the
information answered by this query would simply indicate whether the
atom `p(a)` was `true`, `false`,,or `undefined` in the Well-Founded
Model. In `janus-py` such a query could most easily be made via the
`janus-py` function `jns.cmd()`*

    >>> jns.cmd('jns_test','p','a')  

*Since `jns.cmd` does not return any answer bindings, it returns the
truth value directly to Python, rather than as part of a tuple. However,
`jns.apply_once()` and `jns.cmd()` are both variadic functions so that
the number of input arguments can also vary as shown in the table
below.*

  -------------------------------------- ------------------ --------------------
  *`jns.cmd(’mod’,’cmd’)`*               *calls the goal*   *`mod:cmd()`*
  *`jns.cmd(’mod’,’cmd’,’a’)`*           *calls the goal*   *`mod:cmd(a)`*
  *`jns.cmd(’mod’,’cmd’,’a’,’b’)`*       *calls the goal*   *`mod:cmd(a,b)`*
  *`jns.apply_once(’mod’,’pred’)`*       *calls the goal*   *`mod:pred(X1)`*
  *`jns.apply_once(’mod’,’pred’,’a’)`*   *calls the goal*   *`mod:pred(a,X1)`*
  -------------------------------------- ------------------ --------------------

*More generality is allowed in the non-deterministic `jns.comp()`
discussed more fully in
Section [2.2.2.3](#sec:comp){reference-type="ref" reference="sec:comp"}.
In `jns.comp()` the optional keyword argument `vars` can be used to
indicate the number of return arguments desired. So, if `vars=2` were
added as a keyword argument, two arguments arguments would be added to
the call, with each a free variable. Combining both approaches, a
variety of different Prolog queries can be made as shown in the
following table. [^21]*

  ------------------------------------------- ------------------ -------------------------
  *`jns.comp(’mod’,’pred’),vars=2`*           *calls the goal*   *`mod:pred(X1,X2)`*
  *`jns.comp(’mod’,’pred’,’a’,vars=0)`*       *calls the goal*   *`mod:pred(a)`.*
  *`jns.comp(’mod’,’pred’,’a’,vars=1)`*       *calls the goal*   *`mod:pred(a,X1)`*
  *`jns.comp(’mod’,’pred’,’a’,vars=2)`*       *calls the goal*   *`mod:pred(a,X1,X2)`*
  *`jns.comp(’mod’,’pred’,’a’,’b’,vars=2)`*   *calls the goal*   *`mod:pred(a,b,X1,X2)`*
  ------------------------------------------- ------------------ -------------------------
:::

#### Deterministic String Queries

A more general approach to querying Prolog is to use one of the
string-based functions -- either the deterministic `jns.query_once()` or
the non-deterministic `jns.query()`. These functions support logical
variables so that each argument of the call can be ground,
uninstantiated or partially ground. To support this generality, a
slightly more sophisticated setup is required, and the invocations are
somewhat slower. (See Section [2.4](#sec:jns-perf){reference-type="ref"
reference="sec:jns-perf"} for timings.)

::: {#ex:query-once .example}
**Example 2.6**. **Calling a deterministic query via `jns.query_once()`*
*

*The Prolog goal in Example [2.1](#ex:apply-once){reference-type="ref"
reference="ex:apply-once"} can also be executed using `jns.query_once()`
by forming a syntactically correct Prolog query and specifying the
bindings that are required for Prolog variables. For instance, a
function call such as the following could be made:*

    AnsDict = jns.query_once('basics:reverse(List,RevList)',
                            inputs={'List'=[1,2,3,('mytuple'),{'a':{'b':'c'}}]})

*Note that both `List` and `RevList` are treated as logical variables by
Prolog. When the function is called the value of the index `’List’` in
the dictionary `inputs` will be translated to Prolog syntax:
`[1,2,3,-(mytuple),{a:{b:c}}]` (which has nearly the same syntax as the
corresponding Python data structure). This Prolog term will be unified
with the logical variable `List` so that the following Prolog goal is
called:*

    ?- basics:reverse([1,2,3,-(mytuple),{a:{b:c}}],RevList)

*upon return assigning to `Answer` the Python *return dictionary**

    { 'RevList':{'a':{'b':'c'}},('mytuple'),3,2,1], truth:True }

*in which the logical variable name `’RevList’` is a key of the return
dictionary. Note that the return dictionary contains not only all
bindings to all logical variables in the query, but also a truth value.
In this case*

    >>> AnsDict['truth'] = True

*By default, `jns.query_once()`, `jns.query()`, and ` jns.com()`, return
one of three truth values*

-   *`True` representing the truth value *true*. This means the XSB
    query succeeded and that the answer with bindings
    (` AnsDict[’RevList’]`) is true in the Well-Founded Model of the
    program.[^22]*

-   *`False` representing the truth value *false*. This means the XSB
    query failed and has no answers in the Well-Founded Model of the
    program. In such a case, the return dictionary has the form*

        {truth:False}

-   *`jns.Undefined` representing the truth value *undefined*. This
    means that the XSB query succeeded, but the answer is neither *true*
    nor *false* in the Well-Funded Model of the program.[^23]*

*Although XSB's three-valued logic can be highly useful for many
purposes, it can be safely ignored in many applications, and most
queries will either succeed with true answers or will fail.[^24]*

*Although the above call of `jns.query_once()` uses a single input and
output variable, `jns.query_once()` is in fact highly flexible. Once
could alternately call the goal with the input variable already bound:*

    Answer = jns.query_once("basics:reverse([1,2,3,{'a':{'b':'c'}}],Rev)")

*which would produce the same return dictionary as before.*

*One can even call*

    Answer = jns.query_once('basics:reverse([1,2,3,-('mytuple'),{'a':{'b':'c'}}],
                                            {'a':{'b':'c'}},-('mytuple'),3,2,1])'

*which would produce the return dictionary `{’truth’:True}`. It should
be noted that any data structures within the goal string (i.e., the
second argument of `jns.query_once()`) must already be in Prolog syntax,
so it easier to use logical variables and dictionaries for input and
output whenever the Python and Prolog syntaxes diverge (e.g., for tuples
and sets).*

*One also can use more than one input variable: for instance the call*

    >>> Answer = jns.query_once('basics:reverse([1,2,3,InputTuple,InputDict],RetList)',
                            inputs={InputTuple:-('mytuple'),InputDict={'a':{'b':'c'}}])

*which is equivalent to the Prolog query:*

    ?- InputTuple:-(mytuple),InputDict={a:{b:c}},
       basics:reverse([1,2,3,InputTuple,InputDict],RetList),

*which would produce a return dictionary with the binding to ` RetList`
as above.*
:::

### Non-Deterministic Queries {#sec:jnsnteddet}

There are three ways to call non-deterministic Prolog queries in
`janus-py`. A class -- either the variadic `jns.apply` or the
string-based `jns.query` -- can be instantiated whose iterator
backtracks through Prolog answers. Alternately, the Prolog answers can
be comprehended into a list or set and returned to Python. We consider
each of these cases in turn.

#### Variadic Non-Deterministic Queries {#sec:var-nd}

Consider the predicate `test_nd/2` in the Prolog module `jns_test`.

    test_nd(a,1).
    test_nd(a,11).
    test_nd(a,111).
    test_nd(b,2).
    test_nd(c,3).
    test_nd(d,4).
    test_nd(d,5):- unk(something),p.
    test_nd(d,5):- q,unk(something_else).
    test_nd(d,5):- failing_goal,unk(something_else).

    p.
    q.

In this module, the predicate `unk/1` is defined as

    unk(X):- tnot(unk(X)).

so that for a ground input term $T$ `unk(T)` succeeds with the truth
value *undefined* in the program's Well-Founded Model. The call

    jns.apply('jns_test','test_nd','a')

creates an instance of the Python class `jns.apply` that can be used to
backtrack through the answers to `test_nd(e,X)`. Such a class can be
used wherever a Python iterator object can be used, for instance;

    C1 = jns.apply('jns_test','test_nd','a')
    for answer in C1:
      ...

will iterate through all answers to the Prolog goal ` test_nd(X,Y)`.

#### String-Based Non-Deterministic Queries {#sec:nd-query}

String-based non-deterministic queries are similar to ` jns.apply()`.
For the program `jns_test` of
Section [2.2.2.1](#sec:var-nd){reference-type="ref"
reference="sec:var-nd"} the goal

    jns.query('jns_test','test_nd(X,Y)')

creates an instance of the Python class `jns.query` that can be used to
iterate through solutions to the Prolog goal e.g.,

    C1 = jns.query('jns_test','test_nd(X,Y)')
    for answer in C1:
      ...

The handling of input and output variable bindings is exactly as in
`jns.query_once` in
Section [2.2.2](#sec:jnsnteddet){reference-type="ref"
reference="sec:jnsnteddet"}.

The next example shows different ways in which `janus-py` can express
truth values.

::: {#ex:truth-vals .example}
**Example 2.7**. *Expressing Truth Values *

*In `jns.query_once()`, `jns.query()` and `jns.comp()` truth values can
be expressed in different ways. Consider the fragment:*

    for ans in jns.query('jns_test','test_nd(d,Y)')
       print(ans)

*would print out by default*

    {d:4, truth:True}
    {d:5, truth:Undefined}
    {d:5, truth:Undefined}

*While this default behavior is the best choice for most purposes, there
are cases where the delay list of answers needs to be accessed (cf.
Volume 1, chapter 5) for instance if the answers are to be displayed in
a UI or sent to an ASP solver. In such a case, the keyword argument
`truth_vals` can be set to `DELAY_LISTS`, so that the fragment*

    for ans in jns.query('jns_test','test_nd(d,Y)',truth_vals=DELAY_LISTS) 
       print(ans)

*prints out*

    {Y:4, DelayList:[]}
    {Y:5, DelayList:(plgTerm, unk, something)]}}
    {Y:5, DelayList:(plgTerm, unk, something_else)]}

*In XSB's SLG resolution, a delay list is a set of Prolog literals, but
Prolog literals cannot be directly represented in Python. XSB addresses
this by serializing a term $T$ as follows:*

::: tabbing
*foooof̄oooof̄oooof̄oooof̄oooooooooooooooooooooōoō if $T$ is a non-list term
$T=f(arg_1,...,arg_n)$:\
$serialize(T) = ($plgterm,$serialize(rg_1),...,serialize(arg_n))$\
else $serialize(T) = T$*
:::

*so that the delay list received by Python is a list of serialized
literals.*

*Alternately, if one were certain that no answers would have the truth
value *undefined*, the keyword argument `truth_vals` could be set to
`NO_TRUTHVALS`. For instance*

    for ans in jns.query('jns_test','test_nd(a,Y)',truth_vals=NO_TRUTHVALS) 
       print(ans)

*prints out*

    {Y:1}
    {Y:11}
    {Y:111}
:::

#### Comprehension of Non-Deterministic Queries {#sec:comp}

*The handling of set and list comprehension in `janus` is likely either
to undergo a major revision or to become obsolescent.*

A declarative aspect of Python is its support for comprehension of
lists, sets and aggregates. `janus-py` can fit non-deterministic queries
into this paradigm with *query comprehension*: calls to XSB that return
all solutions to an XSB query as a Python list or all unique solutions
as a set.

::: {#ex:jns-list-comp-1 .example}
**Example 2.8**. **List and Set Comprehension in `janus-py`* *

*Consider again the program `jns_test` introduced in
Section [2.2.2.1](#sec:var-nd){reference-type="ref"
reference="sec:var-nd"}. The Python function*

    >>>  jns.comp('jns_test','test_comp',vars=2)

*calls the XSB goal `?- jns_test:test_comp(X1,X2)` in a manner somewhat
similar to `jns.apply_once()` in
Section [2.2.2.1](#sec:var-nd){reference-type="ref"
reference="sec:var-nd"}, but with several important differences. First,
the keyword argument `vars` set to `2` means that there are two return
variables. Another difference is that the call to ` jns.comp()` returns
multiple solutions as a list of tuples, rather than using an iterator to
return a sequence of answer dictionaries. Formatted this return is:*

         [
          ((e,5),2),((e,5),2),
          ((d,4),1),((c,3),1),
          ((b,2),1),((a,1),1) 
          ((a,11),1),((a,111),1) 
         ]

*Note that each answer in the comprehension is a 2-ary tuple, the first
argument of which represents bindings to the return variables, and the
second its truth value: *true* as `1`, *undefined* as `2`.*

    >>>  jns.comp('jns_test','test_comp',vars=2,set_collect=True)

*returns a set rather than a list.[^25] If there are no answers that
satisfy the query `jns.comp()` returns the empty list or set.*

*Whether it is a list or a set, the return of `jns.comp()` will be
iterable and can be used as any other object of its type, for example:*

    >>> for answer,tv in jns.comp('jns_test','test_comp',vars=2):
    ...     print('answer = '+str(answer)+' ; tv = '+str(tv))
    ... 
    answer = ('e', 5) ; tv = 2
    answer = ('e', 5) ; tv = 2
    answer = ('d', 4) ; tv = 1
    answer = ('c', 3) ; tv = 1
    answer = ('b', 2) ; tv = 1
    answer = ('a', 1) ; tv = 1
    answer = ('a', 11) ; tv = 1
    answer = ('a', 111) ; tv = 1
:::

As with `jns.query()`, `jns.comp()` also supports the different options
for the keyword argument `truth_vals` (cf.
Section [2.2.2.2](#sec:nd-query){reference-type="ref"
reference="sec:nd-query"}).

### Callbacks from XSB to Python {#sec:callbacks}

When XSB is called from Python, `janus` can easily be used to make
callbacks to Python. For instance, the query:

    jns.apply_once('jns_callbacks','test_json')

calls the XSB goal `jns_callbacks:test_json(X)` as usual. The file
`jns_callbacks.P` can be found in the directory

`$XSB_ROOT/xsbtests/janus_tests`

This directory contains many other examples including those discussed in
this chapter. In particular, `jns_callbacks.P` contains the predicate:

    test_json(Ret):- 
       pyfunc(xp_json,
              prolog_loads('{"name":"Bob","languages": ["English","Fench","GERMAN"]}'),
              Ret).

that calls the Python JSON loader as in
Example [1.1](#ex:janus-json){reference-type="ref"
reference="ex:janus-json"}, returning the tuple

    ({'name': 'Bob', 'languages': ['English', 'Fench', 'GERMAN']}, 1)

to Python. This example shows how easy it can be for XSB and Python to
work together: the Python call
`jns.apply_once('jns_callbacks','test_json')` causes the JSON structure
to be read from a string into a Python dictionary, translated to a
Prolog dictionary term, and then back to a Python dictionary associated
with its truth value.

As another example of callbacks consider the goal:

    TV = jns.apply_once('jns_callbacks','test_class','joe')

that calls the XSB rule:

    test_class(Name,Obj):-
       jns.apply_once('jns_callbacks','test_class','joe')

that in turn creates an instance of the class `Person` via:

    class Person:
      def __init__(self, name, age, favorite_ice_cream=None):
        self.name = name
        self.age = age
        if favorite_ice_cream is None:
          favorite_ice_cream = 'chocolate'
        self.favorite_ice_cream = favorite_ice_cream

The reference to the new `Person` instance is returned to Prolog, then
back to Python and assigned to the variable `NewClass`. Afterwards,
accessing `NewClass` properties from the original Python command line:

    >>> NewClass.name

is evaluated to `’joe’` as expected. In other words, the Python
environment calling XSB and that called by XSB are one and the same. The
coupling between Python and XSB is both implementationally tight and
semantically transparent; micro-computations can be shifted between XSB
and Python depending on which language is more useful for a given
purpose.

### Constraints

The material in this section is not necessary to understand for a basic
use of `janus-py`, but shows how `janus-py` can be used for
constraint-based reasoning.

::: {#ex:connstraints .example}
**Example 2.9**. **Evaluating queries with constraints* *

*XSB provides support for constraint-based reasoning via
CLP(R) [@Holz95] both for Prolog-style (non-tabled) and for tabled
resolution. However, using constraint-based reasoners like CLP(R)
requires explicit use of logical variables (cf.
Chapter [\[chap:constraints\]](#chap:constraints){reference-type="ref"
reference="chap:constraints"}), and as mentioned in
Section [2.2.1](#sec:jnsdet){reference-type="ref"
reference="sec:jnsdet"}, `janus-py` does not provide a direct way to
represent logical variables since logical variables do not naturally
correspond to a Python type. Fortunately, it is not difficult to pass
constraint expressions containing logical variables to XSB within Python
strings.*

*Consider a query to find whether*

*$$X  > 3*Y + 2,Y>0 \models X > Y$$*

*In CLP(R) this is done by writing a clause to assert the two
constraints -- in Prolog syntax as calls to the literals
`{X `$>$` 3*Y + 2}` and `{Y`$>$`0}` -- and then calling the CLP(R) goal
`entailed(Y`$>$`0)`. Within XSB, one way to generalize the entailment
relation into a predicate would be to see if one set of constraints,
represented as a list, implies a given constraint:*

    :- import {}/1,entailed/1 from clpr.

      check_entailed(Constraints,Entailed):- 
         set_up_constraints(Constraints),
         entailed(Entailed).

      set_up_constraints([]).
      set_up_constraints([Constr,Rest]):- 
         {Constr},
         set_up_constraints(Rest).

*Using our example, a query to this predicate would have the form*

     ?- check_entailed([X  > 3*Y + 2,Y>0],X > Y).

*This formulation requires the logical variables `X` and `Y` to be
passed into the call. Checking constraint entailment via `janus-py` only
requires writing the constraints as a string in Python and later having
XSB read the string. A predicate to do this from Python is similar to
`check_entailed/2` above, but unpacks the constraints from the input
atom (i.e., the XSB translation of the Python string).*

    :- import read_atom_to_term/3 from string.

    jns.check_entailed(Atom):-
        read_atom_to_term(Atom,Cterm,_Cvars),
        Cterm = [Constraints,Entailed],
        set_up_constraints(Constraints),
        entailed(Entailed).

*The function call from Python is simply:*

    >>>  jns.cmd('jns_constraints','check_entailed','[[X  > 3*Y + 2,Y>0],[X > Y]]')

*Note that the only difference when calling from Python is to put the
two arguments together into a single Python string, so that XSB's reader
treats the `Y` variable in the input constraints and the entailment
constraint as the same [^26]*
:::

### Other `janus-py` Resources and Examples

Many of the examples from this chapter have been saved into Jupyter
notebooks in `$XSB_ROOT/XSB/examples`, with associated PDF files in
`$XSB_ROOT/docs/JupyterNotebooks`.

In addition, as mentioned earlier the directory
` $XSB_ROOT/xsbtests/janus_tests` contains a series of tests for most of
the examples in this chapter and many others.

## The `janus-py` API

When describing Python calls to Prolog tn this section, we sometimes
assume for clarity that the calling environment has executed the
statement `import janus_xsb as jns`.

`cmd(module,pred,*args)`

:    \
    Allows Python to execute a Prolog goal `Goal` containing no
    variables. Each argument in `Goal` corresponds to an element in
    `args`, i.e., the input is translated to
    $module.pred(\overrightarrow{args})$, where $\overrightarrow{args}$
    is an argument vector. For instance the Python call

    `jns.cmd(’consult’,’ensure_loaded’,’jns_test’)`

    calls `consult:ensure_loaded(jns_test)`. When `janus` is used with
    XSB, calls to Prolog predicates that are not in a module may be made
    with `module` set to `usermod`. (Also cf. Example
    [2.5](#ex:variadic-examples){reference-type="ref"
    reference="ex:variadic-examples"} and Example
    [2.3](#ex:jns-cmd){reference-type="ref" reference="ex:jns-cmd"}.)

    In normal execution, `jns.cmd()` returns the truth value of the goal
    as explained in
    Section [2.2](#sec:using-januspy){reference-type="ref"
    reference="sec:using-januspy"}. If an error occurred during Prolog
    execution an Python error is set and the value `None` is returned.

`apply_once(module,pred,*args,**kwargs)`

:    \
    Allows Python to execute a Prolog query, the last argument of which
    is a variable. Unlike with `jns.apply()` the query should be
    deterimistic: otherwise only the query's first answer is returned.
    If the number of `args` is `n`, a call will be made to
    `module:pred/(n+1)` in which the first `n` arguments correspond to
    the arguments in `args` and the binding of the final argument is
    returned to Python as a Python object, i.e. a call
    $module.pred(\overrightarrow{args},Ret)$ is created, where the
    binding of $Ret$ is returned. For example: the call

    `jns.apply_once(’basics’,’reverse’,[1,2,3,``’a’:``’b’:’c’``]))`

    executes the Prolog goal

    '`basics.reverse([1,2,3,``’a’:``’b’:’c’``],Ret)`

    and passes back

    `[``’a’:``’b’:’c’``,3,2,1]`

    to Python. (Also cf.
    Example [2.5](#ex:variadic-examples){reference-type="ref"
    reference="ex:variadic-examples"} for examples of using a varying
    number of arguments.)

    `jns.apply_once()` is designed to be very fast, so it does not
    return a truth value. If the keyword binding
    ` truth_vals=jns.PLAIN_TRUTHVALS` is used, the function returns a
    return dictionary containing both the return and its truth value,
    (cf. Example [2.7](#ex:truth-vals){reference-type="ref"
    reference="ex:truth-vals"}).

`query_once(query_string,**kwargs)`

:    \
    Calls the Prolog goal `query_string` which must be a well-formed
    Prolog atom `Atom` or `Module:Atom` where ` Module` is a Prolog
    module name. (No ending period should be a part of `query_string`.)
    As discussed in Example [2.6](#ex:query-once){reference-type="ref"
    reference="ex:query-once"}, `query_string` is parsed by Prolog. If
    there is a dictionary *Dict* associated with an ` inputs` keyword
    argument, then for any logical variable $V_i$ in `query_string` and
    Python data structure $A_i$ such that $V_i:A_i$ is an item in
    *Dict*, $A_i$ is translated to a Prolog term and unified with $V_i$.
    All other logical variables in ` query_string` are taken to be
    (uninstantiated) output variables. Upon the success of
    `query_string` their bindings are represented in the return
    dictionary, which also by default contains the truth value of the
    answer to `query_string`.

    `kwargs` allows the following types of keyword arguments.

    -   `truth_vals` determines whether and how each answer in the
        collection is associated with its truth value. (Cf.
        Example [2.7](#ex:truth-vals){reference-type="ref"
        reference="ex:truth-vals"} for examples of how the ` truth_vals`
        options affects returns.)

        Values can be:

        -   `PLAIN_TRUTHVALS` which associates each answer with its
            truth value *true* (represented as `True` or *undefined*
            represented as ` jns.Undefined`. (Unlike `jns.cmd()` *false*
            answers are never returned.) This is the default behavior
            for `jns.query_once()` and ` jns.query()`. along with
            `jns.comp()`.

        -   `DELAY_LISTS` which associates each answer with its SLG
            delay list. (See
            Example [2.7](#ex:truth-vals){reference-type="ref"
            reference="ex:truth-vals"} for more information on this
            option; or for background on delay lists, the chapter *Using
            Tabling in XSB: A Tutorial Introduction* in Volume 1 of this
            manual.)

        -   `NO_TRUTHVALS` does not associate an answer with any truth
            value. This option is the default for ` jns.apply_once` and
            `jns.apply()`. This option should only be used in situations
            where it is know that no answers will be *undefined*.

    -   `Inputs` which contains input bindings (in Python syntax) to one
        or more logical variables in ` jns.query_string` as explained in
        Example [2.6](#ex:query-once){reference-type="ref"
        reference="ex:query-once"}.

`apply(module,pred,*args)`

:    \
    `jns.apply()` is called in the same manner as ` jns.apply_once()`
    but creates an instance of an iterator class that is used to
    backtrack through all solutions to the constructed goal. The Prolog
    goal invoked is automatically closed after iterating through all
    solutions, or when an explicit `jns.close_query()` is called. See
    Section [2.2.2.1](#sec:var-nd){reference-type="ref"
    reference="sec:var-nd"} for examples of its use.

`query(query_string,**kwargs)`

:    \
    The string-based `jns.query()` is called in the same manner as
    `jns.query_once()` but creates an instance of an iterator class that
    is used to backtrack through all solutions to the constructed goal.
    The Prolog goal invoked is automatically closed after iterating
    through all solutions, or when an explicit `jns.close_query()` is
    called. See Section [2.2.2.2](#sec:nd-query){reference-type="ref"
    reference="sec:nd-query"} for examples of its use.

`close_query()`

:    \
    Closes a Prolog goal that was opened by `jns.apply()` or
    `jns.query()`.

    In general, a Prolog query opened by `jns.apply()` or ` jns.query()`
    closes automatically when all answers to the query have been
    derived. (The `__next__()` method for the ` jns.apply` and `query`
    classes ensures this). An iterator $I$ is also automatically closed
    when Python execution leaves the scope of $I$. However, since only
    one Prolog query can be open at one time, an explicit close is
    requured in situations where 1) not all answers are required, and 2)
    the control flow is such that Python will not automatically close
    the iterator. A schematic example is:

        MyIter = jns.apply(...)
        :
        for elt in MyIter:
          do something
          if condition:
             jns.close_query()    

    TES: The name close_query() is arguably misleading, since it can be
    used both for jns.query() and jns.apply(). The name jns.close() is
    also ambiguous since it might be taken to mean that janus -- and the
    underlying Prolog -- should be closed.

`comp(module,pred,*args,**kwargs)`

:    \
    Allows Python to call Prolog to perform the equivalent of list or
    set comprehension. `jns.comp()` allows zero or more input arguments
    each containing a Python term ($\overrightarrow{input}$) and zero or
    more output arguments ($\overrightarrow{output}$) to call a Prolog
    goal

    $$module:pred(\overrightarrow{inputs},\overrightarrow{outputs})$$

    It then returns to Python a list or set of tuples representing all
    bindings (or all unique bindings) to $\overrightarrow{outputs}$ for
    which the above goal is true. See Examples
    [2.8](#ex:jns-list-comp-1){reference-type="ref"
    reference="ex:jns-list-comp-1"} and
    [2.5](#ex:variadic-examples){reference-type="ref"
    reference="ex:variadic-examples"} for elaboration on this.

    The actual behavior of `jns.comp()` depends on the keyword arguments
    passed to it.

    `kwargs` can take the following values:

    -   `vars=N` where `N` is a non-negative integer, determines the
        number `N` of output variables for the call. For instance

          --------------------------------- ---------------- -----------------------
          `jns.comp(mod,pred)`              calls the goal   `mod:pred(X1)`
          `jns.comp(mod,pred),vars=2`       calls the goal   `mod:pred(X1,X2)`
          `jns.comp(mod,pred,a,vars=0)`     calls the goal   `mod:pred(a)`.
          `jns.comp(mod,pred,a)`            calls the goal   `mod:pred(a,X1)`
          `jns.comp(mod,pred,a,vars=1)`     calls the goal   `mod:pred(a,X1)`
          `jns.comp(mod,pred,a,vars=2)`     calls the goal   `mod:pred(a,X1,X2)`
          `jns.comp(mod,pred,a,b,vars=2)`   calls the goal   `mod:pred(a,b,X1,X2)`
          --------------------------------- ---------------- -----------------------

        The default is `1`.

    -   `set_collect=True/False` determines the type of collection in
        which the bindings are returned: if the keyword argument is
        `True`, the answers are collected as a set, and if `False` the
        answers are collected as a list. Default is `False`. [^27]

    -   `truth_vals` determines whether how each answer in the
        collection is associated with its truth value. The values and
        their behavior are the same as in `query_once()` and ` query()`:

        -   `PLAIN_TRUTHVALS` which associates each answer with its
            truth value true. (Unlike `jns.cmd()` or
            ` jns.apply_once()`, *false* answers are never included in
            the collection returned by `jns.comp()`.) Using
            ` PLAIN_TRUTHVALS`, each element of the collection is a
            2-ary tuple consisting of an answer and its truth value.
            This is the default behavior for `jns.comp()`.

        -   `DELAY_LISTS` which associates each answer with its SLG
            delay list. (See
            Example [2.7](#ex:truth-vals){reference-type="ref"
            reference="ex:truth-vals"} or for more information, the
            chapter *Using Tabling in Prolog: A Tutorial Introduction*
            in Volume 1 of this manual.)

        -   `NO_TRUTHVALS` does not associate an answer with any truth
            value. This option should only be used in situations where
            it is know that no answers will be *undefined*.

`get_error_message()`

:    \
    If a Prolog exception was raised by the previous call to Prolog,
    ` get_error_message()` returns the Prolog exception message as a
    Python Unicode string. See
    Example [2.4](#ex:janus-py-errors){reference-type="ref"
    reference="ex:janus-py-errors"} for an example of how errors can be
    caught and displayed.

### `janus-py` API Compatubility and Convenience Predicates

These predicates for managing the Prolog session are usually defined in
terms of other predicates in the `janus-py` API, and are included for
convenience or compatibility.

`consult(File)`

:    \

`ensure_loaded(File)`

:    \
    Convenience functions for loading and/or compiling Prolog files. In
    XSB, they are defined as

    `jns.cmd(’consult’,’consult’,File)`

    and

    `jns.cmd(’consult’,’ensure_loaded’,File)`.[^28]

    Note that a given Prolog file can be compiled and/or loaded into the
    running Python-Prolog session (via `consult()` or
    ` ensure_loaded()`), edited and then repeatedly recompiled and
    reloaded without problems.

`prolog_paths()`

:    \
    Convenience function to return a list of all current Prolog library
    paths (Prolog's equivalent of Python's `sys.path`).

`add_prolog_path(Paths)`

:    \
    Convenience function to add one or more Prolog library paths
    designated as a list of strings. This function calls Prolog's
    equivalent of Python's `sys.path.append()`) and is defined as:
    `jns.cmd(’consult’,’add_lib_dir’,Paths)`.

## Performance {#sec:jns-perf}

This section provides information on various aspects of `janus-py`
performance: `janus-py`, which while usually not quite as fast as
`janus-plg` is still very fast, especially `jns.cmd()`,
` jns.apply_once()` and `ins.apply()`.[^29]

### Tests of Latency of Function Calls

By "latency" we mean the amount of time required for Python to call XSB
and return from that call when little or no data is transferred. For the
predicate

    simple_call(N,N1):- N1 is N + 1.

The rows of Table [2.1](#table:janus-py-latency){reference-type="ref"
reference="table:janus-py-latency"} provide iterations per second for
following `janus-py`() functions.

-   `jns.cmd()` tests iterations of the goal

        jns.cmd(jns_test,'simple_call',N,1,2)

-   `jns_apply_once()` tests iterations of

        jns.apply_once('jns_test','simple_call',N)

    for different values of `N`

-   `jns_query_once()` (ground) tests iterations of

        jns.query_once('jns_test:simple_call(1,2)')

-   `jns_query_once()` (non-ground) tests iterations of

        jns.query_once('jns_test:simple_call(1,Num1)')

    Finally, the "Python only" row measures number of iterations to for
    a Python loop to call a Python function to increment an integer.

[]{#table:janus-py-latency label="table:janus-py-latency"}

::: centering
::: {#table:janus-py-latency}
  --------------------- -------------- ------------
  Python only                            14,341,000
  `jns.cmd()`                               324,000
  `jns.apply_once()`                        280,000
  `jns.query_once() `   (ground)            143,000
  `jns.query_once()`    (non-ground)        124,000
  --------------------- -------------- ------------

  : Performance of functions to increment an integer in iterations per
  second
:::
:::

### Tests of List Comprehension

List comprehension were tested on the following predicate under various
options. It can be seen that passing back delay lists incurs very little
overhead compared to default truth values.

    test_comp(a,1).                       test_comp(b,2).
    test_comp(c,3).                       test_comp(d,4).
    test_comp(e,5):- unk(something).
    test_comp(e,5):- unk(something_else).

The rows of Table [2.2](#table:janus-py-comp){reference-type="ref"
reference="table:janus-py-comp"}

-   jns.comp() (no truth_vals) tests iterations of

        jns.comp('jns_test','table_comp',vars=2,truth_vals=jns.NO_TRUTHVALS)

-   jns.comp() (default) tests iterations of

        jns.comp('jns_test','table_comp',vars=2)

-   jns.comp() (delay lists) tests iterations of

        jns.comp('jns_test','table_comp',vars=2,truth_vals=jns.DELAY_LISTS)

[]{#table:janus-py-comp label="table:janus-py-comp"}

::: centering
::: {#table:janus-py-comp}
  ------------ ----------------- ---------
  `jns.comp`   (no truth_vals)     106,000
  `jns.comp`   (default)            99,000
  `jns.comp`   (delay lists)        91,000
  ------------ ----------------- ---------

  : Performance of `jns.comp()` under various options
:::
:::

### Tests of Data Throughput

Finally, the rows of
Table[2.3](#table:janus-py-throughput){reference-type="ref"
reference="table:janus-py-throughput"} provide the number of elements in
a list of integers that can be transferred from Prolog to Python per
second in various contexts. For the predicate

    backtrack_through_list(Size,Elt):-
        makelist(Size,List),
        member(Elt,List).

-   The row "backtrack through a list with `jns.apply()`' gives the
    number of list elements per second that can be returned by iterating
    through

        jns.apply('jns_test','backtrack_through_list',1000000)

-   The row "backtrack through a list with `jns.query()`' gives the
    number of list elements per second that can be returned by iterating
    though

        jns.query('jns_test:backtrack_through_list(1000000,Elt)')

-   And finally, the row "return a large list in a single call " tests
    the size of a list that can be returned in one second from the
    function

        jns.apply_once('jns_test','prolog_makelist',N)    

    where `prolog_makelist(N,List)` creates a list of size `N` and
    unifies it with `List`.

[]{#table:janus-py-throughput label="table:janus-py-throughput"}

::: centering
::: {#table:janus-py-throughput}
  --------------------------------------------- -----------
  backtrack through a list with `jns.apply()`       782,000
  backtrack through a list with `jns.query()`       672,000
  return a large list in a single call            9,091,000
  --------------------------------------------- -----------

  : Passing a list from XSB to Python: list elements per second
:::
:::

### Discussion

Finally, the directory `$XSB_ROOT/xsbtests/janus_tests` contains the
'script `memtest.py` that can be run to provide benchmark times for on a
given platform. The script includes a variety of benchmarks.
Importantly, `jns_bench.py` also uses the Python ` guppy.heapy` module
to examine whether executing millions of `janus-py` calls creates any
memory leaks in Python. Running the script on recent version of Python
show that `janus-py` calling and `janus` data transfer creates virtually
no memory leaks for Python. TES: need to recheck this.

## Current Issues and Limitations {#sec:jns-py-limits}

-   `janus-py` has not currently work on Windows.

-   XSB's heap garbage collection is currently disabled when XSB is
    called from Python, although expansion is allowed for all stacks.

-   In the current version of `janus-py` the Python session that calls
    `janus-py` must not be itself embedded in another process.

[^1]: The `xsbpy` and `px` packages were partly funded by BBN
    Technologies. An earlier version of `janus` is also supported by
    Arriba Prolog. The documentation in this chapter and the next is
    based mostly on previous `xsbpy` and `px` documentation but also
    includes some material originally written for SWI.

[^2]: *In Python, attributes/keys may only contain mixtures of integers,
    strings and tuples.*

[^3]: These integers can be obtained by querying
    `current_prolog_flag/2`.

[^4]: In XSB this is a term of the form `pyObj(Ref)` or `pyIter(Ref)`
    where `Ref` is a Prolog atom depicting the actual reference to a
    Python object. However, other implementations of `janus` use other
    conventions.

[^5]: Testing has been done of the interfaces, but the testing has not
    been exhaustive. As a result, please double-check any results, and
    report bugs -- and especially improvements -- to
    ` xsb.sorceforge.net`.

[^6]: The examples ` jns_fasttext` and `googleTrans` were written by
    Albert Ki; `jns_faiss` was written by Albert Ki and Theresa Swift.

[^7]: At least I think that's how it works\...

[^8]: The format `ttl` is allowed as a substitute for `turtle`, and
    `ntriples` for `nt`.

[^9]: Available at ` https://www.rdfhdt.org/datasets`.

[^10]: Qnode identifiers are automatically expanded to URLs.

[^11]: Its for reasons like this that this section is named `starters`
    rather than ` perefctly_finished_interfaces` -- `jns_wd` cuts
    through some of the brush, but not all of it. And don't get me
    started on why some of the classes are reified.

[^12]: In Linux, this means that the process has a large virtual memory
    size, but its resident set size is low.

[^13]: This has already been done by one company that uses XSB.

[^14]: `janus` correctly handles default keyword arguments, but the
    Python C API does not seem to support default positional arguments.

[^15]: `https://pypi.org/project/xmltodict`

[^16]: See Section [2.5](#sec:jns-py-limits){reference-type="ref"
    reference="sec:jns-py-limits"} for a list of currently unsupported
    features and known bugs.

[^17]: `janus-py` has been tested on Ubuntu v. 18 and v. 20, and on
    Fedora 35; and Python versions 3.7-3.11 have been tested. We believe
    that `janus-py` will work on other recent Unix distributions and
    newer Python versions as well.

[^18]: This activation file updates the `LD_LIBRARY_PATH` used by the
    `ld` command, and adds the `janus` directory to `PYTHONPATH`. On
    macOS ` LD_LIBRARY_PATH` is also updated.

[^19]: *Note that ` pp_jns_query()` does not change the Python command
    line interface -- it simply prints out the query and the answer both
    in Prolog syntax.*

[^20]: *A future implementation may use more precise mapping of XSB
    error types to Python error types.*

[^21]: *Of course `jns.apply_once()` can always pass back multiple
    argument values via Python tuples or other means.*

[^22]: *See Volume 1 Chapter 5 of this manual for an explanation of the
    Well-Founded Model and XSB's three-valued logic.*

[^23]: *In practice, the truth value `Undefined` sometimes actually
    means unknown. See Volume 1 Chapter 5 of this manual for an
    explanation of the Well-Founded Model along with some of the ways
    the third truth value can be exploited in programming.*

[^24]: *As shown in
    Example [\[ex:jns-comp-undef\]](#ex:jns-comp-undef){reference-type="ref"
    reference="ex:jns-comp-undef"}, truth values can also be represented
    by delay lists in list and set comprehensions.*

[^25]: *Due to how sets are implemented in Python, the order in which
    the set elements are returned is non-deterministic.*

[^26]: *Code for this is contained in the file `jns_clpr.P`.*

[^27]: The reason for making lists the default collection type is that
    Python sets can only contain non-mutable objects, and so cannot
    contain lists or dictionaries.

[^28]: On-demand loading, available in Prolog, is not yet available
    within `janus-py`.

[^29]: Timings were performed on a 2019 MacBookPro16 laptop, with a 2.6
    GHz 6-Core Intel Core i7. Python 3.11 and the XSB sourceforge
    version of November 2023 were used. All benchmark tests are
    available in ` $XSB_ROOT/xsbbtests/janus_tests/janus_py_benches.py`
