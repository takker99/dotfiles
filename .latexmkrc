#!/usr/bin/env perl
$latexargs          = '-shell-escape -synctex=1 -halt-on-error -file-line-error';
$latexsilentargs    = $latexargs . ' -interaction=batchmode';
$pdflatex           = 'lualatex %O ' . $latexargs . ' %S';
$latex_silent     = 'platex -synctex=1 -halt-on-error -interaction=batchmode';
$bibtex           = 'pbibtex';
$biber            = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf           = 'dvipdfmx %O -o %D %S';
$makeindex        = 'mendex %O -o %D %S';
$max_repeat       = 5;
$aux_dir          = "$ENV{XDG_CONFIG_HOME}/Tex_build_dir/";
$out_dir          = $aux_dir;
$pdf_mode         = 1;
$pvc_view_file_via_temporary = 0;
$pdf_previewer = 'evince'
