# Windows1250 (central europe)
unzip -p train_poi_data_abstract_only.zip train_poi_data_abstract_only/1556_16296.txt | \
	iconv -f UTF-8 -t CP1250 > 1556_16296-cp1250.txt

# Windows 1252 (western europe)
unzip -p train_poi_data_abstract_only.zip train_poi_data_abstract_only/1556_16296.txt | \
	iconv -f UTF-8 -t CP1252 > 1556_16296-cp1252.txt

# RTF Windows1250 (central europe)
unzip -p train_poi_data_abstract_only.zip train_poi_data_abstract_only/1556_16296.txt | \
	iconv -f UTF-8 -t CP1250 | \
	pandoc -s -o 1556_16292-cp1250.rtf

# RTF Windows1252 (central europe)
unzip -p train_poi_data_abstract_only.zip train_poi_data_abstract_only/1556_16296.txt | \
	iconv -f UTF-8 -t CP1252 | \
	pandoc -s -o 1556_16292-cp1252.rtf

# RTF UTF-8
unzip -p train_poi_data_abstract_only.zip train_poi_data_abstract_only/1556_16296.txt | \
	pandoc -s -o 1556_16292-utf8.rtf
