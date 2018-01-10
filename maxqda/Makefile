input=$(wildcard train_poi_data_abstract_only/*.txt)
output= $(addprefix output/,$(notdir $(input:.txt=.rtf)))

help:
	@echo 'Targets:'
	@echo ' * traindata - create training data files as UTF8-encoded RTFs. Run `make` twice'
	@echo ' * unzip_mex - unZIP MAXWDA MEX files'
	@echo ' * extract - Create CSV with text fragments extracted from MEX files'

%.md: %.Rmd
	Rscript -e 'rmarkdown::render("$<")'




# Convert training data

traindata: $(output) unzip_training

output:
	mkdir -p output

output/%.rtf: train_poi_data_abstract_only/%.txt output
	pandoc -s -o $@ $<

unzip_training: ../train_poi_data_abstract_only.zip
	unzip $<




# Extract from MEX files

unzip_mex:
	unzip maxqda_100-300.zip
	unzip maxqda_300-end.zip

extract: mex_extract.md

mex_extract.md: unzip_mex



debug:
	echo $(output2)

.PHONY: help traindata unzip_training extract unzip_mex
