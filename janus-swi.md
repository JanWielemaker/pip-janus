<div class="title">

SWI-Prolog Python interface

</div>

<div class="author">

Jan Wielemaker  
SWI-Prolog Solutions b.v.  
E-mail: <jan@swi-prolog.org>

</div>

<div class="abstract">

<div class="abstract-title">

Abstract

</div>

This package implements a bi-directional interface between Prolog and
Python using portable low-level primitives. The aim is to make Python
available to Prolog and visa versa with minimal installation effort
while providing a high level bi-directional interface with good
performance.

The API is being developed in close cooperation with the XSB and Ciao
teams as a pilot for the PIP (*Prolog Improvement Proposal*) initiative.
Janus should become the de-facto standard interface between Python and
Prolog.

</div>

# <span id="document-contents">Table of Contents</span>

<div class="toc">

<div class="toc-h2">

[<span class="sec-nr">1</span>
<span class="sec-title">Introduction</span>](#sec:1)

</div>

<div class="toc-h2">

[<span class="sec-nr">2</span> <span class="sec-title">Data
conversion</span>](#sec:2)

</div>

<div class="toc-h2">

[<span class="sec-nr">3</span> <span class="sec-title">Janus by
example</span>](#sec:3)

</div>

<div class="toc-h3">

[<span class="sec-nr">3.1</span> <span class="sec-title">Janus calling
spaCy</span>](#sec:3.1)

</div>

<div class="toc-h2">

[<span class="sec-nr">4</span> <span class="sec-title">library(janus):
Call Python from Prolog</span>](#sec:4)

</div>

<div class="toc-h3">

[<span class="sec-nr">4.1</span> <span class="sec-title">Handling Python
errors in Prolog</span>](#sec:4.1)

</div>

<div class="toc-h3">

[<span class="sec-nr">4.2</span> <span class="sec-title">Janus and
virtual environments (venv)</span>](#sec:4.2)

</div>

<div class="toc-h2">

[<span class="sec-nr">5</span> <span class="sec-title">Calling Prolog
from Python</span>](#sec:5)

</div>

<div class="toc-h3">

[<span class="sec-nr">5.1</span> <span class="sec-title">Janus iterator
query</span>](#sec:5.1)

</div>

<div class="toc-h3">

[<span class="sec-nr">5.2</span> <span class="sec-title">Janus iterator
apply</span>](#sec:5.2)

</div>

<div class="toc-h3">

[<span class="sec-nr">5.3</span> <span class="sec-title">Janus access to
Python locals and globals</span>](#sec:5.3)

</div>

<div class="toc-h3">

[<span class="sec-nr">5.4</span> <span class="sec-title">Janus and
Prolog truth</span>](#sec:5.4)

</div>

<div class="toc-h4">

[<span class="sec-nr">5.4.1</span> <span class="sec-title">Janus classed
Undefined and TruthVal</span>](#sec:5.4.1)

</div>

<div class="toc-h3">

[<span class="sec-nr">5.5</span> <span class="sec-title">Janus class
Term</span>](#sec:5.5)

</div>

<div class="toc-h3">

[<span class="sec-nr">5.6</span> <span class="sec-title">Janus class
PrologError</span>](#sec:5.6)

</div>

<div class="toc-h2">

[<span class="sec-nr">6</span> <span class="sec-title">Janus and
threads</span>](#sec:6)

</div>

<div class="toc-h3">

[<span class="sec-nr">6.1</span> <span class="sec-title">Calling Prolog
from a Python thread</span>](#sec:6.1)

</div>

<div class="toc-h3">

[<span class="sec-nr">6.2</span> <span class="sec-title">Python and
Prolog deadlocks</span>](#sec:6.2)

</div>

<div class="toc-h2">

[<span class="sec-nr">7</span> <span class="sec-title">Janus as a Python
package</span>](#sec:7)

</div>

<div class="toc-h2">

[<span class="sec-nr">8</span> <span class="sec-title">Prolog and
Python</span>](#sec:8)

</div>

<div class="toc-h2">

[<span class="sec-nr">9</span> <span class="sec-title">Janus performance
evaluation</span>](#sec:9)

</div>

<div class="toc-h2">

[<span class="sec-nr">10</span> <span class="sec-title">Python or C/C++
for accessing resources?</span>](#sec:10)

</div>

<div class="toc-h2">

[<span class="sec-nr">11</span> <span class="sec-title">Janus platforms
notes</span>](#sec:11)

</div>

<div class="toc-h3">

[<span class="sec-nr">11.1</span> <span class="sec-title">Janus on
Windows</span>](#sec:11.1)

</div>

<div class="toc-h3">

[<span class="sec-nr">11.2</span> <span class="sec-title">Janus on
Linux</span>](#sec:11.2)

</div>

<div class="toc-h3">

[<span class="sec-nr">11.3</span> <span class="sec-title">Janus on
MacOS</span>](#sec:11.3)

</div>

<div class="toc-h2">

[<span class="sec-nr">12</span> <span class="sec-title">Compatibility to
the XSB Janus implementation</span>](#sec:12)

</div>

<div class="toc-h3">

[<span class="sec-nr">12.1</span> <span class="sec-title">Writing
portable Janus modules</span>](#sec:12.1)

</div>

<div class="toc-h2">

[<span class="sec-nr">13</span> <span class="sec-title">Status of
Janus</span>](#sec:13)

</div>

</div>

## <span id="sec:1"><span class="sec-nr">1</span> <span class="sec-title">Introduction</span></span>

<span id="sec:janus-intro"></span>

Python has a huge developer community that maintains a large set of
resources, notably interfaces to just about anything one can imagine.
Making such interfaces directly available to Prolog can surely be done.
However, developing an interface typically requires programming in C or
C++, a skill that is not widely available everywhere. Being able to
access Python effortlessly from Prolog puts us in a much better position
because Python experience is widely available in our target audience.
This solution was proposed in [Andersen & Swift,
2023](#DBLP:series/lncs-0001S23), [Swift & Andersen,
2023](#DBLP:journals/corr/abs-2308-15893), initially developed for XSB.

Janus provides a bi-directional interface between Prolog and Python
using the low-level C API of both languages. This makes using Python
from Prolog as simple as taking the standard SWI-Prolog distribution and
loading library `library(janus)`. Using Prolog from Python is as simple
as `import janus_swi as janus` and start making calls. Both Prolog and
Python being dynamically typed languages, we can define an easy to use
interface that provides a *latency* of about one `μ`S.

The Python interface is modeled after the recent JavaScript interface
developed for the WASM (Web Assembly) version. That is

  - A di-directional data conversion is defined. See [section
    2](#sec:2).
  - A Prolog predicate
    <span id="idx:pycall2:1"></span>[py\_call/2](#py_call/2) to call
    Python functions and methods, as well as access and set object
    attributes.
  - A non-deterministic Prolog predicate
    <span id="idx:pyiter2:2"></span>[py\_iter/2](#py_iter/2) to
    enumerate a Python *iterator*.
  - A Python function [janus.query\_once()](#janus.query_once\(\)) to
    evaluate a Prolog query as
    <span id="idx:once1:3"></span><span class="pred-ext">once/1</span>,
    providing input to Prolog variables using a Python dict and return a
    Python dict with bindings for each Prolog output variable.
  - A python function [janus.apply\_once()](#janus.apply_once\(\)) to
    call a Prolog predicate with `N` *input arguments* followed by
    exactly one *output argument*. This provides a faster and easier to
    use interface to compliant predicates.
  - Python iterators [janus.query()](#janus.query\(\)) and
    [janus.apply()](#janus.apply\(\)) that provide access to
    non-deterministic Prolog predicates using the calling conventions of
    [janus.query\_once()](#janus.query_once\(\)) and
    [janus.apply\_once()](#janus.apply_once\(\)).

The API of Janus is the result of discussions between the SWI-Prolog,
XSB and Ciao lang teams. It will be reflected in a PIP (*Prolog
Improvement Proposal*). Considering the large differences in design an
opinions in Prolog implementation, the PIP does not cover all aspects of
the API. Many of the predicates and functions have a *Compatibility*
note that explains the relation of the SWI-Prolog API and the PIP. We
summarize the differences in [section 12](#sec:12).

## <span id="sec:2"><span class="sec-nr">2</span> <span class="sec-title">Data conversion</span></span>

<span id="sec:janus-data"></span>

The bi-directional conversion between Prolog and Python terms is
summarized in the table below. For compatibility with Prolog
implementations without native dicts we support converting the `{k1:v1,
k2:v2, ...}` to dicts. Note that `{k1:v1, k2:v2}` is syntactic sugar for
`{}(','(:(k1,v1), :(k2,v2)))`. We allow for embedding this in a
`py(Term)` such that, with `py` defined as *prefix operator*, `py{k1:v1,
k2:v2}` is both valid syntax as SWI-Prolog dict as as ISO Prolog
compliant term and both are translated into the same Python dict. Note
that `{}` translates to a Python string, while `py({})` translates into
an empty Python dict.

By default we translate Python strings into Prolog atoms. Given we
support strings, this is somewhat dubious. There are two reasons for
this choice. One is the pragmatic reason that Python uses strings both
for *identifiers* and arbitrary text. Ideally we'd have the first
translated to Prolog atoms and the latter to Prolog strings, but,
because we do not know which strings act as identifier and which as just
text, this is not possible. The second is to improve compatibility with
Prolog systems that do not support strings. Note that
<span id="idx:pycall3:4"></span>[py\_call/3](#py_call/3) and
<span id="idx:pyiter3:5"></span>[py\_iter/3](#py_iter/3) provide the
option `py_string_as(string)` to obtain a string if this is desirable.

|                |     |                                 |                                                                                                                          |
| -------------- | :-: | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **Prolog**     |     | **Python**                      | **Notes**                                                                                                                |
| Variable       | `⟶` | \-                              | (instantiation error)                                                                                                    |
| Integer        | `⟺` | int                             | Supports big integers                                                                                                    |
| Rational       | `⟺` | fractions.Fraction()            |                                                                                                                          |
| Float          | `⟺` | float                           |                                                                                                                          |
| @(none)        | `⟺` | None                            |                                                                                                                          |
| @(true)        | `⟺` | True                            |                                                                                                                          |
| @(false)       | `⟺` | False                           |                                                                                                                          |
| Atom           | `⟵` | **enum.Enum()**                 | Name of Enum instance                                                                                                    |
| Atom           | `⟷` | String                          |                                                                                                                          |
| String         | `⟶` | String                          |                                                                                                                          |
| \#(Term)       | `⟶` | String                          | *stringify* using <span id="idx:writecanonical1:6"></span><span class="pred-ext">write\_canonical/1</span> if not atomic |
| prolog(Term)   | `⟶` | [janus.Term()](#janus.Term\(\)) | Represents any Prolog term                                                                                               |
| Term           | `⟵` | [janus.Term()](#janus.Term\(\)) |                                                                                                                          |
| List           | `⟶` | List                            |                                                                                                                          |
| List           | `⟵` | Sequence                        |                                                                                                                          |
| List           | `⟵` | Iterator                        | Note that a Python *Generator* is an *Iterator*                                                                          |
| py\_set(List)  | `⟺` | Set                             |                                                                                                                          |
| \-()           | `⟺` | ()                              | Python empty Tuple                                                                                                       |
| \-(a,b, ... )  | `⟺` | (a,b, ... )                     | Python Tuples. Note that a Prolog *pair* `A-B` maps to a Python (binary) tuple.                                          |
| Dict           | `⟺` | Dict                            |                                                                                                                          |
| {k:v, ...}     | `⟺` | Dict                            | Compatibility when using `py_dict_as({}`)                                                                                |
| {k:v, ...}     | `⟹` | Dict                            | Compatibility (see above)                                                                                                |
| py({k:v, ...}) | `⟹` | Dict                            | Compatibility (see above)                                                                                                |
| eval(Term)     | `⟹` | Object                          | Evaluate Term as first argument of <span id="idx:pycall2:7"></span>[py\_call/2](#py_call/2)                              |
| `py_obj` blob  | `⟺` | Object                          | Used for any Python object not above                                                                                     |
| Compound       | `⟶` | \-                              | for any term not above (type error)                                                                                      |

The interface supports unbounded integers and rational numbers. Large
integers (`> 64` bits) are converted using a hexadecimal string as
intermediate. SWI-Prolog rational numbers are mapped to the Python class
**fractions:Fraction**.<sup>1<span class="fn-text">Currently, mapping
rational numbers to fractions uses a string as intermediate
representation and may thus be slow.</span></sup>

The conversion \#(Term) allows passing anything as a Python string. If
`Term` is an atom or string, this is the same as passing the atom or
string. Any other Prolog term is converted as defined by
<span id="idx:writecanonical1:8"></span><span class="pred-ext">write\_canonical/1</span>.
The conversion `prolog(Term)` creates an instance of
[janus.Term()](#janus.Term\(\)). This class encapsulates a copy of an
arbitrary Prolog term. The SWI-Prolog implementation uses the
**PL\_record()** and **PL\_recorded()** functions to store and retrieve
the term. `Term` may be any Prolog term, including *blobs*, *attributed
variables*. Cycles and subterm sharing in `Term` are preserved.
Internally, [janus.Term()](#janus.Term\(\)) is used to represent Prolog
exeptions that are raised during the execution of
[janus.query\_once()](#janus.query_once\(\)) or
[janus.query()](#janus.query\(\)).

Python Tuples are array-like objects and thus map best to a Prolog
compound term. There are two problems with this. One is that few systems
support compound terms with arity zero, e.g., `f` and many systems have
a limit on the *arity* of compound terms. Using Prolog *comma lists*,
e.g., `(a,b,c)` does not implement array semantics, cannot represent
empty tuples and cannot disambiguate tuples with one element from the
element itself. We settled with compound terms using the `-` as functor
to make the common binary tuple map to a Prolog *pair*.

## <span id="sec:3"><span class="sec-nr">3</span> <span class="sec-title">Janus by example</span></span>

<span id="sec:janus-examples"></span>

This section introduces Janus calling Python from Prolog with examples.

### <span id="sec:3.1"><span class="sec-nr">3.1</span> <span class="sec-title">Janus calling spaCy</span></span>

<span id="sec:janus-spacy"></span>

The [spaCy](https://spacy.io/) package provides natural language
processing. This section illustrates the Janus library using spaCy.
Typically, spaCy and the English language models may be installed using

``` code
> pip install spacy
> python -m spacy download en
```

After spaCy is installed, we can define model/1 to represent a Python
object for the English language model using the code below. Note that by
tabling this code as shared, the model is loaded only once and is
accessible from multiple Prolog threads.

``` code
:- table english/1 as shared.

english(NLP) :-
    py_call(spacy:load(en_core_web_sm), NLP).
```

Calling `english(X)` results in `X` = `<py_English>(0x7f703c24f430)`, a
*blob* that references a Python object. *English* is the name of the
Python class to which the object belongs and *0x7f703c24f430* is the
address of the object. The returned object implements the Python
*callable* protocol, i.e., it behaves as a function with additional
properties and methods. Calling the model with a string results in a
parsed document. We can use this from Prolog using the built-in
`__call__` method:

``` code
?- english(NLP),
   py_call(NLP:'__call__'("This is a sentence."), Doc).
NLP = <py_English>(0x7f703851b8e0),
Doc = [<py_Token>(0x7f70375be9d0), <py_Token>(0x7f70375be930),
       <py_Token>(0x7f70387f8860), <py_Token>(0x7f70376dde40),
       <py_Token>(0x7f70376de200)
      ].
```

This is not what we want. Because the spaCy `Doc` class implements the
*sequence* protocol it is translated into a Prolog list of spaCy `Token`
instances. The `Doc` class implements many more methods that we may wish
to use. An example is `noun_chunks`, which provides a Python *generator*
that enumerates the noun chunks found in the input. Each chunk is an
instance of `Span`, a sequence of `Token` instances that have the
property `text`. The program below extracts the noun chunks of the input
as a non-deterministic Prolog predicate. Note that we use
`py_object(true)` to get the parsed document as a Python object. Next,
we use <span id="idx:pyiter2:9"></span>[py\_iter/2](#py_iter/2) to
access the members of the Python *iterator* returned by
`Doc.noun_chunks` as Python object references and finally we extract the
text of each noun chunk as an atom. The SWI-Prolog (atom) garbage
collector will take care of the `Doc` and `Span` Python objects.
Immediate release of these objects can be enforced using
<span id="idx:pyfree1:10"></span>[py\_free/1](#py_free/1).<sup>2<span class="fn-text">Janus
implementations are not required to implement Python object reference
garbage collection.</span></sup>

``` code
:- use_module(library(janus)).

:- table english/1.

english(NLP) :-
    py_call(spacy:load(en_core_web_sm),NLP).

noun(Sentence, Noun) :-
    english(NLP),
    py_call(NLP:'__call__'(Sentence), Doc, [py_object(true)]),
    py_iter(Doc:noun_chunks, Span, [py_object]),
    py_call(Span:text, Noun).
```

After which we can call

``` code
?- noun("This is a sentence.", Noun).
Noun = 'This' ;
Noun = 'a sentence'.
```

The subsequent [section 4](#sec:4) documents the Prolog library
`library(janus)`.

## <span id="sec:4"><span class="sec-nr">4</span> <span class="sec-title">library(janus): Call Python from Prolog</span></span>

<span id="sec:janus"></span>

This library implements calling Python from Prolog. It is available
directly from Prolog if the janus package is bundled. The library
provides access to an *embedded* Python instance. If SWI-Prolog is
embedded into Python using the Python package `janus-swi`, this library
is provided either from Prolog or from the Python package.

Normally, the Prolog user can simply start calling Python using
[py\_call/2](#py_call/2) or friends. In special cases it may be needed
to initialize Python with options using
[py\_initialize/3](#py_initialize/3) and optionally the Python search
path may be extended using [py\_add\_lib\_dir/1](#py_add_lib_dir/1).

  - <span class="pred-tag">\[det\]</span><span id="py_version/0">**py\_version**</span>  
    Print version info on the embedded Python installation based on
    Python `sys.version`. If a Python *virtual environment* (venv) is
    active, indicate this with the location of this environment found.

  - <span class="pred-tag">\[det\]</span><span id="py_call/1">**py\_call**(`+Call`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_call/2">**py\_call**(`+Call,
    -Return`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_call/3">**py\_call**(`+Call,
    -Return, +Options`)</span>  
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
    
      - **py\_object**(`Boolean`)  
        If `true` (default `false`), translate the return as a Python
        object reference. Some objects are *always* translated to
        Prolog, regardless of this flag. These are the Python constants
        `None`, `True` and `False` as well as instances of the Python
        base classes `int`, `float`, `str` or `tuple`. Instances of sub
        classes of these base classes are controlled by this option.
      - **py\_string\_as**(`+Type`)  
        If `Type` is `atom` (default), translate a Python String into a
        Prolog atom. If `Type` is `string`, translate into a Prolog
        string. Strings are more efficient if they are short lived.
      - **py\_dict\_as**(`+Type`)  
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
        [values/3](#values/3), [keys/2](#keys/2), etc. provide portable
        access to the data in the dict.

  - <span class="pred-tag">\[nondet\]</span><span id="py_iter/2">**py\_iter**(`+Iterator,
    -Value`)</span>  
    <span class="pred-tag">\[nondet\]</span><span id="py_iter/3">**py\_iter**(`+Iterator,
    -Value, +Options`)</span>  
    True when `Value` is returned by the Python `Iterator`. Python
    iterators may be used to implement non-deterministic foreign
    predicates. The implementation uses these steps:
    
    1.  Evaluate `Iterator` as [py\_call/2](#py_call/2) evaluates its
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
    successful unification it calls‘\_\_next\_\_()\` again. On failure
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
    | `Options` | is processed as with [py\_call/3](#py_call/3). |
    

      - Compatibility  
        PIP. The same remarks as for [py\_call/2](#py_call/2) apply.
      - bug  
        `Iterator` may not depend on janus.`query()`, i.e., it is not
        possible to iterate over a Python iterator that under the hoods
        relies on a Prolog non-deterministic predicate.

  - <span class="pred-tag">\[det\]</span><span id="py_setattr/3">**py\_setattr**(`+Target,
    +Name, +Value`)</span>  
    Set a Python attribute on an object. If `Target` is an atom, it is
    interpreted as a module. Otherwise it is normally an object
    reference. [py\_setattr/3](#py_setattr/3) allows for *chaining* and
    behaves as if defined as
    
    ``` code
    py_setattr(Target, Name, Value) :-
        py_call(Target, Obj, [py_object(true)]),
        py_call(setattr(Obj, Name, Value)).
    ```
    
      - Compatibility  
        PIP

  - <span class="pred-tag">\[semidet\]</span><span id="py_is_object/1">**py\_is\_object**(`@Term`)</span>  
    True when `Term` is a Python object reference. Fails silently if
    `Term` is any other Prolog term.
    
      - Errors  
        `existence_error(py_object, Term)` is raised of `Term` is a
        Python object, but it has been freed using
        [py\_free/1](#py_free/1).
      - Compatibility  
        PIP. The SWI-Prolog implementation is safe in the sense that an
        arbitrary term cannot be confused with a Python object and a
        reliable error is generated if the references has been freed.
        Portable applications can not rely on this.

  - <span class="pred-tag">\[semidet\]</span><span id="py_is_dict/1">**py\_is\_dict**(`@Term`)</span>  
    True if `Term` is a Prolog term that represents a Python dict.
    
      - Compatibility  
        PIP. The SWI-Prolog version accepts both a SWI-Prolog dict as
        the `\`{k:v,`\`ldots`\`} representation. See `py_dict_as` option
        of [py\_call/2](#py_call/2).

  - <span class="pred-tag">\[det\]</span><span id="py_free/1">**py\_free**(`+Obj`)</span>  
    Immediately free (decrement the reference count) for the Python
    object `Obj`. Further reference to `Obj` using e.g.,
    [py\_call/2](#py_call/2) or [py\_free/1](#py_free/1) raises an
    `existence_error`. Note that by decrementing the reference count, we
    make the reference invalid from Prolog. This may not actually delete
    the object because the object may have references inside Python.
    
    Prolog references to Python objects are subject to atom garbage
    collection and thus normally do not need to be freed explicitly.
    
      - Compatibility  
        PIP. The SWI-Prolog implementation is safe and normally
        reclaiming Python object can be left to the garbage collector.
        Portable applications may not assume garbage collection of
        Python objects and must ensure to call [py\_free/1](#py_free/1)
        exactly once on any Python object reference. Not calling
        [py\_free/1](#py_free/1) leaks the Python object. Calling it
        twice may lead to undefined behavior.

  - <span class="pred-tag">\[semidet\]</span><span id="py_with_gil/1">**py\_with\_gil**(`:Goal`)</span>  
    Run `Goal` as `once(Goal)` while holding the Phyton GIL (*Global
    Interpreter Lock*). Note that all predicates that interact with
    Python lock the GIL. This predicate is only required if we wish to
    make multiple calls to Python while keeping the GIL. The GIL is a
    *recursive* lock and thus calling [py\_call/1](#py_call/1),2 while
    holding the GIL does not *deadlock*.

  - <span class="pred-tag">\[semidet\]</span><span id="py_gil_owner/1">**py\_gil\_owner**(`-Thread`)</span>  
    True when the Python GIL is owned by `Thread`. Note that, unless
    `Thread` is the calling thread, this merely samples the current
    state and may thus no longer be true when the predicate succeeds.
    This predicate is intended to help diagnose *deadlock* problems.
    
    Note that this predicate returns the Prolog threads that locked the
    GIL. It is however possible that Python releases the GIL, for
    example if it performs a blocking call. In this scenario, some other
    thread or no thread may hold the gil.

  - <span class="pred-tag">\[det\]</span><span id="py_func/3">**py\_func**(`+Module,
    +Function, -Return`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_func/4">**py\_func**(`+Module,
    +Function, -Return, +Options`)</span>  
    Call Python `Function` in `Module`. The SWI-Prolog implementation is
    equivalent to `py_call(Module:Function, Return)`. See
    [py\_call/2](#py_call/2) for details.
    
      - Compatibility  
        PIP. See [py\_call/2](#py_call/2) for notes. Note that, as this
        implementation is based on [py\_call/2](#py_call/2), `Function`
        can use changing, e.g., `py_func(sys, path:append(dir), Return)`
        is accepted by this implementation, but not portable.

  - <span class="pred-tag">\[det\]</span><span id="py_dot/4">**py\_dot**(`+Module,
    +ObjRef, +MethAttr, -Ret`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_dot/5">**py\_dot**(`+Module,
    +ObjRef, +MethAttr, -Ret, +Options`)</span>  
    Call a method or access an attribute on the object `ObjRef`. The
    SWI-Prolog implementation is equivalent to `py_call(ObjRef:MethAttr,
    Return)`. See [py\_call/2](#py_call/2) for details.
    
    |          |                                                       |
    | -------- | ----------------------------------------------------- |
    | `Module` | is ignored (why do we need that if we have `ObjRef`?) |
    

      - Compatibility  
        PIP. See [py\_func/3](#py_func/3) for details.

  - <span class="pred-tag">\[semidet\]</span><span id="values/3">**values**(`+Dict,
    +Path, ?Val`)</span>  
    Get the value associated with `Dict` at `Path`. `Path` is either a
    single key or a list of keys.
    
      - Compatibility  
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - <span class="pred-tag">\[det\]</span><span id="keys/2">**keys**(`+Dict,
    ?Keys`)</span>  
    True when `Keys` is a list of keys that appear in `Dict`.
    
      - Compatibility  
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - <span class="pred-tag">\[nondet\]</span><span id="key/2">**key**(`+Dict,
    ?Key`)</span>  
    True when `Key` is a key in `Dict`. Backtracking enumerates all
    known keys.
    
      - Compatibility  
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - <span class="pred-tag">\[det\]</span><span id="items/2">**items**(`+Dict,
    ?Items`)</span>  
    True when `Items` is a list of Key:Value that appear in `Dict`.
    
      - Compatibility  
        PIP. Note that this predicate handle a SWI-Prolog dict, a {k:v,
        ...} term as well as py({k:v, ...}.

  - <span id="py_shell/0">**py\_shell**</span>  
    Start an interactive Python REPL loop using the embedded Python
    interpreter. The interpreter first imports `janus` as below.
    
    ``` code
    from janus import *
    ```
    
    So, we can do
    
    ``` code
    ?- py_shell.
    ...
    >>> query_once("writeln(X)", {"X":"Hello world"})
    Hello world
    {'truth': True}
    ```
    
    If possible, we enable command line editing using the GNU readline
    library.
    
    When used in an environment where Prolog does not use the file
    handles 0,1,2 for the standard streams, e.g., in `swipl-win`,
    Python's I/O is rebound to use Prolog's I/O. This includes Prolog's
    command line editor, resulting in a mixed history of Prolog and
    Pythin commands.

  - <span class="pred-tag">\[det\]</span><span id="py_pp/1">**py\_pp**(`+Term`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_pp/2">**py\_pp**(`+Term,
    +Options`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_pp/3">**py\_pp**(`+Stream,
    +Term, +Options`)</span>  
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

  - <span class="pred-tag">\[det\]</span><span id="py_obj_dir/2">**py\_obj\_dir**(`+ObjRef,
    -List`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_obj_dict/2">**py\_obj\_dict**(`+ObjRef,
    -Dict`)</span>  
    Examine attributes of an object. The predicate
    [py\_obj\_dir/2](#py_obj_dir/2) fetches the names of all attributes,
    while [py\_obj\_dict/2](#py_obj_dict/2) gets a dict with all
    attributes and their values.
    
      - Compatibility  
        PIP

  - <span class="pred-tag">\[det\]</span><span id="py_module/2">**py\_module**(`+Module:atom,
    +Source:string`)</span>  
    Load `Source` into the Python module `Module`. This is intended to
    be used together with the `string` *quasi quotation* that supports
    long strings in SWI-Prolog. For example:
    
    ``` code
    :- use_module(library(strings)).
    :- py_module(hello,
                 {|string||
                  | def say_hello_to(s):
                  |     print(f"hello {s}")
                  |}).
    ```
    
    Calling this predicate multiple times with the same `Module` and
    `Source` is a no-op. Called with a different source creates a new
    Python module that replaces the old in the global namespace.
    
      - Errors  
        `python_error(Type, Data, Stack)` is raised if Python raises an
        error.

  - <span class="pred-tag">\[det\]</span><span id="py_initialize/3">**py\_initialize**(`+Program,
    +Argv, +Options`)</span>  
    Initialize and configure the embedded Python system. If this
    predicate is not called before any other call to Python such as
    [py\_call/2](#py_call/2), it is called *lazily*, passing the Prolog
    executable as `Program`, the non-Prolog arguments as `Argv` and an
    empty `Options` list.
    
    Calling this predicate while the Python is already initialized is a
    no-op. This predicate is thread-safe, where the first call
    initializes Python.
    
    In addition to initializing the Python system, it
    
      - Adds the directory holding `janus.py` to the Python module
        search path.
      - If Prolog I/O is not connected to the file handles 0,1,2, it
        rebinds Python I/O to use the Prolog I/O.
    
    |           |                                                                                    |
    | --------- | ---------------------------------------------------------------------------------- |
    | `Options` | is currently ignored. It will be used to provide additional configuration options. |
    

  - <span class="pred-tag">\[det\]</span><span id="py_lib_dirs/1">**py\_lib\_dirs**(`-Dirs`)</span>  
    True when `Dirs` is a list of directories searched for Python
    modules. The elements of `Dirs` are in Prolog canonical notation.
    
      - Compatibility  
        PIP

  - <span class="pred-tag">\[det\]</span><span id="py_add_lib_dir/1">**py\_add\_lib\_dir**(`+Dir`)</span>  
    <span class="pred-tag">\[det\]</span><span id="py_add_lib_dir/2">**py\_add\_lib\_dir**(`+Dir,
    +Where`)</span>  
    Add a directory to the Python module search path. In the second
    form, `Where` is one of `first` or `last`.
    [py\_add\_lib\_dir/1](#py_add_lib_dir/1) adds the directory as
    first. The property `sys:path` is not modified if it already
    contains `Dir`.
    
    `Dir` is in Prolog notation. The added directory is converted to an
    absolute path using the OS notation.
    
    The form <span class="pred-ext">py\_add\_lib\_dir/0</span> may only
    be used as a *directive*, adding the directory from which the
    current Prolog source is loaded at the head of the Python search
    path. If [py\_add\_lib\_dir/1](#py_add_lib_dir/1) or
    [py\_add\_lib\_dir/2](#py_add_lib_dir/2) are used in a directive and
    the given directory is not absolute, it is resolved against the
    directory holding the current Prolog source.
    
      - Compatibility  
        PIP. PIP only describes
        [py\_add\_lib\_dir/1](#py_add_lib_dir/1).

### <span id="sec:4.1"><span class="sec-nr">4.1</span> <span class="sec-title">Handling Python errors in Prolog</span></span>

<span id="sec:janus-python-errors"></span>

If <span id="idx:pycall2:11"></span>[py\_call/2](#py_call/2) or one of
the other predicates that access Python causes Python to raise an
exception, this exception is translated into a Prolog exception of the
shape below. The library defines a rule for
<span id="idx:printmessage2:12"></span><span class="pred-ext">print\_message/2</span>
to render these errors in a human readable way.

> `error(python_error(ErrorType, Value, Stack)`, \_)

Here, `ErrorType` is the name of the error type, as an atom, e.g.,
`’TypeError'`. `Value` is the exception object represented by a Python
object reference. `Stack` is either `@none` or an object that captures
the Python stack. The `library(janus)` defines the message formatting,
which makes us end up with a message like below.

``` code
?- py_call(nomodule:noattr).
ERROR: Python 'ModuleNotFoundError':
ERROR:   No module named 'nomodule'
ERROR: In:
ERROR:   [10] janus:py_call(nomodule:noattr)
```

### <span id="sec:4.2"><span class="sec-nr">4.2</span> <span class="sec-title">Janus and virtual environments (venv)</span></span>

<span id="sec:janus-venv"></span>

An embedded Python system does not automatically pick up Python virtual
environments. It is supposed to setup its own environment. Janus is
sensitive to Python **venv** environments. Running under such as
environment is assumed if the environment variable `VIRTUAL_ENV` points
at a directory that holds a file `pyvenv.cfg`. If the virtual
environment is detected, the actions in the list below are
taken.<sup>3<span class="fn-text">This is based on observing how Python
3.10 on Linux responds to being used inside a virtual environment. We do
not know whether this covers all platforms and versions.</span></sup>

  - Initialize Python using the `-I` flag to indicate *isolation*.
  - Set `sys.prefix` to the value of the `VIRTUAL_ENV` environment
    variable.
  - Remove all directories with base name `site-packages` or
    `dist-packages` from `sys.path`.<sup>4<span class="fn-text">Note
    that `-I` only removes the personal packages directory, while the
    Python executable removes all, so we do the same.</span></sup>
  - Add `$VIRTUAL_ENV/lib/pythonX.Y/site-packages` to `sys.path`, where
    `X` and `Y` are the major and minor version numbers of the embedded
    Python library. If this directory does not exist we print a
    diagnostic warning.
  - Add a message to
    <span id="idx:pyversion0:13"></span>[py\_version/0](#py_version/0)
    that indicates we are using a virtual environment and from which
    directory.

## <span id="sec:5"><span class="sec-nr">5</span> <span class="sec-title">Calling Prolog from Python</span></span>

<span id="sec:janus-call-prolog"></span>

The Janus interface can also call Prolog from Python. Calling Prolog
from Python is the basis when embedding Prolog into Python using the
Python package `janus_swi`. However, calling Prolog from Python is also
used to handle *call backs*. Mutually recursive calls between Python and
Prolog are supported. They should be handled with some care as it is
easy to crash the process due to a stack overflow.

Loading janus into Python is realized using the Python package
`janus-swi`, which defines the module `janus_swi`. We do not call this
simply `janus` to allow coexistence of Janus for multiple Prolog
implementations. Unless you plan to interact with multiple Prolog
systems in the same session, we advice to import janus for SWI-Prolog as
below.

``` code
import janus_swi as janus
```

If Python is embedded into SWI-Prolog, the Python module may be imported
both as `janus` and `janus_swi`. Using `janus` allows the same Python
code to be used from different Prolog systems, while using `janus_swi`
allows the same code to be used both for embedding Python into Prolog
and Prolog into Python. In the remainder of this section we assume the
Janus functions are available in the name space `janus`.

The Python module `janus` provides utility functions and defines the
classes [janus.query()](#janus.query\(\)),
[janus.apply()](#janus.apply\(\)), [janus.Term()](#janus.Term\(\)),
[janus.Undefined()](#janus.Undefined\(\)) and
[janus.PrologError()](#janus.PrologError\(\)).

The Python calling Prolog interface consist of four primitives,
distinguishing deterministic vs. non-deterministic Prolog queries and
two different calling conventions which we name *functional notation*
and *relational notation*. The *relational* calling convention specifies
a Prolog query as a string with an *input dict* that provides (input)
bindings for part of the variables in the query string. The results are
represented as a dict that holds the bindings of the output variables
and the truth value (see [section 5.4](#sec:5.4)). For example:

``` code
>>> janus.query_once("Y is sqrt(X)", {'X':2})
{'truth': True, 'Y': 1.4142135623730951}
```

The functional notation calling convention specifies the query as a
module, predicate name and input arguments. It calls the predicate with
one argument more than the number of input arguments and translates the
binding of the output argument to Python. For example

``` code
>>> janus.apply_once("user", "plus", 1, 2)
3
```

The table below summarizes the four primitives.

|            |                                              |                                              |
| ---------: | :------------------------------------------: | :------------------------------------------: |
|            |           **Relational notation**            |           **Functional notation**            |
|    **det** | [janus.query\_once()](#janus.query_once\(\)) | [janus.apply\_once()](#janus.apply_once\(\)) |
| **nondet** |      [janus.query()](#janus.query\(\))       |      [janus.apply()](#janus.apply\(\))       |

We start our discussion by introducing the
[janus.query\_once(query,inputs)](#janus.query_once\(\)) function for
calling Prolog goals as
<span id="idx:once1:14"></span><span class="pred-ext">once/1</span>. A
Prolog goal is constructed from a string and a dict with *input
bindings* and returns *output bindings* as a dict. For example

``` code
>>> import janus_swi as janus
>>> janus.query_once("Y is X+1", {"X":1})
{'Y': 2, 'truth': True}
```

Note that the input argument may also be passed literally. Below we give
two examples. We **strongly advise against using string interpolation**
for three reasons. Firstly, the query strings are compiled and cached on
the Prolog sided and (thus) we assume a finite number of distinct query
strings. Secondly, string interpolation is sensitive to *injection
attacks*. Notably inserting quoted strings can easily be misused to
create malicious queries. Thirdly and finally, serializing and
deserializing the data is generally slower then using the input
dictionary, especially if the data is large. Using a dict for input and
output together with a (short) string to denote the goal is easy to use
and fast.

``` code
>>> janus.query_once("Y is 1+1", {})    # Ok for "static" queries
{'Y': 2, 'truth': True}
>>> x = 1
>>> janus.query_once(f"Y is {x}+1", {}) # WRONG, See above
{'Y': 2, 'truth': True}
```

The *output dict* contains all named Prolog variables that (1) are not
in the input dict and (2) do not start with an underscore. For example,
to get the grandparents of a person given
<span id="idx:parent2:15"></span><span class="pred-ext">parent/2</span>
relations we can use the code below, where the `_GP` and `_P` do not
appear in the output dict. This both saves time and avoids the need to
convert Prolog data structures that cannot be represented in Python such
as variables or arbitrary compound terms.

``` code
>>> janus.query_once("findall(_GP, parent(Me, _P), parent(_P, _GP), GPs)",
               {'Me':'Jan'})["GPs"]
[ 'Kees', 'Jan' ]
```

In addition to the variable bindings the dict contains a key
`truth`<sup>5<span class="fn-text">Note that variable bindings always
start with an uppercase latter.</span></sup> that represents the truth
value of evaluating the query. In normal Prolog this is a Python
Boolean. In systems that implement *Well Founded Semantics*, this may
also be an instance of the class
[janus.Undefined()](#janus.Undefined\(\)). See [section 5.4](#sec:5.4)
for details. If evaluation of the query failed, all variable bindings
are bound to the Python constant `None` and the `truth` key has the
value `False`. The following Python function returns `True` if the
Prolog system supports unbounded integers and `False` otherwise.

``` code
def hasBigIntegers():
    janus.query_once("current_prolog_flag(bounded,false)")['truth']
```

While [janus.query\_once()](#janus.query_once\(\)) deals with
semi-deterministic goals, the class [janus.query()](#janus.query\(\))
implements a Python *iterator* that iterates over the solutions of a
Prolog goal. The iterator may be aborted using the Python `break`
statement. As with [janus.query\_once()](#janus.query_once\(\)), the
returned dict contains a `truth` field. This field cannot be `False`
though and thus is either `True` or an instance of the class
[janus.Undefined()](#janus.Undefined\(\))

``` code
import janus_swi as janus

def printRange(from, to):
    for d in janus.query("between(F,T,X)", {"F":from, "T":to})
        print(d["X"])
```

Iterators may be nested. For example, we can create a list of tuples
like below.

``` code
def double_iter(w,h):
    tuples=[]
    for yd in janus.query("between(1,M,Y)", {"M":h}):
        for xd in janus.query("between(1,M,X)", {"M":w}):
            tuples.append((xd['X'],yd['Y']))
    return tuples
```

After this, we may run

``` code
>>> demo.double_iter(2,3)
[(1, 1), (2, 1), (1, 2), (2, 2), (1, 3), (2, 3)]
```

In addition to the *iterator* protocol that class
[janus.query()](#janus.query\(\)) implements, it also implements the
methods [janus.query.next()](#janus.query.next\(\)) and
[janus.query.close()](#janus.query.close\(\)). This allows for e.g.

``` code
    q = query("between(1,3,X)")
    while ( s := q.next() ):
        print(s['X'])
    q.close()
```

But, **iterators based on Prolog goals are fragile**. This is because,
while it is possible to open and run a new query while there is an open
query, the inner query must be closed before we can ask for the next
solution of the outer query. We illustrate this using the sequence
below.

``` code
>>> q1 = query("between(1,3,X)")
>>> q2 = query("between(1,3,X)")
>>> q2.next()
{'truth': True, 'X': 1}
>>> q1.next()
Traceback (most recent call last):
...
swipl.Error: swipl.next_solution(): not inner query
>>> q2.close()
>>> q1.next()
{'truth': True, 'X': 1}
>>> q1.close()
```

**Failure to close a query typically leaves SWI-Prolog in an
inconsistent state and further interaction with Prolog is likely to
crash the process**. Future versions may improve on that.

  - <span id="janus.query_once()">`dict` **janus.query\_once**(`query,
    bindings={}, keep=False,
    truth_vals=TruthVals.PLAIN_TRUTHVALS`)</span>  
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
    [janus.apply\_once()](#janus.apply_once\(\)), which provide a fast
    but more limited alternative for making ground queries
    ([janus.cmd()](#janus.cmd\(\))) or queries with leading ground
    arguments followed by a single output variable.
    
      - Compatibility  
        PIP.

  - <span id="janus.once()">`dict` **janus.once**(`query, bindings={},
    keep=False, truth_vals=TruthVals.PLAIN_TRUTHVALS`)</span>  
    *Deprecated*. Renamed to
    [janus.query\_once()](#janus.query_once\(\)).

  - <span id="janus.apply_once()">`Any` **janus.apply\_once**(`module,
    predicate, input ..., fail=obj`)</span>  
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

  - <span id="janus.cmd()">`Truth` **janus.cmd**(`module, predicate,
    input ...`)</span>  
    Similar to [janus.apply\_once()](#janus.apply_once\(\)), but no
    argument for the return value is added. This function returns the
    *truth value* using the same conventions as the `truth` key in
    [janus.query\_once()](#janus.query_once\(\)). For example:
    
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
    
    The function [janus.query\_once()](#janus.query_once\(\)) is more
    flexible and provides all functionality of
    [janus.cmd()](#janus.cmd\(\)). However, this function is faster and
    in some scenarios easier to use.
    
      - Compatibility  
        PIP.

  - <span id="janus.consult()">`None` **janus.consult**(`file,
    data=None, module='user'`)</span>  
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
    <span id="idx:printmessage2:17"></span><span class="pred-ext">print\_message/2</span>
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

  - <span id="janus.prolog()">`None` **janus.prolog**(`  `)</span>  
    Start the interactive Prolog toplevel. This is the Python equivalent
    of <span id="idx:pyshell0:18"></span>[py\_shell/0](#py_shell/0).

### <span id="sec:5.1"><span class="sec-nr">5.1</span> <span class="sec-title">Janus iterator query</span></span>

<span id="sec:janus-class-query"></span>

Class [janus.query()](#janus.query\(\)) is similar to the
[janus.query\_once()](#janus.query_once\(\)) function, but it returns a
Python *iterator* that allows for iterating over the answers to a
non-deterministic Prolog predicate.

  - <span id="janus.query()">`query` **janus.query**(`query,
    bindings={}, keep=False`)</span>  
    As [janus.query\_once()](#janus.query_once\(\)), returning an
    *iterator* that provides an answer dict as
    [janus.query\_once()](#janus.query_once\(\)) for each answer to
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
    iterator, the Python destructor (**\_\_del\_\_()**) takes care of
    closing the query.
      - Compatibility  
        PIP.

### <span id="sec:5.2"><span class="sec-nr">5.2</span> <span class="sec-title">Janus iterator apply</span></span>

<span id="sec:janus-class-apply"></span>

Class [janus.apply()](#janus.apply\(\)) is similar to
[janus.apply\_once()](#janus.apply_once\(\)), calling a Prolog predicate
using functional notation style. It returns a Python *iterator* that
enumerates all answers.

  - <span id="janus.apply()">`apply` **janus.apply**(`module, predicate,
    input ...`)</span>  
    As [janus.apply\_once()](#janus.apply_once\(\)), returning an
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
    iterator, the Python destructor (**\_\_del\_\_()**) takes care of
    closing the query.
    
      - Compatibility  
        PIP.

### <span id="sec:5.3"><span class="sec-nr">5.3</span> <span class="sec-title">Janus access to Python locals and globals</span></span>

<span id="sec:janus-locals-and-globals"></span>

Python provides access to dictionaries holding the local variables of a
function using **locals()** as well as the global variables stored as
attributes to the module to which the function belongs as **globals()**.
The Python C API provides **PyEval\_GetLocals()** and
**PyEval\_GetGlobals()**, but these return the scope of the Janus API
function rather than user code, i.e., the global variables of the
`janus` module and the local variables of the running Janus interface
function.

Python code that wishes Prolog to access its scope must pass the
necessary scope elements (local and global variables) explicitly to the
Prolog code. It is possible to pass the entire local and or global scope
by the output of **locals()** and/or **globals()**. Note however that a
dict passed to Prolog is translated to its Prolog representation. This
representation may be prohibitively large and does not allow Prolog to
modify variables in the scope. Note that Prolog can access the global
scope of a module as attributes of this module, e.g.

``` code
increment :-
    py_call(demo:counter, V0),
    V is V0+1,
    py_setattr(demo, counter, V).
```

### <span id="sec:5.4"><span class="sec-nr">5.4</span> <span class="sec-title">Janus and Prolog truth</span></span>

<span id="sec:janus-truth"></span>

In traditional Prolog, queries *succeed* or *fail*. Systems that
implement tabling with *Well Founded Semantics* such as XSB and
SWI-Prolog define a third truth value typically called *undefined*.
Undefined results may have two reasons; (1) the program is logically
inconsistent or (2) *restraints* have been applied in the derivation.

Because classical Prolog truth is dominant, we represent the success of
a query using the Python booleans `True` and `False`. For undefined
answers we define a class [janus.Undefined()](#janus.Undefined\(\)) that
may represent different levels of detail on why the result is undefined.
The notion of *generic undefined* is represented by a unique instance of
this class. The three truth values are accessible as properties of the
`janus` module.

  - **janus.true**  
    This property has the Python boolean `True`
  - **janus.false**  
    This property has the Python boolean `False`
  - **janus.undefined**  
    This property holds a unique instance of class
    [janus.Undefined()](#janus.Undefined\(\))

#### <span id="sec:5.4.1"><span class="sec-nr">5.4.1</span> <span class="sec-title">Janus classed Undefined and TruthVal</span></span>

<span id="sec:janus-class-undefined"></span>

The class [janus.Undefined()](#janus.Undefined\(\)) represents an
undefined result under the *Well Founded Semantics*.

  - <span id="janus.Undefined()">`Undefined`
    **janus.Undefined**(`term=None`)</span>  
    Instances are never created explicitly by the user. They are created
    by the calls to Prolog initiated from
    [janus.query\_once()](#janus.query_once\(\)) and
    [janus.query()](#janus.query\(\)).
    
    The class has a single property class `term` that represents either
    the *delay list* or the *residual program*. See
    [janus.TruthVal()](#janus.TruthVal\(\)) for details.

  - <span id="janus.TruthVal()">`Enum` **janus.TruthVal**(`  `)</span>  
    This class is a Python *enumeration*. Its values are passed as the
    optional `truth` parameter to
    [janus.query\_once()](#janus.query_once\(\)) and
    [janus.query()](#janus.query\(\)). The defined instances are
    
      - **NO\_TRUTHVALS**  
        Undefined results are reported as `True`. This is quite
        pointless in the current design and this may go.
      - **PLAIN\_TRUTHVALS**  
        Return undefined results as `janus.undefined`, a unique instance
        of the class [janus.Undefined()](#janus.Undefined\(\)).
      - **DELAY\_LISTS**  
        Return undefined results as an instance of class
        [janus.Undefined()](#janus.Undefined\(\)). thats holds the delay
        list in Prolog native representation. See
        <span id="idx:calldelays2:20"></span><span class="pred-ext">call\_delays/2</span>.
      - **RESIDUAL\_PROGRAM**  
        Return undefined results as an instance of class
        [janus.Undefined()](#janus.Undefined\(\)). thats holds the
        *residual program* in Prolog native representation. See
        <span id="idx:callresidualprogram2:21"></span><span class="pred-ext">call\_residual\_program/2</span>.
    
    The instances of this enumeration are available as attributed of the
    `janus` module.

For example, given Russel's paradox defined in Prolog as below.

``` code
:- module(russel, [shaves/2]).

:- table shaves/2.

shaves(barber,P) :- person(P),  tnot(shaves(P,P)).
person(barber).
person(mayor).
```

From Python, we may ask who shaves the barber in four ways as
illustrated below. Note that the Prolog representations for
`janus.DELAY_LISTS` and `janus.RESIDUAL_PROGRAM` use the
<span id="idx:writecanonical1:22"></span><span class="pred-ext">write\_canonical/1</span>
notation. They may later be changed to use a more human friendly
notation.

``` code
# Using NO_TRUTHVALS
>>> janus.query_once("russel:shaves(barber, X)", truth_vals=janus.NO_TRUTHVALS)
{'truth': True, 'X': 'barber'}

# Using default PLAIN_TRUTHVALS (default)
>>> janus.query_once("russel:shaves(barber, X)")
{'truth': Undefined, 'X': 'barber'}

# Using default DELAY_LISTS
>>> janus.query_once("russel:shaves(barber, X)", truth_vals=janus.DELAY_LISTS)
{'truth': :(russel,shaves(barber,barber)), 'X': 'barber'}

# Using default RESIDUAL_PROGRAM
>>> janus.query_once("russel:shaves(barber, X)", truth_vals=janus.RESIDUAL_PROGRAM)
{'truth': [:-(:(russel,shaves(barber,barber)),tnot(:(russel,shaves(barber,barber))))], 'X': 'barber'}
```

### <span id="sec:5.5"><span class="sec-nr">5.5</span> <span class="sec-title">Janus class Term</span></span>

<span id="sec:janus-class-term"></span>

Class [janus.Term()](#janus.Term\(\)) encapsulates a Prolog term.
Similarly to the Python object reference (see
<span id="idx:pyisobject1:23"></span>[py\_is\_object/1](#py_is_object/1)),
the class allows Python to represent arbitrary Prolog data, typically
with the intend to pass it back to Prolog.

  - <span id="janus.Term()">`Term` **janus.Term**(`...`)</span>  
    Instances are never created explicitly by the user. An instance is
    created by handling a term `prolog(Term)` to the data conversion
    process. As a result, we can do
    
    ``` code
    ?- py_call(janus:echo(prolog(hello(world))), Obj,
               [py_object(true)]).
    Obj = <py_Term>(0x7f7a14512050).
    ?- py_call(print($Obj)).
    hello(world)
    Obj = <py_Term>(0x7f7a14512050).
    ```

  - <span id="janus.Term.__str__()">`Term`
    **janus.Term.\_\_str\_\_**(`  `)</span>  
    Return the output of
    <span id="idx:print1:24"></span><span class="pred-ext">print/1</span>
    on the term. This is what is used by the Python function print().

  - <span id="janus.Term.__repr__()">`Term`
    **janus.Term.\_\_repr\_\_**(`  `)</span>  
    Return the output of
    <span id="idx:writecanonical1:25"></span><span class="pred-ext">write\_canonical/1</span>
    on the term.

### <span id="sec:5.6"><span class="sec-nr">5.6</span> <span class="sec-title">Janus class PrologError</span></span>

<span id="sec:janus-class-prolog-error"></span>

Class [janus.PrologError()](#janus.PrologError\(\)), derived from the
Python class **Exception** represents a Prolog exception that typically
results from calling [janus.query\_once()](#janus.query_once\(\)),
[janus.apply\_once()](#janus.apply_once\(\)),
[janus.query()](#janus.query\(\)) or [janus.apply()](#janus.apply\(\)).
The class either encapsulates a string on a Prolog exception term using
**janus.Term**. Prolog exceptions are used to represent errors raised by
Prolog. Strings are used to represent errors from invalid use of the
interface. The default behavior gives the expected message:

``` code
>>> x = janus.query_once("X is 3.14/0")['X']
Traceback (most recent call last):
  ...
janus.PrologError: //2: Arithmetic: evaluation error: `zero_divisor'
```

At this moment we only define a single Python class for representing
Prolog exceptions. This suffices for error reporting, but does not make
it easy to distinguish different Prolog errors. Future versions may
improve on that by either subclassing **janus.PrologError** or provide a
method to classify the error more easily.

  - <span id="janus.PrologError()">`PrologError`
    **janus.PrologError**(`TermOrString`)</span>  
    The constructor may be used explicitly, but this should be very
    uncommon.
  - <span id="janus.PrologError.__str__()">`String`
    **janus.PrologError.\_\_str\_\_**(`  `)</span>  
    Return a human readable message for the error using
    <span id="idx:messagetostring2:26"></span><span class="pred-ext">message\_to\_string/2</span>
  - <span id="janus.PrologError.__repr__()">`String`
    **janus.PrologError.\_\_repr\_\_**(`  `)</span>  
    Return a formal representation of the error by means of
    <span id="idx:writecanonical1:27"></span><span class="pred-ext">write\_canonical/1</span>.

## <span id="sec:6"><span class="sec-nr">6</span> <span class="sec-title">Janus and threads</span></span>

<span id="sec:janus-threads"></span>

Where SWI-Prolog support native preemptively scheduled threads that
exploit multiple cores, Python has a single interpreter that can switch
between native threads.<sup>7<span class="fn-text">Actually, you can
create multiple Python interpreters. It is not yet clear to us whether
that can help improving on concurrency.</span></sup> Initially the
Python interpreter is associated with the thread that created it which,
for janus, is the first thread calling Python. The Prolog thread that
initiated Janus may terminate. This does not affect the embedded Python
interpreter and this interpreter may continue to be used from other
Prolog threads.

Janus ensures it holds the Python GIL when interacting with the Python
interpreter. If Python calls Prolog, the GIL is released using
`Py_BEGIN_ALLOW_THREADS`.

  - Multiple Prolog threads can make calls to Python. The access to
    Python is *serialized*. If a Prolog thread does not want other
    threads to use Python it can use
    <span id="idx:pywithgil1:28"></span>[py\_with\_gil/1](#py_with_gil/1).
    When multiple Prolog threads make many calls to Python performance
    tends to drop significantly.
  - Multiple Python threads can make calls to Prolog. While Prolog is
    working on the query, the Python interpreter may switch to other
    Python threads.

### <span id="sec:6.1"><span class="sec-nr">6.1</span> <span class="sec-title">Calling Prolog from a Python thread</span></span>

<span id="sec:janus-thread-call-prolog"></span>

Prolog may be called safely from any Python thread. The Prolog execution
is embraced with `Py_BEGIN_ALLOW_THREADS` and `Py_END_ALLOW_THREADS`,
which implies that Python is allowed to switch to another thread while
Prolog is doing its work.

If the calling Python thread is not the one that initiated Janus,
[janus.query\_once()](#janus.query_once\(\)) and
[janus.query()](#janus.query\(\)) attach and detach a temporary Prolog
engine using **PL\_thread\_attach\_engine()** and
**PL\_thread\_destroy\_engine()**. This is relatively costly. In
addition we allow associating a Prolog engine persistently with the
calling thread.

  - <span id="janus.engine()">`int` **janus.engine**(`  `)</span>  
    Return the identifier of the Prolog engine associated to the current
    thread, -1 if no engine is attached or -2 if this version of Prolog
    does not support engines.

  - <span id="janus.attach_engine()">`int`
    **janus.attach\_engine**(`  `)</span>  
    Attach a Prolog engine to the current thread using
    **PL\_thread\_attach\_engine()**. On success, return the integer
    thread id of the created Prolog
    engine.<sup>8<span class="fn-text">The current implementation passes
    `NULL` to **PL\_thread\_attach\_engine()**. Future versions may
    provide access to the creation attributes.</span></sup>
    
    If the thread already has an engine the *attach count* is
    incremented and the current engine id is returned. The engine is
    detached after a matching number of calls to
    [janus.detach\_engine()](#janus.detach_engine\(\))

  - <span id="janus.detach_engine()">`None`
    **janus.detach\_engine**(`  `)</span>  
    Decrement the *attach count* of the attached Prolog engine. Destroy
    the engine if this count drops to zero. Raises an exception of the
    calling thread is not attached to a Prolog engine.

### <span id="sec:6.2"><span class="sec-nr">6.2</span> <span class="sec-title">Python and Prolog deadlocks</span></span>

<span id="sec:janus-deadlocks"></span>

In a threaded environment, Python calls must be guarded by
PyGILState\_Ensure() and PyGILState\_Release() that ultimately
lock/unlock a *mutex*. Unfortunately there is no PyGILState\_TryEnsure()
and therefore we may create deadlocks when Prolog locks are involved.
This may either apply to explicit Prolog locks from
<span id="idx:withmutex2:29"></span><span class="pred-ext">with\_mutex/2</span>
and friends or implicit locks on e.g. I/O streams. The classical
scenario is thread `A` holding the Python GIL and wanting to call Prolog
code that locks a mutex `M`, while thread `B` holds `M` and wishes to
make a Python call and this tries to lock the GIL. The predicate
<span id="idx:pygilowner1:30"></span>[py\_gil\_owner/1](#py_gil_owner/1)
can be used to help diagnosing such issues.

## <span id="sec:7"><span class="sec-nr">7</span> <span class="sec-title">Janus as a Python package</span></span>

<span id="sec:janus-python-package"></span>

The [Janus GIT repo](https://github.com/SWI-Prolog/packages-swipy)
provides `setup.py`. Janus may be installed as a Python package after
downloading using

``` code
pip install .
```

**pip** allows for installation from the git repository in a one-liner
as below.

``` code
pip install git+https://github.com/SWI-Prolog/packages-swipy.git#egg=janus_swi
```

Installing janus as a Python package requires

  - The **swipl** program in the default search path. The `setup.py`
    runs `swipl --dump-runtime-variables` to obtain the installation
    locations of the various Prolog components. On Windows, if **swipl**
    is not on `%PATH%`, `setup.py` tries the registry to find the
    default binary installation.
  - A C compiler that can be used by **pip**. The janus interface has
    been tested to compile using GCC, Clang and Microsoft Visual C++.

After successful installation we should be able to use Prolog directly
from Python. For example:

``` code
python
>>> from janus_swi import *
>>> query_once("writeln('Hello world!')")
Hello world!
{'truth': True}
>>> [a["D"] for a in query("between(1,6,D)")]
[1, 2, 3, 4, 5, 6]
>>> prolog()
?- version.
Welcome to SWI-Prolog (threaded, 64 bits, version 9.1.12-8-g70b70a968-DIRTY)
SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software.
...
?-
```

## <span id="sec:8"><span class="sec-nr">8</span> <span class="sec-title">Prolog and Python</span></span>

<span id="sec:janus-prolog-python"></span>

Prolog is a very different language than imperative languages. An
interesting similarity is the notion of *backtracking* vs. Python
*iterators*.

To be extended.

## <span id="sec:9"><span class="sec-nr">9</span> <span class="sec-title">Janus performance evaluation</span></span>

<span id="sec:janus-performance"></span>

Below is a table to give some feeling on the overhead of making calls
between Prolog and Python. These figures are roughly the same as the
figures for the XSB/Python interface. All benchmarks have been executed
on AMD3950X running Ubuntu 22.04, SWI-Prolog 9.1.11 and Python 3.10.6.

|                                                                   |                    |
| ----------------------------------------------------------------- | :----------------: |
| **Action**                                                        | **Time (seconds)** |
| Echo list with 1,000,000 elements                                 |        0.12        |
| Call Pyton `demo:int()` from Prolog 1,000,000 times               |        0.44        |
| Call Pyton `demo:sumlist3(5,[1,2,3])` from Prolog 1,000,000 times |        1.4         |
| Call Prolog `Y is X+1` from Python 1,000,000 times                |        1.9         |
| Iterate from Python over Prolog goal `between(1, 1 000 000,  X)`  |        1.1         |
| Iterate over Python iterator `range(1,1000000)` from Prolog       |        0.17        |

## <span id="sec:10"><span class="sec-nr">10</span> <span class="sec-title">Python or C/C++ for accessing resources?</span></span>

<span id="sec:janus-vs-c"></span>

Using Python as an intermediate to access external resources allows
writing such interfaces with less effort by a much wider community. The
resulting interface is often also more robust due to well defined data
conversion and sound memory management that you get for free.

Nevertheless, Python often accesses resources with a C or C++ API. We
can also create this bridge directly, bypassing Python. That avoids one
layer of data conversion and preserves the excellent multi-threading
capabilities of SWI-Prolog. As is, Python operations are synchronized
using the Python *GIL*, a global lock that allows for only a single
thread to use Python at the same time.<sup>9<span class="fn-text">There
are rumors that Python's multi threading will be able to use multiple
cores.</span></sup>

Writing an interface for SWI-Prolog is typically easier that for
Python/C because memory management is easier. Where we need to manage
reference counts to Python objects through all possibly paths of the C
functions, SWI-Prolog `term_t` merely has to be allocated once in the
function. All failure parts will discard the Prolog data automatically
through backtracking and all success paths will do so through the Prolog
garbage collector.<sup>10<span class="fn-text">Using a Python C++
interface such as [pybind11](https://github.com/pybind/pybind11)
simplifies memory management for a Python interface.</span></sup>

Summarizing, Janus is ideal to get started quickly. Applications that
need to access C/C++ resources and need either exploit all cores of your
hardware or get the best performance on calls or exchanging data should
consider using the C or C++ interfaces of SWI-Prolog.

## <span id="sec:11"><span class="sec-nr">11</span> <span class="sec-title">Janus platforms notes</span></span>

<span id="sec:janus-platforms"></span>

Janus relies on the C APIs of Prolog and Python and functions therefore
independent from the platform. While the C, Python and Prolog code the
builds Janus is platform independent, dynamically loading Prolog into
Python or Python into Prolog depends on versions as well as several
properties of the dynamic linking performed by the platform. In the
sections below we describe some of the issues.

### <span id="sec:11.1"><span class="sec-nr">11.1</span> <span class="sec-title">Janus on Windows</span></span>

<span id="sec:janus-on-windows"></span>

We tested the Windows platform using SWI-Prolog binaries from
<https://www.swi-prolog.org/Downloads.html> and Python downloaded from
<https://www.python.org/downloads/windows/>. The SWI-Prolog binary
provides `janus.dll` which is linked to `python3.dll`, a “stable API''
based wrapper that each Python 3 binary distribution provides in
addition to `python3xx.dll`. Calling Python from Prolog is supported out
of the box, provided the folder holding `python3.dll` is in the search
`%PATH%`.

The Python package can be installed using **pip** as described in
[section 7](#sec:7). Once built, this package finds SWI-Prolog on
`%PATH%` or using the registry and should be fairly independent from the
Prolog version as long as it is version 9.1.12 or later.

### <span id="sec:11.2"><span class="sec-nr">11.2</span> <span class="sec-title">Janus on Linux</span></span>

<span id="sec:janus-on-linux"></span>

On Linux systems we bind to the currently installed Prolog and Python
version. This should work smoothly from source. Janus is included in the
[PPA distribution](https://www.swi-prolog.org/build/PPA.html) for Ubuntu
as well as in the [Docker
images](https://www.swi-prolog.org/Docker.html). It is currently not
part of the SNAP distribution.

See [section 7](#sec:7) for for building the `janus_swi` Python package.

### <span id="sec:11.3"><span class="sec-nr">11.3</span> <span class="sec-title">Janus on MacOS</span></span>

<span id="sec:janus-on-macos"></span>

Unfortunately MacOS versions of Python do not ship with the equivalent
of `python3.dll` found on Windows. This implies we can only compile our
binaries against a specific version of Python. We will use the default
Python binary for that, which is installed in
`/Library/Frameworks/Python.framework/`

The Macports version is also linked against an explicit version of
Python, in this case provided by Macports.

The Python package `janus_swi` may be compiled against any version of
Python selected by **pip**. See [section 7](#sec:7) for details.

## <span id="sec:12"><span class="sec-nr">12</span> <span class="sec-title">Compatibility to the XSB Janus implementation</span></span>

<span id="sec:janus-vs-xsb"></span>

We aim to provide an interface that is close enough to allow developing
Prolog code that uses Python and visa versa. Differences between the two
Prolog implementation make this non-trivial. SWI-Prolog has native
support for *dicts*, *strings*, *unbounded integers*, *rational numbers*
and *blobs* that provide safe pointers to external objects that are
subject to (atom) garbage collection.

We try to find a compromise to make the data conversion as close as
possible while supporting both systems as good as possible. For this
reason we support creating a Python dict both from a SWI-Prolog dict and
from the Prolog term `py({k1:v1, k2:v2, ...})`. With `py` defined as a
prefix operator, this may be written without parenthesis and is thus
equivalent to the SWI-Prolog dict syntax. The `library(janus)` library
provides access predicates that are supported by both systems and where
the SWI-Prolog version supports both SWI-Prolog dicts and the above
Prolog representation. See
<span id="idx:items2:31"></span>[items/2](#items/2),
<span id="idx:values3:32"></span>[values/3](#values/3),
<span id="idx:key2:33"></span>[key/2](#key/2) and
<span id="idx:items2:34"></span>[items/2](#items/2).

Calling Python from Prolog provides a low-level and a more high level
interface. The high level interface is realized by
<span id="idx:pycall23:35"></span>[py\_call/\[2,3\]](#py_call/2) and
<span id="idx:pyiter23:36"></span>[py\_iter/\[2,3\]](#py_iter/2). We
realize the low level interfaces
<span id="idx:pyfunc34:37"></span>[py\_func/\[3,4\]](#py_func/3) and
<span id="idx:pydot45:38"></span>[py\_dot/\[4,5\]](#py_dot/4) on top of
<span id="idx:pycall2:39"></span>[py\_call/2](#py_call/2). The interface
for calling Prolog from Python is settled on the five primitives
described in [section 5](#sec:5).

We are discussing to minimize the differences. Below we summarize the
known differences.

  - SWI-Prolog represents Phyton dicts as Prolog dicts. XSB uses a term
    py( k:v, ... ), where the `py()` wrapper is optional. The predicate
    <span id="idx:pyisdict1:40"></span>[py\_is\_dict/1](#py_is_dict/1)
    may be used to test that a Prolog term represents a Python dict. The
    predicates <span id="idx:values3:41"></span>[values/3](#values/3),
    <span id="idx:keys2:42"></span>[keys/2](#keys/2),
    <span id="idx:key2:43"></span>[key/2](#key/2) and
    <span id="idx:items2:44"></span>[items/2](#items/2) can be used to
    access either representation.
  - SWI-Prolog allows for `prolog(Term)` to be sent to Python, creating
    an instance of [janus.Term()](#janus.Term\(\)).
  - SWI-Prolog represents Python object references as a *blob*. XSB uses
    a term. The predicate
    <span id="idx:pyisobject1:45"></span>[py\_is\_object/1](#py_is_object/1)
    may be used to test that a Prolog term refers to a Python object. In
    XSB, the user *must* call
    <span id="idx:pyfree1:46"></span>[py\_free/1](#py_free/1) when done
    with some object. In SWI-Prolog, either
    <span id="idx:pyfree1:47"></span>[py\_free/1](#py_free/1) may be
    used or the object may be left to the Prolog (atom) garbage
    collector.
  - Exceptions are represented differently, both representing Python
    exceptions in Prolog and Prolog exceptions in Python. As a result,
    acting on specific types of exceptions in a portable way is not
    supported.
  - When calling Prolog from Python and relying on well founded
    semantics, only *plain truth values* (i.e., `janus.undefined` are
    supported in a portable way. *Delay lists*, providing details on why
    the result is undefined, are represented differently.

### <span id="sec:12.1"><span class="sec-nr">12.1</span> <span class="sec-title">Writing portable Janus modules</span></span>

<span id="sec:janus-portable-code"></span>

This section will be written after the dust has settled. Topics

  - Dealing with Python dicts
  - Dealing with Prolog modules
  - Dealing with Prolog references to Python objects
  - More?

## <span id="sec:13"><span class="sec-nr">13</span> <span class="sec-title">Status of Janus</span></span>

<span id="sec:janus-status"></span>

The current version of this Janus library must be considered *beta*
code.

  - The design is stable
  - Naming and functionality are almost stable.
  - Testing is not exhaustive.

## Bibliography

  - <span id="DBLP:series/lncs-0001S23">**Andersen & Swift,
    2023**</span>  
    Carl Andersen and Theresa Swift. The janus system: A bridge to new
    prolog applications. In David Scott Warren, Verónica Dahl, Thomas
    Eiter, Manuel V. Hermenegildo, Robert A. Kowalski, and Francesca
    Rossi, editors, *Prolog: The Next 50 Years*, volume 13900 of
    *Lecture Notes in Computer Science*, pages 93--104. Springer, 2023.
  - <span id="DBLP:journals/corr/abs-2308-15893">**Swift & Andersen,
    2023**</span>  
    Theresa Swift and Carl Andersen. The janus system: Multi-paradigm
    programming in prolog and python. *CoRR*, abs/2308.15893, 2023.

# <span id="document-index">Index</span>

  - ?  
    between/3  
    [5.2](#idx:between3:19)

  - call\_delays/2  
    [5.4.1](#idx:calldelays2:20)

  - call\_residual\_program/2  
    [5.4.1](#idx:callresidualprogram2:21)

  - [items/2](#items/2)  
    [12](#idx:items2:31) [12](#idx:items2:34) [12](#idx:items2:44)

  - [janus.apply()](#janus.apply\(\))  
    [janus.apply.close()](#janus.apply.close\(\))  
    [janus.apply.next()](#janus.apply.next\(\))  
    [janus.apply\_once()](#janus.apply_once\(\))  
    [janus.attach\_engine()](#janus.attach_engine\(\))  
    [janus.cmd()](#janus.cmd\(\))  
    [janus.consult()](#janus.consult\(\))  
    [janus.detach\_engine()](#janus.detach_engine\(\))  
    [janus.engine()](#janus.engine\(\))  
    [janus.once()](#janus.once\(\))  
    [janus.prolog()](#janus.prolog\(\))  
    [janus.query()](#janus.query\(\))  
    [janus.query.close()](#janus.query.close\(\))  
    [janus.query.next()](#janus.query.next\(\))  
    [janus.query\_once()](#janus.query_once\(\))  
    [key/2](#key/2)  
    [12](#idx:key2:33) [12](#idx:key2:43)

  - [keys/2](#keys/2)  
    [12](#idx:keys2:42)

  - message\_to\_string/2  
    [5.6](#idx:messagetostring2:26)

  - once/1  
    [1](#idx:once1:3) [5](#idx:once1:14) [5](#idx:once1:16)

  - parent/2  
    [5](#idx:parent2:15)

  - print/1  
    [5.5](#idx:print1:24)

  - print\_message/2  
    [4.1](#idx:printmessage2:12) [5](#idx:printmessage2:17)

  - [py\_add\_lib\_dir/1](#py_add_lib_dir/1)  
    [py\_add\_lib\_dir/2](#py_add_lib_dir/2)  
    [py\_call/1](#py_call/1)  
    [py\_call/2](#py_call/2)  
    [1](#idx:pycall2:1) [2](#idx:pycall2:7) [4.1](#idx:pycall2:11)
    [12](#idx:pycall2:39)

  - [py\_call/3](#py_call/3)  
    [2](#idx:pycall3:4)

  - py\_call/\[2,3\]  
    [12](#idx:pycall23:35)

  - [py\_dot/4](#py_dot/4)  
    [py\_dot/5](#py_dot/5)  
    py\_dot/\[4,5\]  
    [12](#idx:pydot45:38)

  - [py\_free/1](#py_free/1)  
    [3.1](#idx:pyfree1:10) [12](#idx:pyfree1:46) [12](#idx:pyfree1:47)

  - [py\_func/3](#py_func/3)  
    [py\_func/4](#py_func/4)  
    py\_func/\[3,4\]  
    [12](#idx:pyfunc34:37)

  - [py\_gil\_owner/1](#py_gil_owner/1)  
    [6.2](#idx:pygilowner1:30)

  - [py\_initialize/3](#py_initialize/3)  
    [py\_is\_dict/1](#py_is_dict/1)  
    [12](#idx:pyisdict1:40)

  - [py\_is\_object/1](#py_is_object/1)  
    [5.5](#idx:pyisobject1:23) [12](#idx:pyisobject1:45)

  - [py\_iter/2](#py_iter/2)  
    [1](#idx:pyiter2:2) [3.1](#idx:pyiter2:9)

  - [py\_iter/3](#py_iter/3)  
    [2](#idx:pyiter3:5)

  - py\_iter/\[2,3\]  
    [12](#idx:pyiter23:36)

  - [py\_lib\_dirs/1](#py_lib_dirs/1)  
    [py\_module/2](#py_module/2)  
    [py\_obj\_dict/2](#py_obj_dict/2)  
    [py\_obj\_dir/2](#py_obj_dir/2)  
    [py\_pp/1](#py_pp/1)  
    [py\_pp/2](#py_pp/2)  
    [py\_pp/3](#py_pp/3)  
    [py\_setattr/3](#py_setattr/3)  
    [py\_shell/0](#py_shell/0)  
    [5](#idx:pyshell0:18)

  - [py\_version/0](#py_version/0)  
    [4.2](#idx:pyversion0:13)

  - [py\_with\_gil/1](#py_with_gil/1)  
    [6](#idx:pywithgil1:28)

  - [values/3](#values/3)  
    [12](#idx:values3:32) [12](#idx:values3:41)

  - with\_mutex/2  
    [6.2](#idx:withmutex2:29)

  - write\_canonical/1  
    [2](#idx:writecanonical1:6) [2](#idx:writecanonical1:8)
    [5.4.1](#idx:writecanonical1:22) [5.5](#idx:writecanonical1:25)
    [5.6](#idx:writecanonical1:27)

  - Exception  
    [5.6](#sec:5.6)

  - F  
    fractions:Fraction  
    [2](#sec:2)

  - P  
    janus.PrologError  
    [5.6](#sec:5.6)

  - [janus.PrologError()](#janus.PrologError\(\))  
    [janus.PrologError.\_\_repr\_\_()](#janus.PrologError.__repr__\(\))  
    [janus.PrologError.\_\_str\_\_()](#janus.PrologError.__str__\(\))  
    Q  
    [janus.Query()](#janus.Query\(\))  
    T  
    janus.Term  
    [5.6](#sec:5.6)

  - [janus.Term()](#janus.Term\(\))  
    [janus.Term.\_\_repr\_\_()](#janus.Term.__repr__\(\))  
    [janus.Term.\_\_str\_\_()](#janus.Term.__str__\(\))  
    [janus.TruthVal()](#janus.TruthVal\(\))  
    U  
    [janus.Undefined()](#janus.Undefined\(\))
