.PHONY: all

all: txt/lat_score.tsv.gz


txt/censored: 01_censorList.bash
	./01_censorList.bash

txt/id_date.txt: 02_subjInfo.bash
	./02_subjInfo.bas

txt/lat_score.tsv.gz: txt/id_date.txt 04_eyetracking_score_lat.bash 
	./04_eyetracking_score_lat.bash
