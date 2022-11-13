# PTM-analysis-package-R

## Installation

To install the package you must have the package ‘devtools’. If you don’t have this package you can install it by running the code:

**install.packages(“devtools”)**

When devtools is installed, download the package by running the code below:

**devtools::install_github("Will-Thomas1/PTM-analysis-package-R")**

Then, to load all functions into the global environment run:

**library(“PHAME”)**

Instead of referring back to this README file in the future, by running ?[function] you can get a reminder of what the function does and how to define all of its parameters in the help tab. For example ?normalise_to gives:

![image](https://user-images.githubusercontent.com/107320556/201520754-bd609ebb-a98d-435a-be36-22f1f74a8868.png)


 
## Description of functions

### add_seq_info
•	Adds a new column that incorporates the information in the modifications description column into the sequence.
•	If df_with_sequences_and_modifications is left blank a prompt will appear allowing the Excel file of choice to be selected. 
•	residues_to_mark_as_unmodified - 
•	If add_Nterm_mods parameter is TRUE then N-terminal modifications will be added as well. 
	 
### add_rel_abundance_col
•	Create new columns with relative abundances by dividing the abundance for one row by the sum of the total abundace.
•	If the abundance_colnames parameter is left blank then all column headers with 'abundance' in them will be chosen. 
•	New columns generated will have the same name as the ones they're derived from except they'll have '_relative' appended at the end.
 
### prop_of_seqs_containing_PTM()
•	This function first groups together all sequences that contain a specified PTM or even a residue. It will then give the ratio, by abundance, of sequences containing the PTM divided by the total abundance. 
filter_seqs_with_all_residues_mods()

If a protocol such as propionylation has been performed all the residues of a particular species should be modified. This function removes sequences that contain one or more unmodified residues.
prop_of_seqs_fully_modified()
•	Gives the proportion of sequences that have 100% of a particular residue fully modified divided by the total abundance. 

### Avg_no_of_PTMs()
•	Gives the average number of PTMs, or residues of a specific type, per sequence and weighted by abundance. 
Avg_no_of_residue_unmod()
•	Gives the average number of an unmodified residue per sequence and weighted by abundance. 
relative_abundance_ignore_PTMs()
•	This will create a dataframe with two columns: sequences that haven’t been modified and their abundance by %.
merge_repeats()
•	If two rows have the same sequence AND the same modifications (including N-terminal modifications) then these two rows will be merged. Repeats usually occur because the same peptide has been assigned to two different proteins with a shared sequence of amino acids. 
•	What separates this function from distinct() in tidyverse is that all the information is retained – if a sequence could belong to two different histones then those histone names are separated by a ‘;’ semicolon. 
•	In the example 
 
 
This is transformed into…..
 
 
### filter_Nterm_mods()
•	This function can quite easily be performed in Excel but this function will filter out any sequences that don’t contain a particular PTM or N-terminal modification. 
Nterm_mod_pct()
•	Calculates the percentage of sequences that have a modified N-terminus or PTM.
Cumulative distribution of sequences by the proportion of them that are modified by a particular PTM – not a function just yet
•	Although functions that spit out a number that tells you what proportion of sequences contain a particular PTM/ N-terminal modification are useful, they don’t tell you how sequences are distributed along the spectrum. For example, some sequences may be very efficiently propionylated at the N-terminus such that 99.9% of that sequence by abundance is propionylated by abundance. 
•	By plotting the number of cumulative frequency of sequences (ignoring any modifications) against the proportion of those sequences that are modified you can get an idea of what percentage of sequence are constitutively modified.
•	There’
•	For the example below, sequences which are acetylated is analysed. 
 
### add_positions_of_PTMs_col 
•	Adds a column with the PTMs (excluding N-termini) and their position on a protein they’ve already been assigned to (NOT the position of the PTM on the peptide).
•	This function will not work if there are two values in either of the start/ end columns. 
•	Due to methionine cleavage subtract_1 is an option to change the start and end values to those more commonly found in the literature (e.g. K28ac to K27ac).
•	An example of the column that will be added is shown below. 
 
### PTM_abundance_at_given_position_by_abundance()
•	If you give a specific position you’re interested in AND a PTM you’ll get the percent of sequences/ residues at that position which have that PTM you specified. 
•	For example, if you specify “K10bu”, you’ll get a percentage of what lysines at that position are butyrylated. 

