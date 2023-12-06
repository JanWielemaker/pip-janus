# pip-janus

## XSB conversion

    pandoc -f latex -t gfm janus-man.tex -o janus-xsb.md

## SWI conversion

    pandoc -t gfm -o janus-swi.md janus.html

## Merging

Currently only for Prolog predicates.

    swipl tools/merge.pl --interleave janus-xsb.md janus-swi.md janus-merged.md
