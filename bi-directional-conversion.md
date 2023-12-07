# Data conversion

## XSB version

## Bi-translation between Prolog Terms and Python Data Structures

`janus` takes advantage of a C-level bi-translation of a large portion
of Prolog terms and Python data structures: i.e., Python lists, tuples,
dictionaries, sets and other data types are translated to their Prolog
term forms, and Prolog terms of restricted syntax are translated to
lists, tuples, dictionaries, sets and so on. Bi-translation is recursive
in that any of these data structures can be nested in any other data
structures (subject to limitations on the occurrence of mutables in
Python data structures).

Due to syntactic similarities between Prolog terms and Python data
structures, the Prolog term forms are easy to translate and use – and
sometimes appear syntactically identical.

As terminology, when a Python data structure $D$ is translated into a
Prolog term $T$, $T$ is called a *(Janus) D term* e.g., a dictionary
term or a set term. he type representing any Python structure that can
be translated to Prolog is called *jns_struct* while *jns_term* is the
pseudo-type representing all Prolog terms that can be translated into a
Python data structure.

### The Bi-translation Specification

Bi-translation between Prolog and Python can be described from the
viewpoint of Python types as follows:

- *Numeric Types*: Python integers and floats are bi-translated to
  Prolog integers and floats. Python complex numbers are not (yet)
  translated, and in XSB translation is only supported for integers
  between XSB’s minimum and maximum integer [^3]

  - *Boolean Types* in Python are translated to the special Prolog
    structures `@(true)` and ` @(false)`.

- *String Types*: Python string types are bi-translated to Prolog atoms.
  XSB’s translation assumes UTF-8 encoding on both sides.

  Note that a Python string can be enclosed in either double quotes
  (`''`) or single quotes (`'`). In translating from Python to Prolog,
  the outer enclosure is ignored, so Python `"’Hello’"` is translated to
  the Prolog `’\’Hello\’’`, while the Python `’"Goodbye"’` is translated
  to the Prolog `’"Goodbye"’`.

- *Sequence Types*:

  - Python lists are bi-translated as Prolog lists and the two forms are
    syntactically identical. The maximum size of lists in both XSB and
    Python is limited only by the memory available.

  - A Python tuple of arity `N` is bi-translated with a compound Prolog
    term `-/N` (i.e., the functor is a hyphen). The maximum size of
    tuples in XSB is $2^{16}$.

- *Mapping Types*: The translation of Python dictionaries takes
  advantage of the syntax of braces, which is supported by any Prolog
  that supports DCGs. The term form of a dictionary is;

  `{ DictList} `

  where `DictList` is a comma list of `’:’/2` terms that use input
  notation.

  `Key:Value`

  `Key` and `Value` are the translations of any Python data structures
  that are both allowable as a dictionary key or value, and supported by
  `janus`. For instance, ` Value` can be (the term form of) a list, a
  set, a tuple or another dictionary as with

  `{’K1’:[1,2,3], ’k2’:(4,5,6)]}`

  which has a nearly identical term form as

  `{’K1’:[1,2,3], k2: -(4,5,6)]}`

- *Set Types*: A Python set *S* is translated to the term form

  `py_set(SetList)`

  where *SetList* is the list containing exactly the translated elements
  of $S$. Due to Python’s implementation of sets, there is no guarantee
  that the order of elements will be the same in $S$ and $SetList$.

- *None Types.* The Python keyword `None` is translated to the Prolog
  term `@(none)`.

- *Binary Types:* are not yet supported. There are no current plans to
  support this type in XSB.

- Any Python object `Obj` of a type that is not translated to a Prolog
  term as indicated above, and that does not have an associated iterator
  is translated to the Python object reference, which can be passed back
  to Python for an object call or other purposes. In XSB, object
  references have the form `pyObj(Obj)`, but this form is system
  dependent, and will differ in other Prologs that support `janus` such
  as SWI.


## SWI Version

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
<span id="idx:pycall3:4"></span>[py_call/3](#py_call/3) and
<span id="idx:pyiter3:5"></span>[py_iter/3](#py_iter/3) provide the
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
| \#(Term)       | `⟶` | String                          | *stringify* using <span id="idx:writecanonical1:6"></span><span class="pred-ext">write_canonical/1</span> if not atomic |
| prolog(Term)   | `⟶` | [janus.Term()](#janus.Term\(\)) | Represents any Prolog term                                                                                               |
| Term           | `⟵` | [janus.Term()](#janus.Term\(\)) |                                                                                                                          |
| List           | `⟶` | List                            |                                                                                                                          |
| List           | `⟵` | Sequence                        |                                                                                                                          |
| List           | `⟵` | Iterator                        | Note that a Python *Generator* is an *Iterator*                                                                          |
| py_set(List)  | `⟺` | Set                             |                                                                                                                          |
| \-()           | `⟺` | ()                              | Python empty Tuple                                                                                                       |
| \-(a,b, ... )  | `⟺` | (a,b, ... )                     | Python Tuples. Note that a Prolog *pair* `A-B` maps to a Python (binary) tuple.                                          |
| Dict           | `⟺` | Dict                            |                                                                                                                          |
| {k:v, ...}     | `⟺` | Dict                            | Compatibility when using `py_dict_as({}`)                                                                                |
| {k:v, ...}     | `⟹` | Dict                            | Compatibility (see above)                                                                                                |
| py({k:v, ...}) | `⟹` | Dict                            | Compatibility (see above)                                                                                                |
| eval(Term)     | `⟹` | Object                          | Evaluate Term as first argument of <span id="idx:pycall2:7"></span>[py_call/2](#py_call/2)                              |
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
<span id="idx:writecanonical1:8"></span><span class="pred-ext">write_canonical/1</span>.
The conversion `prolog(Term)` creates an instance of
[janus.Term()](#janus.Term\(\)). This class encapsulates a copy of an
arbitrary Prolog term. The SWI-Prolog implementation uses the
**PL_record()** and **PL_recorded()** functions to store and retrieve
the term. `Term` may be any Prolog term, including *blobs*, *attributed
variables*. Cycles and subterm sharing in `Term` are preserved.
Internally, [janus.Term()](#janus.Term\(\)) is used to represent Prolog
exeptions that are raised during the execution of
[janus.query_once()](#janus.query_once\(\)) or
[janus.query()](#janus.query\(\)).

Python Tuples are array-like objects and thus map best to a Prolog
compound term. There are two problems with this. One is that few systems
support compound terms with arity zero, e.g., `f` and many systems have
a limit on the *arity* of compound terms. Using Prolog *comma lists*,
e.g., `(a,b,c)` does not implement array semantics, cannot represent
empty tuples and cannot disambiguate tuples with one element from the
element itself. We settled with compound terms using the `-` as functor
to make the common binary tuple map to a Prolog *pair*.
