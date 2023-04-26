#!/usr/bin/env perl
# -*- cperl -*-

use strict;
use Getopt::Long;

# where to start with recursive scan
my $SRCDIR = "./plug-ins";

# output undocumented plugins??
my $show_undocumented_plugins = 0;

# if you want chapters for each subdir set to 1 else to 0:
my $separte_dirs_by_chapters = 1;

# if you want to include chapter introductions (look for PlugInClass.doc files)
my $look_for_chapter_intro   = 1;
my $ClassIntroFile = "PlugInClass.doc";


my $MODULE = "Gxsm-4.0";

# known tags:
my $DSC_BEGIN_TAG   = "% BeginPlugInDocuSection";
my $DSC_CAPTION_TAG = "% PlugInDocuCaption:";
my $DSC_NAME_TAG    = "% PlugInName:";
my $DSC_AUTHOR_TAG  = "% PlugInAuthor:";
my $DSC_EMAIL_TAG   = "% PlugInAuthorEmail:";
my $DSC_MENUPATH_TAG= "% PlugInMenuPath:";
my $DSC_DSC_TAG     = "% PlugInDescription";
my $DSC_USE_TAG     = "% PlugInUsage";
my $DSC_OSEC_TAG    = "% OptPlugInSection:";
my $DSC_OSSEC_TAG   = "% OptPlugInSubSection:";
my $DSC_OSRCS_TAG   = "% OptPlugInSources";
my $DSC_OOBJ_TAG    = "% OptPlugInObjects";
my $DSC_ODEST_TAG   = "% OptPlugInDest";
my $DSC_OCONF_TAG   = "% OptPlugInConfig";
my $DSC_OFILE_TAG   = "% OptPlugInFiles";
my $DSC_OREF_TAG    = "% OptPlugInRefs";
my $DSC_OBUGS_TAG   = "% OptPlugInKnownBugs";
my $DSC_ONOTES_TAG  = "% OptPlugInNotes";
my $DSC_OHINTS_TAG  = "% OptPlugInHints";
my $DSC_END_TAG     = "% EndPlugInDocuSection";
my $DSC_TAG         = "% PlugIn|% OptPlugIn|% EndPlugIn";

# tag for ignoreing source file
my $DSC_MODULEIGNORE_TAG  = "% PlugInModuleIgnore";

# where to place docu
my $OUTPUT_DIR = "./src/latex";

# additional files to ignore
my $IGNORE_FILES = ""; # "vorlage.C";

# not used now
my $main_list = "";
my $object_list = "";

# output path/file
my $plugin_list = "${OUTPUT_DIR}/$MODULE-plugins.tex";

# output for undocumented plugins and some stats
my $plugin_undoc_list = "${OUTPUT_DIR}/$MODULE-undocumented.tex";
my $number_of_scanned_plugins = 0;
my $number_of_documented_plugins = 0;
my $number_of_undocumented_plugins = 0;
my $number_of_ignored_subroutine_files = 0;
my $number_of_ignored_plugins = 0;

open (PLUGINLIST, ">$plugin_list")
    || die "Can't open $plugin_list";

open (PLUGIN_UNDOC_LIST, ">$plugin_undoc_list")
    || die "Can't open $plugin_list";

print PLUGIN_UNDOC_LIST "% Do not edit this file, it is autogenerated!\n";
print PLUGIN_UNDOC_LIST "% This is a list of still undocumented PlugIns.\n\n";
print PLUGIN_UNDOC_LIST "% ------------------------------------------------------------\n\n";
print PLUGIN_UNDOC_LIST "\\chapter{List of undocumented and ignored GXSM Plug-Ins}\n\n";


print PLUGINLIST "% Do not edit this file, it is autogenerated!\n";
print PLUGINLIST "% Edit the PlugIn Docu section in the PlugIn source file instead!\n\n";
print PLUGINLIST "% ------------------------------------------------------------\n\n";
print PLUGINLIST "% start of PlugIn docu scan\n";

if ($separte_dirs_by_chapters == 0){
  print PLUGINLIST "\\chapter{GXSM Plug-Ins}\n\n";
  print PLUGINLIST "Introduction to PlugIns..., to do!\n\n";
}

&ScanCFiles ($SRCDIR, \$object_list, \$main_list);

print PLUGINLIST "% ------------------------------------------------------------\n\n";
print PLUGINLIST "% finished PlugIn docu scan.\n";
print PLUGINLIST "% End of autogenerated PlugIn docu file.\n";

close (PLUGINLIST);

print PLUGIN_UNDOC_LIST "\\section{Summary of PlugIn documentation scan}\n\n";
print PLUGIN_UNDOC_LIST "Number of scanned PlugIns/Files: ", $number_of_scanned_plugins, "\\\\\n";
print PLUGIN_UNDOC_LIST "Number of documented PlugIns: ", $number_of_documented_plugins, "\\\\\n";
print PLUGIN_UNDOC_LIST "Number of undocumented PlugIns: ", $number_of_undocumented_plugins, "\\\\\n";
print PLUGIN_UNDOC_LIST "Number of ignored PlugIns: ", $number_of_ignored_plugins, "\\\\\n";
print PLUGIN_UNDOC_LIST "Number of ignored subroutine Files: ", $number_of_ignored_subroutine_files, "\\\\\n\n";
print PLUGIN_UNDOC_LIST "% ------------------------------------------------------------\n\n";
print PLUGIN_UNDOC_LIST "% End of autogenerated file.\n";
close (PLUGIN_UNDOC_LIST);

# Summary
print "\n\nSummary of PlugIn Documentation Scan\n";
print "----------------------------------------------\n";
print "Number of scanned PlugIns/Files.... : ", $number_of_scanned_plugins, "\n";
print "Number of documented PlugIns....... : ", $number_of_documented_plugins, "\n";
print "Number of undocumented PlugIns..... : ", $number_of_undocumented_plugins, "\n";
print "Number of ignored PlugIns.......... : ", $number_of_ignored_plugins, "\n";
print "Number of ignored subroutine Files. : ", $number_of_ignored_subroutine_files, "\n\n";

print "Files generated:\n";
print "----------------------------------------------\n";
print "PlugIn Manual...................... : ", $plugin_list, "\n";
print "Undocumented PlugIns............... : ", $plugin_undoc_list, "\n\n";

sub ScanCFiles {
  my ($source_dir, $object_list, $main_list) = @_;
  print "Scanning source directory: $source_dir\n";
  
  # This array holds any subdirectories found.
  my (@subdirs) = ();
  
  opendir (SRCDIR, $source_dir)
    || die "Can't open source directory $source_dir: $!";

  my $addchap = 1;
  my $file;
  foreach $file (readdir (SRCDIR)) {
    if ($file eq '.' || $file eq '..' || $file =~ /^\./) {
      next;
    } elsif (-d "$source_dir/$file") {
      push (@subdirs, $file);
    } elsif ($file =~ m/\.C$/) {
      if ($separte_dirs_by_chapters){
	if ($addchap){
	  my $formateddir = $source_dir;
	  $formateddir =~ s/..\/..\/plug-ins\///;
	  $formateddir =~ s/.\/plug-ins\///;
	  $formateddir =~ s/_/\\_/g;
	  print "DEBUG: new PlugIn Chapter: ", $formateddir, " ----------\n";
	  print PLUGINLIST "\n\n";
	  print PLUGINLIST "% Subdirectory: ", $source_dir, "\n";
	  print PLUGINLIST "% ------------------------------------------------------------\n\n";
	  print PLUGINLIST "\\chapter{Plug-Ins: ", $formateddir,"}\n\n";
	  $addchap = 0;

	  if ($look_for_chapter_intro){
	    &WritePlugInClassIntro ("$source_dir/$ClassIntroFile", $object_list, $main_list);
	  }
	}
      }
      &ScanPlugIn ("$source_dir/$file", $object_list, $main_list);
    }
  }
  closedir (SRCDIR);
  
  # Now recursively scan the subdirectories.
  my $dir;
  foreach $dir (@subdirs) {
    next if ($IGNORE_FILES =~ m/(\s|^)\Q${dir}\E(\s|$)/);
    &ScanCFiles ("$source_dir/$dir", $object_list, $main_list);
  }
}

sub WritePlugInClassIntro {
#    print "DEBUG: Looking for Chapter Introduction...\n";
    my ($input_file, $object_list, $main_list) = @_;
    if (! -f $input_file) {
	print "WARNING: no $input_file found!\n";
	return;
    }

    open(INPUT, $input_file)
	|| die "Can't open $input_file: $!";
    
    print PLUGINLIST "% Inclusion of PlugInClassIntro: ", $input_file, "\n\n";
    while(<INPUT>) {
      next if /^\s*%/;
      print PLUGINLIST $_;
    }
}

sub ScanPlugIn {
    my ($input_file, $object_list, $main_list) = @_;
    my $file_basename;
    my $indocu = 0;
    my $nodocu = 1;
    my $close_on_next_tag = 0;
    my $ignoremodule = 0;
    my $nocaption = 1;

    my $caption= "";
    my $name   = "pi\\_name";
    my $author = "Nobody";
    my $email  = "Nobody\@no.net";
    my $menupath = "/";
    my $tag;
    my $needsclearpage = 0;

    print "DEBUG: Scanning $input_file\n";
    if ($input_file =~ m/^.*[\/\\](.*)\.C$/) {
	$file_basename = $1;
    } else {
	print "WARNING: Can't find basename of file $input_file\n";
	$file_basename = $input_file;
    }

    my $pluginname = $input_file;
    $pluginname =~ s/..\/..\/plug-ins\///;
    $pluginname =~ s/.\/plug-ins\///;
    $pluginname =~ s/_/\\_/g;
    my $pilabel = $name;


    # Check if the basename is in the list of headers to ignore.
    if ($IGNORE_FILES =~ m/(\s|^)\Q${file_basename}\E\.C(\s|$)/) {
	print "DEBUG: File ignored: $input_file\n";
	print PLUGIN_UNDOC_LIST "\\section{Ignored: ", $pluginname, "}\nThis PlugIn is ignored, because it's in the ignore list of the docuscangxsmplugins.pl script!\n\n";
	$number_of_ignored_plugins++;
	return;
    }

    if (! -f $input_file) {
	print "File doesn't exist: $input_file\n";
	return;
    }

    open(INPUT, $input_file)
	|| die "Can't open $input_file: $!";
    
    print PLUGINLIST "% PlugIn: ", $input_file, "\n";
    print PLUGINLIST "% ------------------------------------------------------------\n\n";
    
    while(<INPUT>) {
      if ($close_on_next_tag) {
	if (m/^\s/){
	  next;
	}
	if (m/^\t/){
	  next;
	}
	if (m/^\r/){
	  next;
	}
      }

      if (m/^$DSC_TAG/) {
	if ($close_on_next_tag) {
	  print PLUGINLIST "}\n\n";
	  $close_on_next_tag = 0;
	}
      }

      if (m/^\\GxsmScreenShot/){
#	print "DEBUG: Screenshot found\n";
	$needsclearpage = 1;
      }

      if (m/^$DSC_MODULEIGNORE_TAG/){
	$ignoremodule = 1;
	last;
      }elsif (m/^$DSC_BEGIN_TAG/) {
#	print "DEBUG: start docu tag found\n";
	$nodocu = 0;
	$indocu = 1;
      } elsif (m/^$DSC_END_TAG/) {
#	print "DEBUG: end docu tag found\n";
	$indocu = 0;
      } elsif (m/^$DSC_CAPTION_TAG/) {
	chop;
	($tag,$caption) = split(/: /);
	print PLUGINLIST "\\section{", $caption, "}\n";
	$nocaption = 0;
	next;
      } elsif (m/^$DSC_NAME_TAG/) {
	chop;
	($tag,$name) = split(/: /);
	$name = "Unnamed" unless($name);
	$pilabel = $name;
	$pilabel =~ s/_//g;
	$name =~ s/_/\\_/g;
	print PLUGINLIST "% Name=",$name,"\n";
	next;
      } elsif (m/^$DSC_AUTHOR_TAG/) {
	chop;
	($tag,$author) = split(/: /);
	print PLUGINLIST "% Author=",$author,"\n";
	next;
      } elsif (m/^$DSC_EMAIL_TAG/) {
	chop;
	($tag,$email) = split(/: /);
	$email =~ s/_/\\_/g;
	print PLUGINLIST "% Email=",$email,"\n";
	next;
      } elsif (m/^$DSC_MENUPATH_TAG/) {
	chop;
	($tag,$menupath) = split(/: /);
	$menupath =~ s/_/\\_/g;
	print PLUGINLIST "% Menupath=",$menupath,"\n";
	next;
      } elsif (m/^$DSC_DSC_TAG/) {
	print PLUGINLIST "\\label{pi:", $pilabel, "}\n";
	print PLUGINLIST "\\subsubsection{Description}\n\n";
	next;
      } elsif (m/^$DSC_USE_TAG/) {
	print PLUGINLIST "\\subsubsection{Usage}\n\n";
	next;
      } elsif (m/^$DSC_OSEC_TAG/) {
	chop;
	($tag,$caption) = split(/: /);
	print PLUGINLIST "\\subsection{", $caption, "}\n\n";
	next;
      } elsif (m/^$DSC_OSSEC_TAG/) {
	chop;
	($tag,$caption) = split(/: /);
	print PLUGINLIST "\\subsubsection{", $caption, "}\n\n";
	next;
      } elsif (m/^$DSC_OSRCS_TAG/) {
	print PLUGINLIST "\\subsubsection{Sources}\n\n";
	next;
      } elsif (m/^$DSC_OOBJ_TAG/) {
	print PLUGINLIST "\\subsubsection{Objects}\n\n";
	next;
      } elsif (m/^$DSC_ODEST_TAG/) {
	print PLUGINLIST "\\subsubsection{Destination}\n\n";
	next;
      } elsif (m/^$DSC_OREF_TAG/) {
	print PLUGINLIST "\\subsubsection{References}\n\n";
	next;
      } elsif (m/^$DSC_OCONF_TAG/) {
	print PLUGINLIST "\\subsubsection{Configuration}\n\n";
	next;
      } elsif (m/^$DSC_OFILE_TAG/) {
	print PLUGINLIST "\\subsubsection{Files}\n\n";
	next;
      } elsif (m/^$DSC_OBUGS_TAG/) {
	print PLUGINLIST "\\subsubsection{Known Bugs}\n\n";
	next;
      } elsif (m/^$DSC_ONOTES_TAG/) {
#	print PLUGINLIST "\\subsubsection{Notes}\n\n";
	print PLUGINLIST "\\GxsmNote{\n";
	$close_on_next_tag = 1;
	next;
      } elsif (m/^$DSC_OHINTS_TAG/) {
#	print PLUGINLIST "\\subsubsection{Hints}\n\n";
	print PLUGINLIST "\\GxsmHint{\n";
	$close_on_next_tag = 1;
	next;
      } elsif ($indocu){
	if ($nocaption) {
	  print "WARNING: no caption tag found! Using plugin path!\n";
	  print PLUGINLIST "\\section{", $pluginname, "}\n\n";
	  $nocaption = 0;
	}
	print PLUGINLIST $_;
      }

    }
    
    if ($ignoremodule) {
	print "DEBUG: ignoring this, it's part of a plugin!\n";
	$number_of_ignored_subroutine_files++;
    }elsif ($nodocu) {
      if ($show_undocumented_plugins){
	if ($nocaption) {
	  print "WARNING: no caption tag found! Using plugin path!\n";
	  print PLUGINLIST "\\section{", $pluginname, "}\n\n";
	  $nocaption = 0;
	}
	
	print PLUGINLIST "This PlugIn needs a documentation section in it's main source file!\n\n";
      }
      print PLUGIN_UNDOC_LIST "\\section{", $pluginname, "}\nThis PlugIn is needs documentation!\n\n";
      $number_of_undocumented_plugins++;
    }else{
      print PLUGINLIST "\\index{C-PlugIn!", $pluginname, "}\n";
      print PLUGINLIST "\\index{PlugIn!", $name, "}\n";
      print PLUGINLIST "\\index{GXSM-Menu!", $menupath, "}\n";
      print PLUGINLIST "\\subsubsection{Info for Plug-In: ", $menupath, " }\n";
      print PLUGINLIST "\\begin{tabbing}\n";
      print PLUGINLIST "Plug-In name:   \\= ", $author, $name, " \\= Email: \\= x \\kill\n";
      print PLUGINLIST "Plug-In name:   \\> ", $name,   "\\>  File:  \\> ", $pluginname, "\\\\\n";
      print PLUGINLIST "Author:	        \\> ", $author, "\\>  Email: \\> ", $email, "\\\\\n";
#      print PLUGINLIST "Plug-In name:   \\> ", $name,   "\\>  File:  \\> \\GxsmFile{", $pluginname, "}\\\\\n";
#      print PLUGINLIST "Author:	        \\> ", $author, "\\>  Email: \\> \\GxsmEmail{", $email, "}\\\\\n";
#      print PLUGINLIST "Menu path:      \\> ", $menupath, "\\\\\n";
      print PLUGINLIST "\\end{tabbing}\n\n";
      if ($needsclearpage){
# add a \clearpage (via macro) at end of each PlugIn Doc containing screenshots 
# to assure they are printyed and not moved to end of chapter
	print PLUGINLIST "\\GxsmClearpage\n\n";
      }
      $number_of_documented_plugins++;
    }
    $number_of_scanned_plugins++;

    close(INPUT);
}
