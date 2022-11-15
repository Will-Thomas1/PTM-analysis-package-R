# PTM Histone Analysis Made Easy (PHAME)

## Installation and Tips

To install the package you must have the package ‘devtools’. If you don’t have this package you can install it by running the code:

**install.packages(“devtools”)**

When devtools is installed, download the package by running the code below:

**devtools::install_github("Will-Thomas1/PTM-analysis-package-R")**

Then, to load all functions into the global environment run:

**library(“PHAME”)**

Instead of referring back to this README file in the future, by running ?[function] you can get a reminder of what the function does and how to define all of its parameters in the help tab. For example ?normalise_to gives:

![image](https://user-images.githubusercontent.com/107320556/202028510-c250e9c0-3e7f-4158-aa13-5b2ebd6ababb.png)

The PTM_info_df dataframe which is loaded into the global environment upon running library("PHAME") contains all the shorthand and longhand abbreviations for PTMs. To edit this go to the data-raw file and edit the abbrevs_and_longhand_PTM_names file. 

To quickly get a list of all the functions in PHAME enter "**PHAME::**" (without quotation marks) into the console 
 
## Description of functions

### add_seq_info
•	Adds a new column that incorporates the information in the modifications description column into the sequence.

•	If df_with_sequences_and_modifications is left blank a prompt will appear allowing the Excel file of choice to be selected. 

•	residues_to_mark_as_unmodified - 

•	If add_Nterm_mods parameter is TRUE then N-terminal modifications will be added as well. 

![image](https://user-images.githubusercontent.com/107320556/202029057-d8073fb4-31fc-4103-bc09-00c1fea88c1c.png)
![image](https://user-images.githubusercontent.com/107320556/202028789-d361212a-7826-4a1b-8536-a649f057700f.png)


### add_relative_abundance

•	Create new columns with relative abundances by dividing the abundance for one row by the sum of the total abundace.

•	If the abundance_colnames parameter is left blank then all column headers with 'abundance' in them will be chosen. 

•	New columns generated will have the same name as the ones they're derived from except they'll have '_relative' appended at the end.
 
![image](https://user-images.githubusercontent.com/107320556/202029376-f377d9c4-b108-4f3f-9359-050a96d819f1.png)
 
### average_freq_of_PTM_per_seq

•	Calculates the average number of PTMs per row. This can be weighted by abundance or not using the weight_by_abundance parameter (TRUE by default). 

•	If no abundance columns are selected, all are chosen. 
 
![image](https://user-images.githubusercontent.com/107320556/201529375-1132dd56-3150-4c02-bb75-a1f284a721aa.png)
![image](https://user-images.githubusercontent.com/107320556/201529378-c620071e-8f70-410b-8825-68fc4f1929e8.png)


 
### prop_of_seqs_containing_PTM

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
 
![image](https://user-images.githubusercontent.com/107320556/202028112-914a4eba-ba6c-4ae9-9efe-6d245b87e467.png) 
 
 
### possible_arrangements_of_PTMs

•	For a given sequence and set of PTMs, find all the combinations in which the PTMs could appear on the sequence. 

![image](https://user-images.githubusercontent.com/107320556/202028347-c931ade7-ae0c-40d6-8a02-24d950cd1698.png)

 
### prop_of_rows_with_PTM

•	Calculates the proportion of rows which contain specified PTMs.
 
![image](https://user-images.githubusercontent.com/107320556/201529410-51407aac-2f66-4400-beed-ea08495584de.png)


### add_positions_of_PTMs_col 

•	Adds a column with the PTMs (excluding N-termini) and their position on a protein they’ve already been assigned to (NOT the position of the PTM on the peptide).

•	This function will not work if there are two values in either of the start/ end columns. 

•	Due to methionine cleavage subtract_1 is an option to change the start and end values to those more commonly found in the literature (e.g. K28ac to K27ac).
 
![image](https://user-images.githubusercontent.com/107320556/202029628-b5f71f9e-6d4d-4782-8df9-e9b9ab410440.png)
 





