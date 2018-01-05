input=$(wildcard train_poi_data_abstract_only/*.txt)
output= $(addprefix output/,$(notdir $(input:.txt=.rtf)))

help:
	@echo 'Targets:'
	@echo ' * traindata - create training data files as UTF8-encoded RTFs. Run `make` twice'



# Convert training data

traindata: $(output) unzip_training

output:
	mkdir -p output

output/%.rtf: train_poi_data_abstract_only/%.txt output
	pandoc -s -o $@ $<

unzip_training: ../train_poi_data_abstract_only.zip
	unzip $<




# Extract from MEX files





debug:
	echo $(output2)

.PHONY: help traindata unzip_training
