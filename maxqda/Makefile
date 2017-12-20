input=$(wildcard train_poi_data_abstract_only/*.txt)


%.rtf: %.txt
	pandoc -s -o $@ $<

default: $(input:.txt=.rtf)
