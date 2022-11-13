# PTM-analysis-package-R

## Installation

To install the package you must have the package ‘devtools’. If you don’t have this package you can install it by running the code:

**install.packages(“devtools”)**

When devtools is installed, download the package by running the code below:

**devtools::install_github("Will-Thomas1/PTM-analysis-package-R")**

Then, to load all functions into the global environment run:

**library(“PHAME”)**

Instead of referring back to this README file in the future, by running ?[function] you can get a reminder of what the function does and how to define all of its parameters in the help tab. For example ?normalise_to gives:

![image](https://user-images.githubusercontent.com/107320556/201528945-2f84b56f-5492-4b16-b22c-c445e0448284.png)

The PTM_info_df dataframe which is loaded into the global environment upon running library("PHAME") contains all the shorthand and longhand abbreviations for PTMs. To edit this go to the data-raw file and edit the abbrevs_and_longhand_PTM_names file. 
 
## Description of functions

### add_seq_info
•	Adds a new column that incorporates the information in the modifications description column into the sequence.

•	If df_with_sequences_and_modifications is left blank a prompt will appear allowing the Excel file of choice to be selected. 

•	residues_to_mark_as_unmodified - 

•	If add_Nterm_mods parameter is TRUE then N-terminal modifications will be added as well. 

![image](https://user-images.githubusercontent.com/107320556/201529294-981cc51f-38de-40df-9b76-f1e08a43dfd3.png)
![image](https://user-images.githubusercontent.com/107320556/201529298-1b0a477e-2c1d-4736-a4d6-de4c73d58228.png)


### add_rel_abundance_col

•	Create new columns with relative abundances by dividing the abundance for one row by the sum of the total abundace.

•	If the abundance_colnames parameter is left blank then all column headers with 'abundance' in them will be chosen. 

•	New columns generated will have the same name as the ones they're derived from except they'll have '_relative' appended at the end.
 
![image](https://user-images.githubusercontent.com/107320556/201529343-165623f9-9690-49d7-a135-958007df9f75.png)
 
### average_freq_of_PTM_per_seq

•	Calculates the average number of PTMs per row. This can be weighted by abundance or not using the weight_by_abundance parameter (TRUE by default). 

•	If no abundance columns are selected, all are chosen. 
 
![image](https://user-images.githubusercontent.com/107320556/201529375-1132dd56-3150-4c02-bb75-a1f284a721aa.png)
![image](https://user-images.githubusercontent.com/107320556/201529378-c620071e-8f70-410b-8825-68fc4f1929e8.png)


 
### prop_of_seqs_containing_PTM()

•	This function first groups together all sequences that contain a specified PTM or even a residue. It will then give the ratio, by abundance, of sequences containing the PTM divided by the total abundance. 

### delete_rows_with_same_elements_in_cols

•	Deletes rows that have the same values for a vector of specified column names.

•	This function groups rows that have the same values for all the specified columns. 

•	In addition to the primary function, it's also possible to specify if some species are not quantified to exclude these species from being deleted. If a row has all 'NA' values in all columns with 'abundance' in it, they will be retained. By default ignore_rows_where_all_abundances_NA, the parameter that controls this, is set to true.

### mgf_to_datatable

•	This function takes an mgf file and translates the information into a datatable format.

•	Can only do one mgf file at a time.

### normalise_to 

•	Normalises the abundance values of selected columns to a reference column. 

•	If comparison_cols parameter is not defined all columns with abundance in them will be chosen. 
 
![image](https://user-images.githubusercontent.com/107320556/201529393-3042d832-7f72-4494-a0ec-575e276d3915.png)
 
 
### possible_arrangements_of_PTMs

•	For a given sequence and set of PTMs, find all the combinations in which the PTMs could appear on the sequence. 
 
![image](https://user-images.githubusercontent.com/107320556/201529400-9faedba6-e877-444c-8942-20513b8121a1.png)

 
### prop_of_rows_with_PTM

•	Calculates the proportion of rows which contain specified PTMs.
 
![image](https://user-images.githubusercontent.com/107320556/201529410-51407aac-2f66-4400-beed-ea08495584de.png)


### add_positions_of_PTMs_col 

•	Adds a column with the PTMs (excluding N-termini) and their position on a protein they’ve already been assigned to (NOT the position of the PTM on the peptide).

•	This function will not work if there are two values in either of the start/ end columns. 

•	Due to methionine cleavage subtract_1 is an option to change the start and end values to those more commonly found in the literature (e.g. K28ac to K27ac).
 
![image](https://user-images.githubusercontent.com/107320556/201529470-18831c3c-3f42-4b6c-8b53-ddd74f64f5ac.png)

 
### PTM_abundance_at_given_position_by_abundance()

•	If you give a specific position you’re interested in AND a PTM you’ll get the percent of sequences/ residues at that position which have that PTM you specified. 

•	For example, if you specify “K10bu”, you’ll get a percentage of what lysines at that position are butyrylated. 
 





