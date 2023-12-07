

# Contents

  - [Predicate py_func/3, py_func/4](#predicate-pyfunc3-pyfunc4)
  - [Predicate py_dot/3, py_dot/4, py_dot/5](#predicate-pydot3-pydot4-pydot5)
  - [Predicate py_setattr/3](#predicate-pysetattr3)
  - [Predicate py_iter/2, py_iter/3](#predicate-pyiter2-pyiter3)
  - [Predicate py_call/1, py_call/2, py_call/3](#predicate-pycall1-pycall2-pycall3)
  - [Predicate py_free/1](#predicate-pyfree1)
  - [Predicate py_pp/1, py_pp/2, py_pp/3](#predicate-pypp1-pypp2-pypp3)
  - [Predicate py_add_lib_dir/1, py_add_lib_dir/2](#predicate-pyaddlibdir1-pyaddlibdir2)
  - [Predicate py_lib_dirs/1](#predicate-pylibdirs1)
  - [Predicate values/3](#predicate-values3)
  - [Predicate py_is_object/1](#predicate-pyisobject1)
  - [Predicate items/2, key/2, keys/2](#predicate-items2-key2-keys2)
  - [Python function cmd](#python-function-cmd)
  - [Python function apply_once](#python-function-applyonce)
  - [Python function query_once](#python-function-queryonce)
  - [Python function apply](#python-function-apply)
  - [Python function query](#python-function-query)
  - [Python function consult, ensure_loaded](#python-function-consult-ensureloaded)

## Predicate py_func/3, py_func/4

### XSB version

  - **py_func**(+Module, +Function, ?Return)<br>
  - **py_func**(+Module, +Function, ?Return, +Options)<br>
Ensures that the Python module `Module` is loaded, and calls
` Module.Function` unifying the return of `Function` with ` Return`. As
in Python, the arguments of `Function` may contain keywords but
positional arguments must occur before keywords. For example the goal

    py_func(jns_rdflib,rdflib_write_file(Triples,'out.ttl',format=turtle),Ret).

calls the Python function `jns_rdflib.rdflib_write_file()` to write
`Triples`, a list of triples in Prolog format, to the file
`new_sample.ttl` using the RDF `turtle` format.

In general, `Module` must be the name of a Python module or path
represented as a Prolog atom. Python built-in functions can be called
using the “pseudo-module” `builtins`, for instance

`py_func(builtins, float(’+1E6’),F).`

produces the expected result:

`F = 1000000.0`

If `Module` has not already been loaded, it will be automatically loaded
during the call. Python modules are searched for in the paths maintained
in Python’s `sys.path` list and these Python paths can be queried from
Prolog via ` py_lib_dir/1` and modified via `py_add_lib_dir/1`.

`Function` is the invocation of a Python function in `Module`, where
`Function` is a compound Prolog structure in which arguments with the
outer functor `=/2` are treated as Python keyword arguments.

Currently supported options are:

- `py_object(true)` This option returns most Python data structures as
  object references, so that attributes of the data structures can be
  queried if needed. The only data returned *not* as an object reference
  are

  - Objects of `boolean` type

  - Objects of `none` type

  - Objects of exactly the class `long`, `float` or ` string`. Objects
    that are proper subclasses of these types are returned as object
    references.

**Error Cases**

- `py_func/4` is called with an uninstantiated option list

  - `instantiation_error`

- The option list `py_func/4` contains an improper element, or
  combination of elements.

  - `domain_error`

- `Module` is not a Prolog atom:

  - `type_error`

- `Module` cannot be found in the current Python search paths:

  - `existence_error`

- `Function` is not a callable term

  - `type_error`

- `Function` does not correspond to a Python function in `Module`

  - `existence_error`

- When translating an argument of function:

  - A set (`py_set/1`) term has an argument that is not a list

    - `type_error`

  - The list in a set term (`py_set/1` contains a non-hashable term

    - `type_error`

  - A dictionary (`/1`) term has an argument that is not a comma-list

    - `type_error`

  - An element of a dictionary comma-list is not of the form ` :/2` or
    the structure contains a non-hashable key (first argument)

    - `type_error`

  - An argument of `Function` is otherwise non-translatable to Python

    - `misc_error`

In addition, errors thrown by Python are caught by XSB and re-thrown as
`misc_error` errors.

### SWI-Prolog version

  - **py_func**(+Module, +Function, -Return)<br>
  - **py_func**(+Module, +Function, -Return, +Options)<br>
    Call Python `Function` in `Module`. The SWI-Prolog implementation is
    equivalent to `py_call(Module:Function, Return)`. See
    `py_call/2` for details.

      - Compatibility
        PIP. See `py_call/2` for notes. Note that, as this
        implementation is based on `py_call/2`, `Function`
        can use *chaining*, e.g., `py_func(sys, path:append(dir),
        Return)` is accepted by this implementation, but not portable.

## Predicate py_dot/3, py_dot/4, py_dot/5

### XSB version

  - **py_dot**(+ObjRef, +MethAttr, ?Ret, +Prolog_Opts)<br>
  - **py_dot**(+ObjRef, +MethAttr, ?Ret)<br>
Applies a method to `ObjRef` or obtains an attribute value for `ObjRef`.
As with `py_func/[3,4]`, `ObjRef` is a Python object reference in term
form or a Python module. A Python object reference may be returned by
various calls, such as initializing an instance of a class: [^4]

- If `MethAttr` is a Prolog compound term corresponding to a Python
  method for `ObjRef`, the method is called and its return unified with
  `Ret`.

- If `MethAttr` is a Prolog atom corresponding to the name of an
  attribute of `ObjRef`, the attribute value (for `ObjRef`) is accessed
  and unified with `Ret`.

Both the Prolog options (`Prolog_Opts`) and the handling of Python paths
is as with `py_func/[3,4]`.

**Error Cases**

- `py_dot/4` is called with an uninstantiated option list

  - `instantiation_error`

- The option list `py_dot/4` contains an improper element, or
  combination of elements.

  - `domain_error`

- `Obj` is not a Prolog atom or Python object reference

  - `type_error`

- `MethAttr` is not a callable term or atom.

  - `type_error`

- `MethAttr` does not correspond to a Python method or attribute for
  `PyObj`

  - `misc_error`

- If an error occurs when translating an argument of ` MethAttr` to
  Python the actions are as described for ` py_func/[3,4]`.

In addition, errors thrown by Python are caught by XSB and re-thrown as
`misc_error` errors.

### SWI-Prolog version

  - **py_dot**(+Module, +ObjRef, +MethAttr, -Ret)<br>
  - **py_dot**(+Module, +ObjRef, +MethAttr, -Ret, +Options)<br>
    Call a method or access an attribute on the object `ObjRef`. The
    SWI-Prolog implementation is equivalent to `py_call(ObjRef:MethAttr,
    Return)`. See `py_call/2` for details.

    |          |                                                       |
    | -------- | ----------------------------------------------------- |
    | `Module` | is ignored (why do we need that if we have `ObjRef`?) |


      - Compatibility
        PIP. See `py_func/3` for details.

## Predicate py_setattr/3

### XSB version

  - **py_setattr**(+ModObj, +Attr, +Val)<br>
If `ModObj` is a module or an object, this command is equivalent to the
Python

`ModObj.Attr = Val`.

**Error Cases**

- `Obj` is not a Prolog atom or Python object reference

  - `type_error`

- `MethAttr` is not an atom.

  - `type_error`

- If an error occurs when translating an argument of ` MethAttr` to
  Python the actions are as described for ` py_func/[3,4]`.

### SWI-Prolog version

  - **py_setattr**(+Target, +Name, +Value)<br>
    Set a Python attribute on an object. If `Target` is an atom, it is
    interpreted as a module. Otherwise it is normally an object
    reference. `py_setattr/3` allows for *chaining* and
    behaves as if defined as

    ``` code
    py_setattr(Target, Name, Value) :-
        py_call(Target, Obj, [py_object(true)]),
        py_call(setattr(Obj, Name, Value)).
    ```

      - Compatibility
        PIP

## Predicate py_iter/2, py_iter/3

### XSB version

  - **py_iter**(+ModObj, +FuncMethAttr, -Ret)<br>
`py_iter/2` takes as input to its first argument either a module in
which the function `FuncMethAttr` will be called; or a Python object
reference to which either the method `FuncMethAttr` will be applied or
the attribute `FuncMethAttr` will be accessed. Just as with
`py_func/[3,4]` and `py_dot/[3,4]` the arguments of `FuncMethAttr` may
contain keywords, but positional arguments must occur before keywords.
However, if the Python function, method or attribute returns an iterator
object `Obj`, the iterator for ` Obj` will be accessed and values of the
iterator will be returned via backtracking (cf.
Example <a href="#jns-examp:lazy-ret" data-reference-type="ref"
data-reference="jns-examp:lazy-ret">1.6</a>).

If the size of a return from Python is expected to be very large, say
over 1MB or so the use of `py_iter()` is recommended.

**Error Cases**

Error cases are similar to `py_func/[3,4]` if `ModObj` is a module, and
to `py_obj` if `ModObj` is a Python object reference.

### SWI-Prolog version

  - **py_iter**(+Iterator, -Value)<br>
  - **py_iter**(+Iterator, -Value, +Options)<br>
    True when `Value` is returned by the Python `Iterator`. Python
    iterators may be used to implement non-deterministic foreign
    predicates. The implementation uses these steps:

    1.  Evaluate `Iterator` as `py_call/2` evaluates its
        first argument, except the `Obj:Attr = Value` construct is not
        accepted.
    2.  Call `__iter__` on the result to get the iterator itself.
    3.  Get the `__next__` function of the iterator.
    4.  Loop over the return values of the *next* function. If the
        Python return value unifies with `Value`, succeed with a
        choicepoint. Abort on Python or unification exceptions.
    5.  Re-satisfaction continues at (4).

    The example below uses the built-in iterator `range()`:

    ``` code
    ?- py_iter(range(1,3), X).
    X = 1 ;
    X = 2.
    ```

    Note that the implementation performs a *look ahead*, i.e., after
    successful unification it calls‘__next__()\` again. On failure
    the Prolog predicate succeeds deterministically. On success, the
    next candidate is stored.

    Note that a Python *generator* is a Python *iterator*. Therefore,
    given the Python generator expression below, we can use
    `py_iter(squares(1,5),X)` to generate the squares on backtracking.

    ``` code
    def squares(start, stop):
         for i in range(start, stop):
             yield i * i
    ```

    |           |                                                |
    | --------- | ---------------------------------------------- |
    | `Options` | is processed as with `py_call/3`. |


      - Compatibility
        PIP. The same remarks as for `py_call/2` apply.
      - bug
        `Iterator` may not depend on janus.`query()`, i.e., it is not
        possible to iterate over a Python iterator that under the hoods
        relies on a Prolog non-deterministic predicate.

## Predicate py_call/1, py_call/2, py_call/3

### XSB version

  - **py_call**(+Form, -Ret, +Opts)<br>
  - **py_call**(+Form, -Ret)<br>
`py_call/[2,3]` is alternate syntax for `py_func/[3,4]` and
`py_dot/[3,4]`. Or perhaps it is the other way around.

`py_call(Mod:Func,Ret,Opts)`

emulates `py_func(Mod,Func,Ret,Opts)`, while

`py_call(Obj:Func,Ret,Opts)`

emulates `py_dot(Obj,Func,Ret,Opts)`. Within ` py_call/[2,3]` function
composition can be performed via the use of the `eval/1` term and via
nested use of `:/2` as indicated in
Example <a href="#jns-examp:pycall" data-reference-type="ref"
data-reference="jns-examp:pycall">1.7</a>.

Options and Error cases are the same as for `py_func/[3,4]` and
`py_dot/[3,4]`.

### SWI-Prolog version

  - **py_call**(+Call)<br>
  - **py_call**(+Call, -Return)<br>
  - **py_call**(+Call, -Return, +Options)<br>
    `Call` Python and return the result of the called function. `Call`
    has the shape‘\[Target\]\[:Action\]\*\`, where `Target` is either a
    Python module name or a Python object reference. Each `Action` is
    either an atom to get the denoted attribute from current `Target` or
    it is a compound term where the first argument is the function or
    method name and the arguments provide the parameters to the Python
    function. On success, the returned Python object is translated to
    Prolog. `Action` without a `Target` denotes a buit-in function.

    Arguments to Python functions use the Python conventions. Both
    *positional* and *keyword* arguments are supported. Keyword
    arguments are written as `Name = Value` and must appear after the
    positional arguments.

    Below are some examples.

    ``` code
    % call a built-in
    ?- py_call(print("Hello World!\n")).
    true.

    % call a built-in (alternative)
    ?- py_call(builtins:print("Hello World!\n")).
    true.

    % call function in a module
    ?- py_call(sys:getsizeof([1,2,3]), Size).
    Size = 80.

    % call function on an attribute of a module
    ?- py_call(sys:path:append("/home/bob/janus")).
    true

    % get attribute from a module
    ?- py_call(sys:path, Path)
    Path = ["dir1", "dir2", ...]
    ```

    Given a class in a file `dog.py` such as the following example from
    the Python documentation

    ``` code
    class Dog:
        tricks = []

        def __init__(self, name):
            self.name = name

        def add_trick(self, trick):
            self.tricks.append(trick)
    ```

    We can interact with this class as below. Note that `$Doc` in the
    SWI-Prolog toplevel refers to the last toplevel binding for the
    variable `Dog`.

    ``` code
    ?- py_call(dog:'Dog'("Fido"), Dog).
    Dog = <py_Dog>(0x7f095c9d02e0).

    ?- py_call($Dog:add_trick("roll_over")).
    Dog = <py_Dog>(0x7f095c9d02e0).

    ?- py_call($Dog:tricks, Tricks).
    Dog = <py_Dog>(0x7f095c9d02e0),
    Tricks = ["roll_over"]
    ```

    If the principal term of the first argument is not `Target:Func`,
    The argument is evaluated as the initial target, i.e., it must be an
    object reference or a module. For example:

    ``` code
    ?- py_call(dog:'Dog'("Fido"), Dog),
       py_call(Dog, X).
       Dog = X, X = <py_Dog>(0x7fa8cbd12050).
    ?- py_call(sys, S).
       S = <py_module>(0x7fa8cd582390).
    ```

    `Options` processed:

      - **py_object**(`Boolean`)
        If `true` (default `false`), translate the return as a Python
        object reference. Some objects are *always* translated to
        Prolog, regardless of this flag. These are the Python constants
        `None`, `True` and `False` as well as instances of the Python
        base classes `int`, `float`, `str` or `tuple`. Instances of sub
        classes of these base classes are controlled by this option.
      - **py_string_as**(`+Type`)
        If `Type` is `atom` (default), translate a Python String into a
        Prolog atom. If `Type` is `string`, translate into a Prolog
        string. Strings are more efficient if they are short lived.
      - **py_dict_as**(`+Type`)
        One of `dict` (default) to map a Python dict to a SWI-Prolog
        dict if all keys can be represented. If `{}` or not all keys can
        be represented, `Return` is unified to a term `{k:v, ...}` or
        `py({})` if the Python dict is empty.

    <!-- end list -->

      - Compatibility
        PIP. The options `py_string_as` and `py_dict_as` are SWI-Prolog
        specific, where SWI-Prolog Janus represents Python strings as
        atoms as required by the PIP and it represents Python dicts by
        default as SWI-Prolog dicts. The predicates
        `values/3`, `keys/2`, etc. provide portable
        access to the data in the dict.

## Predicate py_free/1

### XSB version

  - **py_free**(+ObjRef)<br>
In general when `janus` bi-translates between Python objects and Prolog
terms it performs a copy: this has the advantage that each system can
perform its own memory management independently of the other. The
exception is when a reference to a Python object is passed to XSB. In
this case, Python must explicitly be told that the Python object can be
reclaimed, and this is done through ` py_free/1`.

**Error Cases**

- `ObjRef` is not a Python object reference. (Only a syntax check is
  performed, so no determination is made that `ObjRef` is a *valid*
  Python object reference

  - `type_error`

### SWI-Prolog version

  - **py_free**(+Obj)<br>
    Immediately free (decrement the reference count) for the Python
    object `Obj`. Further reference to `Obj` using e.g.,
    `py_call/2` or `py_free/1` raises an
    `existence_error`. Note that by decrementing the reference count, we
    make the reference invalid from Prolog. This may not actually delete
    the object because the object may have references inside Python.

    Prolog references to Python objects are subject to atom garbage
    collection and thus normally do not need to be freed explicitly.

      - Compatibility
        PIP. The SWI-Prolog implementation is safe and normally
        reclaiming Python object can be left to the garbage collector.
        Portable applications may not assume garbage collection of
        Python objects and must ensure to call `py_free/1`
        exactly once on any Python object reference. Not calling
        `py_free/1` leaks the Python object. Calling it
        twice may lead to undefined behavior.

  - <span class="pred-tag">\[semidet\]</span><span id="py_with_gil/1">**py_with_gil**(`:Goal`)</span>
    Run `Goal` as `once(Goal)` while holding the Phyton GIL (*Global
    Interpreter Lock*). Note that all predicates that interact with
    Python lock the GIL. This predicate is only required if we wish to
    make multiple calls to Python while keeping the GIL. The GIL is a
    *recursive* lock and thus calling `py_call/1`,2 while
    holding the GIL does not *deadlock*.

## Predicate py_pp/1, py_pp/2, py_pp/3

### XSB version

  - **py_pp**(+Stream, +Term, +Options)<br>
  - **py_pp**(+Stream, +Term)<br>
  - **py_pp**(+Term)<br>
Pretty prints a `janus` Python term. By default, the term is translated
to Python and makes use of Python’s `pprint.pformat()`, which produces a
string that is then returned to Prolog and written out. If the option
`prolog_pp(true)` is given, the term is pretty printed directly in
Prolog. As an example

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

Such pretty printing can be useful for developing applications such as
with `jns_elastic`, the `janus` Elasticsearch interface which
communicates with Elasticsearch via (sometimes large) JSON terms.

### SWI-Prolog version

  - **py_pp**(+Term)<br>
  - **py_pp**(+Term, +Options)<br>
  - **py_pp**(+Stream, +Term, +Options)<br>
    Pretty prints the Prolog translation of a Python data structure in
    Python syntax. This exploits `pformat()` from the Python module
    `pprint` to do the actual formatting. `Options` is translated into
    keyword arguments passed to pprint.`pformat()`. In addition, the
    option `nl(Bool)` is processed. When `true` (default), we use
    pprint.`pp()`, which makes the output followed by a newline. For
    example:

    ``` code
    ?- py_pp(py{a:1, l:[1,2,3], size:1000000},
             [underscore_numbers(true)]).
    {'a': 1, 'l': [1, 2, 3], 'size': 1_000_000}
    ```

      - Compatibility
        PIP

## Predicate py_add_lib_dir/1, py_add_lib_dir/2

### XSB version

  - **py_add_lib_dir**(+Path, +FirstLast)<br>
  - **py_add_lib_dir**(+Path)<br>
The convenience and compatibility predicate `py_add_lib_dir/2` allows
the user to add a path to the end of `sys.path` (if ` FirstLast = last`
or the beginning (if `FirstLast = fiast`. `py_add_lib_dir/1` acts as
`py_add_lib_dir/2` where ` FirstLast = last`.

When adding to the end `sys.path` this predicate acts similarly to XSB’s
`add_lib_dir/1`, which adds Prolog library directories.

### SWI-Prolog version

  - **py_add_lib_dir**(+Dir)<br>
  - **py_add_lib_dir**(+Dir, +Where)<br>
    Add a directory to the Python module search path. In the second
    form, `Where` is one of `first` or `last`.
    `py_add_lib_dir/1` adds the directory as
    `last`. The property `sys:path` is not modified if it already
    contains `Dir`.

    `Dir` is in Prolog notation. The added directory is converted to an
    absolute path using the OS notation using
    <span class="pred-ext">prolog_to_os_filename/2</span>.

    If `Dir` is a *relative* path, it is taken relative to Prolog source
    file when used as a *directive* and relative to the process working
    directory when called as a predicate.

      - Compatibility
        PIP. Note that SWI-Prolog uses POSIX file conventions
        internally, mapping to OS conventions inside the predicates that
        deal with files or explicitly using
        <span class="pred-ext">prolog_to_os_filename/2</span>. Other
        systems may use the native file conventions in Prolog.

## Predicate py_lib_dirs/1

### XSB version

  - **py_lib_dirs**(?Path)<br>
This convenience and compatibility predicate returns the current Python
library directories as a Prolog list.

### SWI-Prolog version

  - **py_lib_dirs**(-Dirs)<br>
    True when `Dirs` is a list of directories searched for Python
    modules. The elements of `Dirs` are in Prolog canonical notation.

      - Compatibility
        PIP

## Predicate values/3

### XSB version

  - **values**(+Dict, +Path, ?Val)<br>
Convenience predicate and compatibility to obtain a value from a
(possibly nested) Prolog dictionary. The goal

`values(D,key1,V)`

is equivalent to the Python expression `D[key1]` while

`values(D,[key1,key2,key3],V)` v is equivalent to the Python expression

`D[key1][key2][key3]`

There are no error conditions associated with this predicate.

### SWI-Prolog version

  - **values**(+Dict, +Path, ?Val)<br>
    Get the value associated with `Dict` at `Path`. `Path` is either a
    single key or a list of keys.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

## Predicate py_is_object/1

### XSB version

  - **py_is_object**(+Obj)<br>
Succeeds if `Obj` is a Python object reference and fails otherwise.
Different Prologs that implement Janus will have different
representations of Python objects, so this predicate should be used to
determine whether a term is a Python Object.

### SWI-Prolog version

  - **py_is_object**(@Term)<br>
    True when `Term` is a Python object reference. Fails silently if
    `Term` is any other Prolog term.

      - Errors
        `existence_error(py_object, Term)` is raised of `Term` is a
        Python object, but it has been freed using
        `py_free/1`.
      - Compatibility
        PIP. The SWI-Prolog implementation is safe in the sense that an
        arbitrary term cannot be confused with a Python object and a
        reliable error is generated if the references has been freed.
        Portable applications can not rely on this.

## Predicate items/2, key/2, keys/2

### XSB version

  - **keys**(+Dict, ?Keys)<br>
  - **key**(+Dict, ?Keys)<br>
  - **items**(+Dict, ?Items)<br>
Convenience predicates (for the inveterate Python programmer) to obtain
a list of keys or items from a Prolog dictionary. There are no error
conditions associated with these predicates.

The predicate `key/2` returns each key of a dictionary on backtracking,
rather than returning all keys as one list, as in `keys/2`.

### SWI-Prolog version

  - **keys**(+Dict, ?Keys)<br>
    True when `Keys` is a list of keys that appear in `Dict`.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - **key**(+Dict, ?Key)<br>
    True when `Key` is a key in `Dict`. Backtracking enumerates all
    known keys.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - **items**(+Dict, ?Items)<br>
    True when `Items` is a list of Key:Value that appear in `Dict`.

      - Compatibility
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

## Python function cmd

### XSB version

  - `` **cmd**(`module, pred, *args`)<br>
Allows Python to execute a Prolog goal `Goal` containing no variables.
Each argument in `Goal` corresponds to an element in `args`, i.e., the
input is translated to $module.pred(\overrightarrow{args})$, where
$\overrightarrow{args}$ is an argument vector. For instance the Python
call

`jns.cmd(’consult’,’ensure_loaded’,’jns_test’)`

calls `consult:ensure_loaded(jns_test)`. When `janus` is used with XSB,
calls to Prolog predicates that are not in a module may be made with
`module` set to `usermod`. (Also cf. Example
<a href="#ex:variadic-examples" data-reference-type="ref"
data-reference="ex:variadic-examples">2.5</a> and Example
<a href="#ex:jns-cmd" data-reference-type="ref"
data-reference="ex:jns-cmd">2.3</a>.)

In normal execution, `jns.cmd()` returns the truth value of the goal as
explained in
Section <a href="#sec:using-januspy" data-reference-type="ref"
data-reference="sec:using-januspy">2.2</a>. If an error occurred during
Prolog execution an Python error is set and the value `None` is
returned.

### SWI-Prolog version

  - `Truth` **cmd**(`module, predicate, *input`)<br>
    Similar to [janus.apply_once()](#janus.apply_once\(\)), but no
    argument for the return value is added. This function returns the
    *truth value* using the same conventions as the `truth` key in
    [janus.query_once()](#janus.query_once\(\)). For example:

    ``` code
    >>> import janus_swi as janus
    >>> cmd("user", "true")
    True
    >>> cmd("user", "current_prolog_flag", "bounded", "true")
    False
    >>> cmd("user", "undefined")
    Undefined
    >>> cmd("user", "no_such_predicate")
    Traceback (most recent call last):
      File "/usr/lib/python3.10/code.py", line 90, in runcode
        exec(code, self.locals)
      File "<console>", line 1, in <module>
    janus.PrologError: '$c_call_prolog'/0: Unknown procedure: no_such_predicate/0
    ```

    The function [janus.query_once()](#janus.query_once\(\)) is more
    flexible and provides all functionality of
    [janus.cmd()](#janus.cmd\(\)). However, this function is faster and
    in some scenarios easier to use.

      - Compatibility
        PIP.

## Python function apply_once

### XSB version

  - `` **apply_once**(`module, pred, *args, **kwargs`)<br>
Allows Python to execute a Prolog query, the last argument of which is a
variable. Unlike with `jns.apply()` the query should be deterimistic:
otherwise only the query’s first answer is returned. If the number of
`args` is `n`, a call will be made to `module:pred/(n+1)` in which the
first `n` arguments correspond to the arguments in `args` and the
binding of the final argument is returned to Python as a Python object,
i.e. a call $module.pred(\overrightarrow{args},Ret)$ is created, where
the binding of $Ret$ is returned. For example: the call

`jns.apply_once(’basics’,’reverse’,[1,2,3,``’a’:``’b’:’c’``]))`

executes the Prolog goal

‘`basics.reverse([1,2,3,``’a’:``’b’:’c’``],Ret)`

and passes back

`[``’a’:``’b’:’c’``,3,2,1]`

to Python. (Also cf.
Example <a href="#ex:variadic-examples" data-reference-type="ref"
data-reference="ex:variadic-examples">2.5</a> for examples of using a
varying number of arguments.)

`jns.apply_once()` is designed to be very fast, so it does not return a
truth value. If the keyword binding ` truth_vals=jns.PLAIN_TRUTHVALS` is
used, the function returns a return dictionary containing both the
return and its truth value, (cf.
Example <a href="#ex:truth-vals" data-reference-type="ref"
data-reference="ex:truth-vals">2.7</a>).

### SWI-Prolog version

  - `Any` **apply_once**(`module, predicate, *input, fail=obj`)<br>
    *Functional notation* style calling of a deterministic Prolog
    predicate. This calls `module:predicate(Input ... , Output)`, where
    `Input` are the Python `input` arguments converted to Prolog. On
    success, `Output` is converted to Python and returned. On failure a
    [janus.PrologError()](#janus.PrologError\(\)) exception is raised
    unless the `fail` parameter is specified. In the latter case the
    function returns `obj`. This interface provides a comfortable and
    fast calling convention for calling a simple predicate with suitable
    calling conventions. The example below returns the *home directory*
    of the SWI-Prolog installation.

    ``` code
    >>> import janus_swi as janus
    >>> janus.apply_once("user", "current_prolog_flag", "home")
    '/home/janw/src/swipl-devel/build.pdf/home'
    ```

      - Compatibility
        PIP.

## Python function query_once

### XSB version

  - `` **query_once**(`query_string, **kwargs`)<br>
Calls the Prolog goal `query_string` which must be a well-formed Prolog
atom `Atom` or `Module:Atom` where ` Module` is a Prolog module name.
(No ending period should be a part of `query_string`.) As discussed in
Example <a href="#ex:query-once" data-reference-type="ref"
data-reference="ex:query-once">2.6</a>, `query_string` is parsed by
Prolog. If there is a dictionary *Dict* associated with an ` inputs`
keyword argument, then for any logical variable $V_i$ in `query_string`
and Python data structure $A_i$ such that $V_i:A_i$ is an item in
*Dict*, $A_i$ is translated to a Prolog term and unified with $V_i$. All
other logical variables in ` query_string` are taken to be
(uninstantiated) output variables. Upon the success of `query_string`
their bindings are represented in the return dictionary, which also by
default contains the truth value of the answer to `query_string`.

`kwargs` allows the following types of keyword arguments.

- `truth_vals` determines whether and how each answer in the collection
  is associated with its truth value. (Cf.
  Example <a href="#ex:truth-vals" data-reference-type="ref"
  data-reference="ex:truth-vals">2.7</a> for examples of how the
  ` truth_vals` options affects returns.)

  Values can be:

  - `PLAIN_TRUTHVALS` which associates each answer with its truth value
    *true* (represented as `True` or *undefined* represented as
    ` jns.Undefined`. (Unlike `jns.cmd()` *false* answers are never
    returned.) This is the default behavior for `jns.query_once()` and
    ` jns.query()`. along with `jns.comp()`.

  - `DELAY_LISTS` which associates each answer with its SLG delay list.
    (See Example <a href="#ex:truth-vals" data-reference-type="ref"
    data-reference="ex:truth-vals">2.7</a> for more information on this
    option; or for background on delay lists, the chapter *Using Tabling
    in XSB: A Tutorial Introduction* in Volume 1 of this manual.)

  - `NO_TRUTHVALS` does not associate an answer with any truth value.
    This option is the default for ` jns.apply_once` and `jns.apply()`.
    This option should only be used in situations where it is know that
    no answers will be *undefined*.

- `Inputs` which contains input bindings (in Python syntax) to one or
  more logical variables in ` jns.query_string` as explained in
  Example <a href="#ex:query-once" data-reference-type="ref"
  data-reference="ex:query-once">2.6</a>.

### SWI-Prolog version

  - `dict` **query_once**(`query, bindings={}, keep=False, truth_vals=TruthVals.PLAIN_TRUTHVALS`)<br>
    Call `query` using `bindings` as
    <span id="idx:once1:16"></span><span class="pred-ext">once/1</span>,
    returning a dict with the resulting bindings. If `bindings` is
    omitted, no variables are bound. The `keep` parameter determines
    whether or not Prolog discards all backtrackable changes. By
    default, such changes are discarded and as a result, changes to
    backtrackable global variables are lost. Using `True`, such changes
    are preserved.

    ``` code
    >>> query_once("b_setval(a, 1)", keep=True)
    {'truth': 'True'}
    >>> query_once("b_getval(a, X)")
    {'truth': 'True', 'X': 1}
    ```

    If `query` fails, the variables of the query are bound to the Python
    constant `None`. The `bindings` object includes a key
    `truth`<sup>6<span class="fn-text">As this name is not a valid
    Prolog variable name, this cannot be ambiguous.</span></sup> that
    has the value `False` (query failed, all bindings are `None`),
    `True` (query succeeded, variables are bound to the result
    converting Prolog data to Python) or an instance of the class
    [janus.Undefined()](#janus.Undefined\(\)). The information carried
    by this instance is determined by the `truth` parameter. Below is an
    example. See [section 5.4](#sec:5.4) for details.

    ``` code
    >>> import janus_swi as janus
    >>> janus.query_once("undefined")
    {'truth': Undefined}
    ```

    See also [janus.cmd()](#janus.cmd\(\)) and
    [janus.apply_once()](#janus.apply_once\(\)), which provide a fast
    but more limited alternative for making ground queries
    ([janus.cmd()](#janus.cmd\(\))) or queries with leading ground
    arguments followed by a single output variable.

      - Compatibility
        PIP.

## Python function apply

### XSB version

  - `` **apply**(`module, pred, *args`)<br>
`jns.apply()` is called in the same manner as ` jns.apply_once()` but
creates an instance of an iterator class that is used to backtrack
through all solutions to the constructed goal. The Prolog goal invoked
is automatically closed after iterating through all solutions, or when
an explicit `jns.close_query()` is called. See
Section <a href="#sec:var-nd" data-reference-type="ref"
data-reference="sec:var-nd">2.2.2.1</a> for examples of its use.

### SWI-Prolog version

  - `apply` **apply**(`module, predicate, *input`)<br>
    As [janus.apply_once()](#janus.apply_once\(\)), returning an
    *iterator* that returns individual answers. The example below uses
    Python *list comprehension* to create a list of integers from the
    Prolog built-in
    <span id="idx:between3:19"></span><span class="pred-ext">between/3</span>.

    ``` code
    >>> [*janus.apply("user", "between", 1, 6)]
    [1, 2, 3, 4, 5, 6]
    ```

      - Compatibility
        PIP.

  - <span id="janus.apply.next()">`any|None`
    **janus.apply.next**(`  `)</span>
    Explicitly ask for the next solution of the iterator. Normally,
    using the `apply` as an iterator is to be preferred. See discussion
    above. Note that this calling convention cannot distinguish between
    the Prolog predicate returning `@none` and reaching the end of the
    iteration.

  - <span id="janus.apply.close()">`None`
    **janus.apply.close**(`  `)</span>
    Close the query. Closing a query is obligatory. When used as an
    iterator, the Python destructor (**__del__()**) takes care of
    closing the query.

      - Compatibility
        PIP.

## Python function query

### XSB version

  - `` **query**(`query_string, **kwargs`)<br>
The string-based `jns.query()` is called in the same manner as
`jns.query_once()` but creates an instance of an iterator class that is
used to backtrack through all solutions to the constructed goal. The
Prolog goal invoked is automatically closed after iterating through all
solutions, or when an explicit `jns.close_query()` is called. See
Section <a href="#sec:nd-query" data-reference-type="ref"
data-reference="sec:nd-query">2.2.2.2</a> for examples of its use.

### SWI-Prolog version

  - `query` **query**(`query, bindings={}, keep=False`)<br>
    As [janus.query_once()](#janus.query_once\(\)), returning an
    *iterator* that provides an answer dict as
    [janus.query_once()](#janus.query_once\(\)) for each answer to
    `query`. Answers never have `truth` `False`. See discussion above.
      - Compatibility
        PIP. The `keep` is a SWI-Prolog extension.
  - <span id="janus.Query()">`Query` **janus.Query**(`query,
    bindings={}, keep=False`)</span>
    *Deprecated*. This class was renamed to
    [janus.query(.)](#janus.query\(\))
  - <span id="janus.query.next()">`dict|None`
    **janus.query.next**(`  `)</span>
    Explicitly ask for the next solution of the iterator. Normally,
    using the `query` as an iterator is to be preferred. See discussion
    above.
  - <span id="janus.query.close()">`None`
    **janus.query.close**(`  `)</span>
    Close the query. Closing a query is obligatory. When used as an
    iterator, the Python destructor (**__del__()**) takes care of
    closing the query.
      - Compatibility
        PIP.

## Python function consult, ensure_loaded

### XSB version

  - `` **consult**(`file`)<br>
  - `` **ensure_loaded**(`file`)<br>
Convenience functions for loading and/or compiling Prolog files. In XSB,
they are defined as

`jns.cmd(’consult’,’consult’,File)`

and

`jns.cmd(’consult’,’ensure_loaded’,File)`.[^28]

Note that a given Prolog file can be compiled and/or loaded into the
running Python-Prolog session (via `consult()` or ` ensure_loaded()`),
edited and then repeatedly recompiled and reloaded without problems.

### SWI-Prolog version

  - `None` **consult**(`file, data=None, module='user'`)<br>
    Load Prolog text into the Prolog database. By default, `data` is
    `None` and the text is read from `file`. If `data` is a string, it
    provides the Prolog text that is loaded and `file` is used as
    *identifier* for source locations and error messages. The `module`
    argument denotes the target module. That is where the clauses are
    added to if the Prolog text does not define a module or where the
    exported predicates of the module are imported into.

    If `data` is not provided and `file` is not accessible this raises a
    Prolog exception. Errors that occur during the compilation are
    printed using
    <span id="idx:printmessage2:17"></span><span class="pred-ext">print_message/2</span>
    and can currently not be captured easily. The script below prints
    the train connections as a list of Python tuples.

    ``` code
        import janus_swi as janus

        janus.consult("trains", """
        train('Amsterdam', 'Haarlem').
        train('Amsterdam', 'Schiphol').
        """)

        print([d['Tuple'] for d in
               janus.query("train(_From,_To),Tuple=_From-_To")])

    ```

      - Compatibility
        PIP. The `data` and `module` keyword arguments are SWI-Prolog
        extensions.